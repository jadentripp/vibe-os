#!/usr/bin/env bash
set -euo pipefail

REPO="${VIBE_REPO:-}"
REF="${VIBE_REF:-}"
CODESPACE_NAME="${CODESPACE_NAME:-}"
DISPLAY_NAME="${DISPLAY_NAME:-}"
CODESPACE_MACHINE="${CODESPACE_MACHINE:-}"
IDLE_TIMEOUT="${IDLE_TIMEOUT:-30m}"
RETENTION_PERIOD="${RETENTION_PERIOD:-1h}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
OPEN_BROWSER="${OPEN_BROWSER:-1}"
RUN_PREFLIGHT_ONLY=0

usage() {
  cat <<'EOF'
Usage: tools/play_now_codespaces.sh [options]

Create or reuse a disposable GitHub Codespace, start vibe-os Doom there through
tools/play_now_remote.sh, make noVNC private, and print the browser URL.

This script is safe to run on the Mac: it uses gh to control Codespaces only.
QEMU, the shareware WAD, disk image, pixels, and raw audio stay inside the
Codespace.

Options:
  --repo OWNER/REPO       Repository to create the Codespace from.
                          Default: gh repo view for the current checkout.
  --ref BRANCH            Branch/ref to use. Default: current git branch.
  --codespace NAME        Reuse an existing Codespace instead of creating one.
  --display-name NAME     Display name for a newly created Codespace.
  --machine NAME          Optional Codespaces machine type.
  --idle-timeout VALUE    Codespaces idle timeout. Default: 30m.
  --retention-period VAL  Codespaces retention after stop. Default: 1h.
  --preflight, --dry-run  Check gh/git/ref/port safety and print the plan
                          without creating, starting, or modifying a Codespace.
  --no-open               Do not open the noVNC URL automatically on macOS.
  -h, --help              Show this help.
EOF
}

die() {
  echo "play-now Codespaces failed: $*" >&2
  exit 1
}

require_tool() {
  command -v "$1" >/dev/null 2>&1 || die "missing required local tool: $1"
}

require_gh_auth() {
  gh auth status -h github.com >/dev/null 2>&1 || die "GitHub CLI is not authenticated for github.com; run gh auth login before launching Codespaces"
}

sanitize_display_part() {
  printf "%s" "$1" | tr '/_.' '---' | tr -cd 'A-Za-z0-9-'
}

current_repo() {
  gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null
}

current_ref() {
  git branch --show-current 2>/dev/null || true
}

validate_novnc_port() {
  case "$NOVNC_PORT" in
    ''|*[!0-9]*)
      die "NOVNC_PORT must be a TCP port number, got '$NOVNC_PORT'"
      ;;
  esac
  if [ "$NOVNC_PORT" -lt 1 ] || [ "$NOVNC_PORT" -gt 65535 ]; then
    die "NOVNC_PORT must be between 1 and 65535, got '$NOVNC_PORT'"
  fi
}

novnc_url_from_browse_url() {
  local browse_url="$1"

  case "$browse_url" in
    http://*|https://*)
      ;;
    *)
      die "gh returned an invalid noVNC browse URL for port $NOVNC_PORT: '$browse_url'"
      ;;
  esac

  case "$browse_url" in
    */vnc.html|*/vnc.html\?*)
      printf "%s\n" "$browse_url"
      ;;
    *\?*)
      printf "%s/vnc.html?autoconnect=1\n" "${browse_url%%\?*}"
      ;;
    *)
      printf "%s/vnc.html?autoconnect=1\n" "${browse_url%/}"
      ;;
  esac
}

require_clean_pushed_git_state() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "run this from the vibe-os git checkout so the launcher can prove it will use pushed code"

  local dirty
  dirty="$(git status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"
  if [ -n "$dirty" ]; then
    {
      echo "local git working tree is dirty; refusing before touching Codespaces."
      echo "Codespaces runs pushed git state, not local uncommitted files."
      echo "Commit/push or stash these paths first:"
      printf "%s\n" "$dirty" | sed -n '1,12s/^/  /p'
    } >&2
    exit 1
  fi

  local branch
  branch="$(current_ref)"
  if [ -z "$branch" ] || [ "$REF" != "$branch" ]; then
    return 0
  fi

  local upstream
  upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)" || {
    die "current branch '$branch' has no upstream; push it before using Codespaces as current-head proof"
  }

  local counts behind ahead
  counts="$(git rev-list --left-right --count "$upstream...HEAD" 2>/dev/null)" || {
    die "could not compare current branch '$branch' with upstream '$upstream'"
  }
  read -r behind ahead <<EOF_COUNTS
$counts
EOF_COUNTS
  if [ "${behind:-0}" != "0" ] || [ "${ahead:-0}" != "0" ]; then
    die "current branch '$branch' differs from upstream '$upstream' (ahead=${ahead:-?} behind=${behind:-?}); push/sync it before launching Codespaces"
  fi
}

print_preflight_summary() {
  echo "play-now Codespaces preflight OK"
  echo "repo: $REPO"
  echo "ref: $REF"
  if [ -n "$CODESPACE_NAME" ]; then
    echo "codespace: reuse $CODESPACE_NAME"
  else
    echo "codespace: create $DISPLAY_NAME"
  fi
  echo "machine: ${CODESPACE_MACHINE:-default}"
  echo "idle timeout: $IDLE_TIMEOUT"
  echo "retention period: $RETENTION_PERIOD"
  echo "noVNC port: $NOVNC_PORT (private)"
  echo "browser open: $OPEN_BROWSER"
  echo "git state: clean and pushed for the selected current branch"
  echo "local artifact transfer: none (no WADs, disk images, pixels, raw audio, or logs copied to the Mac)"
  echo "remote preflight command: ./tools/play_now_remote.sh --preflight"
  echo "remote start command: NOVNC_PORT=$NOVNC_PORT nohup ./tools/play_now_remote.sh"
  echo "dry-run: Codespace was not created or modified"
  echo "next: run without --dry-run when you are ready to start the disposable remote play session"
}

remote_start_payload() {
  cat <<'REMOTE'
set -euo pipefail

repo_dir="${VIBE_CODESPACE_REPO_DIR:-}"
if [ -z "$repo_dir" ]; then
  for candidate in /workspaces/*; do
    if [ -e "$candidate/.git" ]; then
      repo_dir="$candidate"
      break
    fi
  done
fi
[ -n "$repo_dir" ] || { echo "could not find repo checkout under /workspaces" >&2; exit 1; }
cd "$repo_dir"

if [ -n "${VIBE_PLAY_REF:-}" ]; then
  git fetch --depth=1 origin "$VIBE_PLAY_REF" >/tmp/vibe-os-play-now-fetch.log 2>&1 || {
    cat /tmp/vibe-os-play-now-fetch.log >&2
    exit 1
  }
  git checkout --detach FETCH_HEAD
  echo "remote play ref: $(git rev-parse --short HEAD)"
fi

./tools/play_now_remote.sh --preflight

pid_file=/tmp/vibe-os-play-now.pid
log_file=/tmp/vibe-os-play-now.log
if [ -s "$pid_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
  echo "vibe-os play-now already running in this Codespace: pid=$(cat "$pid_file")"
else
  rm -f "$pid_file" "$log_file"
  nohup ./tools/play_now_remote.sh >"$log_file" 2>&1 &
  echo "$!" >"$pid_file"
  echo "vibe-os play-now started in this Codespace: pid=$(cat "$pid_file")"
fi
echo "remote play log: $log_file"
REMOTE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      [ "$#" -ge 2 ] || die "--repo requires OWNER/REPO"
      REPO="$2"
      shift
      ;;
    --ref|--branch)
      [ "$#" -ge 2 ] || die "--ref requires a branch or ref"
      REF="$2"
      shift
      ;;
    --codespace)
      [ "$#" -ge 2 ] || die "--codespace requires a Codespace name"
      CODESPACE_NAME="$2"
      shift
      ;;
    --display-name)
      [ "$#" -ge 2 ] || die "--display-name requires a value"
      DISPLAY_NAME="$2"
      shift
      ;;
    --machine)
      [ "$#" -ge 2 ] || die "--machine requires a value"
      CODESPACE_MACHINE="$2"
      shift
      ;;
    --idle-timeout)
      [ "$#" -ge 2 ] || die "--idle-timeout requires a value"
      IDLE_TIMEOUT="$2"
      shift
      ;;
    --retention-period)
      [ "$#" -ge 2 ] || die "--retention-period requires a value"
      RETENTION_PERIOD="$2"
      shift
      ;;
    --preflight|--dry-run)
      RUN_PREFLIGHT_ONLY=1
      ;;
    --no-open)
      OPEN_BROWSER=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
  shift
done

require_tool gh
require_tool git
require_gh_auth
validate_novnc_port

if [ -z "$REPO" ]; then
  REPO="$(current_repo)"
fi
[ -n "$REPO" ] || die "could not infer repo; pass --repo OWNER/REPO"

if [ -z "$REF" ]; then
  REF="$(current_ref)"
fi
[ -n "$REF" ] || REF="main"

require_clean_pushed_git_state

if [ -z "$CODESPACE_NAME" ] && [ -z "$DISPLAY_NAME" ]; then
  ref_part="$(sanitize_display_part "$REF")"
  DISPLAY_NAME="vibe-os-play-${ref_part}-$(date -u +%Y%m%d%H%M%S)"
fi

if [ "$RUN_PREFLIGHT_ONLY" = "1" ]; then
  print_preflight_summary
  exit 0
fi

if [ -z "$CODESPACE_NAME" ]; then
  echo "Creating disposable Codespace '$DISPLAY_NAME' for $REPO@$REF"
  echo "Running: gh codespace create --repo \"$REPO\" --branch \"$REF\" --devcontainer-path \".devcontainer/devcontainer.json\""
  create_args=(
    codespace create
    --repo "$REPO"
    --branch "$REF"
    --devcontainer-path ".devcontainer/devcontainer.json"
    --display-name "$DISPLAY_NAME"
    --idle-timeout "$IDLE_TIMEOUT"
    --retention-period "$RETENTION_PERIOD"
    --default-permissions
    --status
  )
  if [ -n "$CODESPACE_MACHINE" ]; then
    create_args+=(--machine "$CODESPACE_MACHINE")
  fi
  gh "${create_args[@]}"

  CODESPACE_NAME="$(
    gh codespace list \
      --repo "$REPO" \
      --json name,displayName \
      --jq ".[] | select(.displayName == \"$DISPLAY_NAME\") | .name" \
      | head -n 1
  )"
  [ -n "$CODESPACE_NAME" ] || die "created Codespace was not found by display name '$DISPLAY_NAME'"
else
  echo "Reusing Codespace '$CODESPACE_NAME'"
fi

echo "Starting vibe-os Doom inside Codespace '$CODESPACE_NAME'"
payload="$(remote_start_payload)"
gh codespace ssh -c "$CODESPACE_NAME" -- env VIBE_PLAY_REF="$REF" NOVNC_PORT="$NOVNC_PORT" bash -lc "$payload"

novnc_browse_url=""
echo "Waiting for noVNC port $NOVNC_PORT"
for _ in 1 2 3 4 5 6 7 8 9 10; do
  novnc_browse_url="$(
    gh codespace ports \
      -c "$CODESPACE_NAME" \
      --json sourcePort,browseUrl \
      --jq ".[] | select(.sourcePort == $NOVNC_PORT) | .browseUrl" \
      | head -n 1
  )"
  if [ -n "$novnc_browse_url" ]; then
    echo "Marking noVNC port $NOVNC_PORT private"
    gh codespace ports visibility "$NOVNC_PORT:private" -c "$CODESPACE_NAME" >/dev/null || {
      die "could not mark noVNC port $NOVNC_PORT private; check the Codespaces Ports tab before opening the forwarded URL"
    }
    echo "noVNC port $NOVNC_PORT is private"
    break
  fi
  sleep 2
done

echo
echo "Codespace: $CODESPACE_NAME"
echo "Remote log: gh codespace ssh -c \"$CODESPACE_NAME\" -- tail -f /tmp/vibe-os-play-now.log"
echo "Delete when done: gh codespace delete -c \"$CODESPACE_NAME\" --force"

if [ -n "$novnc_browse_url" ]; then
  novnc_url="$(novnc_url_from_browse_url "$novnc_browse_url")"
  echo "Open Doom noVNC: $novnc_url"
  echo "Controls: arrows move/turn, Ctrl fires, Space uses, Escape opens menu."
  if [ "$OPEN_BROWSER" = "1" ] && [ "$(uname -s)" = "Darwin" ] && command -v open >/dev/null 2>&1; then
    open "$novnc_url" || true
  fi
else
  echo "noVNC browse URL was not ready yet."
  echo "List ports: gh codespace ports -c \"$CODESPACE_NAME\""
  echo "Fallback tunnel: gh codespace ports forward $NOVNC_PORT:$NOVNC_PORT -c \"$CODESPACE_NAME\""
  echo "Then open: http://127.0.0.1:$NOVNC_PORT/vnc.html?autoconnect=1"
fi
