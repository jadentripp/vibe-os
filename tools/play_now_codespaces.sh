#!/usr/bin/env bash
set -euo pipefail

REPO="${VIBE_REPO:-}"
REF="${VIBE_REF:-}"
REPO_EXPLICIT=0
REF_EXPLICIT=0
CODESPACE_NAME="${CODESPACE_NAME:-}"
DISPLAY_NAME="${DISPLAY_NAME:-}"
CODESPACE_MACHINE="${CODESPACE_MACHINE:-}"
IDLE_TIMEOUT="${IDLE_TIMEOUT:-30m}"
RETENTION_PERIOD="${RETENTION_PERIOD:-1h}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
OPEN_BROWSER="${OPEN_BROWSER:-1}"
CODESPACES_PORT_WAIT_SECONDS="${CODESPACES_PORT_WAIT_SECONDS:-300}"
CODESPACES_PORT_WAIT_INTERVAL="${CODESPACES_PORT_WAIT_INTERVAL:-5}"
CODESPACES_SSH_ATTEMPTS="${CODESPACES_SSH_ATTEMPTS:-3}"
CODESPACES_SSH_RETRY_SECONDS="${CODESPACES_SSH_RETRY_SECONDS:-10}"
CODESPACES_MIN_INTERACTIVE_CPUS="${CODESPACES_MIN_INTERACTIVE_CPUS:-4}"
MAX_DISPLAY_NAME_LENGTH=48
RUN_PREFLIGHT_ONLY=0
PRINT_WEB_URL_ONLY=0
GIT_STATE_SUMMARY=""
REPO_DATABASE_ID=""
MACHINE_SELECTION_SUMMARY=""
REMOTE_PLAY_PATHS=(
  ".devcontainer/devcontainer.json"
  ".devcontainer/Dockerfile"
  ".devcontainer/play-now-welcome.sh"
  "Makefile"
  "tools/play_now_remote.sh"
  "tools/play_now_cloud_shell.sh"
  "tools/check_play_now_remote.py"
  "tools/prepare_shareware_wad.py"
  "tools/make_wad_image.py"
)

if [ -n "${VIBE_REPO:-}" ]; then
  REPO_EXPLICIT=1
fi
if [ -n "${VIBE_REF:-}" ]; then
  REF_EXPLICIT=1
fi

usage() {
  cat <<'EOF'
Usage: tools/play_now_codespaces.sh [options]

Create or reuse a disposable GitHub Codespace, start vibe-os Doom there through
tools/play_now_remote.sh, make noVNC private, and print the browser URL.

This script is safe to run on the Mac: it uses gh to control Codespaces only.
QEMU, the shareware WAD, disk image, pixels, and raw audio stay inside the
Codespace. The selected GitHub branch must already contain the devcontainer
and remote play scripts; local uncommitted launcher edits are never copied.

Options:
  --repo OWNER/REPO       Repository to create the Codespace from.
                          Default: gh repo view for the current checkout.
  --ref BRANCH            Branch/ref to use. Default: current git branch.
  --codespace NAME        Reuse an existing Codespace instead of creating one.
  --display-name NAME     Display name for a newly created Codespace.
  --machine NAME          Optional Codespaces machine type. If omitted for a
                          new CLI-created Codespace, prefer the smallest
                          available 4+ CPU machine for interactive play.
  --idle-timeout VALUE    Codespaces idle timeout. Default: 30m.
  --retention-period VAL  Codespaces retention after stop. Default: 1h.
  --preflight, --dry-run  Check gh/git/ref/port safety and print the plan
                          without creating, starting, or modifying a Codespace.
  --web-url               Print a browser-only Codespaces creation URL plus
                          the in-Codespace play command, then exit. With
                          --repo/--ref this does not require gh auth or the
                          gh Codespaces API scope.
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

gh_auth_available() {
  command -v gh >/dev/null 2>&1 && gh auth status -h github.com >/dev/null 2>&1
}

require_gh_codespaces_access() {
  gh api -H "Accept: application/vnd.github+json" "/user/codespaces?per_page=1" >/dev/null 2>&1 || {
    {
      echo "GitHub CLI token cannot access Codespaces."
      echo
      echo "Option A, fix local gh and rerun:"
      echo "  gh auth refresh -h github.com -s codespace"
      echo
      echo "Option B, no local gh Codespaces scope needed: create it in the browser, then run the remote play command inside the Codespace."
      print_web_fallback_hint
    } >&2
    exit 1
  }
}

sanitize_remote_error() {
  sed -E \
    -e 's/((GH|GITHUB|CODESPACES|VSCODE|ACTIONS|NPM|NODE_AUTH|DOCKER|AWS|AZURE|GOOGLE|OPENAI|ANTHROPIC|GEMINI|HF|HUGGINGFACE|VIBE)[A-Z0-9_]*_(TOKEN|KEY|SECRET|PASSWORD|CREDENTIAL|AUTH)[A-Z0-9_]*=)[^[:space:]]+/\1[redacted]/g' \
    -e 's/((GH|GITHUB|CODESPACES|VSCODE|ACTIONS|NPM|NODE_AUTH|DOCKER|AWS|AZURE|GOOGLE|OPENAI|ANTHROPIC|GEMINI|HF|HUGGINGFACE|VIBE)[A-Z0-9_]*=)(gh[pousr]_[A-Za-z0-9_]+)/\1[redacted]/g' \
    -e 's/(Authorization: *(Bearer|token) +)[^[:space:]]+/\1[redacted]/Ig' \
    -e 's/(access_token=)[^&[:space:]]+/\1[redacted]/Ig'
}

ssh_permission_error() {
  grep -Eiq \
    'Permission denied|publickey|Could not resolve hostname|connection reset|connection refused|failed to connect|The codespace is not running|codespace.*starting|codespace.*not ready' \
    "$1"
}

print_codespace_cleanup_commands() {
  echo "Remote log: gh codespace ssh -c \"$CODESPACE_NAME\" -- tail -f /tmp/vibe-os-play-now.log"
  echo "Diagnostics: gh codespace ssh -c \"$CODESPACE_NAME\" -- /tmp/vibe-os-play-now-diagnostics.sh"
  echo "List ports: gh codespace ports -c \"$CODESPACE_NAME\""
  echo "Inspect machine: gh api /user/codespaces/$CODESPACE_NAME --jq .machine"
  echo "Stop play-now: gh codespace ssh -c \"$CODESPACE_NAME\" -- 'if [ -s /tmp/vibe-os-play-now.pid ]; then kill \"\$(cat /tmp/vibe-os-play-now.pid)\"; fi'"
  echo "Delete when done: gh codespace delete -c \"$CODESPACE_NAME\" --force"
  echo "Browser cleanup: GitHub repo > Code > Codespaces > ... > Delete"
}

verify_remote_play_payload() {
  local path
  local payload_tmp
  local remote_url
  local missing=()

  payload_tmp="$(mktemp -d "${TMPDIR:-/tmp}/vibe-os-play-now-payload.XXXXXX")" || die "could not create temporary payload check directory"
  remote_url="https://github.com/${REPO}.git"

  (
    cd "$payload_tmp"
    git init -q
    git remote add origin "$remote_url"
    GIT_TERMINAL_PROMPT=0 git fetch --depth=1 --filter=blob:none origin "refs/heads/$REF" >/dev/null 2>&1
  ) || {
    rm -rf "$payload_tmp"
    die "could not fetch GitHub branch '$REF' from '$REPO' for play-now payload verification"
  }

  for path in "${REMOTE_PLAY_PATHS[@]}"; do
    if ! (cd "$payload_tmp" && git cat-file -e "FETCH_HEAD:$path" >/dev/null 2>&1); then
      missing+=("$path")
    fi
  done

  rm -rf "$payload_tmp"
  if [ "${#missing[@]}" -gt 0 ]; then
    die "GitHub branch '$REF' in '$REPO' is missing required play-now path '${missing[0]}'; push the devcontainer, remote play launcher, and WAD prep helpers before starting Codespaces"
  fi
}
validate_repo_slug() {
  local repo="$1"

  case "$repo" in
    */*)
      ;;
    *)
      die "repo must be OWNER/REPO, got '$repo'"
      ;;
  esac
  case "$repo" in
    *$'\n'*|*$'\r'*|*' '*|*'	'*|*://*|/*|*/|*/*/*)
      die "repo must be a GitHub OWNER/REPO slug, got '$repo'"
      ;;
  esac
  case "$repo" in
    *[!A-Za-z0-9_./-]*)
      die "repo contains unsupported characters: '$repo'"
      ;;
  esac
}

validate_ref_name() {
  local ref="$1"

  [ -n "$ref" ] || die "ref must not be empty"
  case "$ref" in
    *$'\n'*|*$'\r'*|*' '*|*'	'*|-*|refs/*)
      die "ref must be a branch name without spaces/control characters, got '$ref'"
      ;;
  esac
  git check-ref-format --branch "$ref" >/dev/null 2>&1 || {
    die "ref must be a valid Git branch name, got '$ref'"
  }
}

verify_github_remote_ref() {
  validate_repo_slug "$REPO"
  validate_ref_name "$REF"

  local remote_url
  local refs
  local expected_ref

  remote_url="https://github.com/${REPO}.git"
  expected_ref="refs/heads/$REF"
  refs="$(
    GIT_TERMINAL_PROMPT=0 git ls-remote --heads "$remote_url" "$REF" 2>/dev/null || true
  )"
  if ! printf "%s\n" "$refs" | awk '{print $2}' | grep -Fx "$expected_ref" >/dev/null 2>&1; then
    die "GitHub branch '$REF' was not found in '$REPO'; push it first or pass a branch that exists remotely"
  fi

  REPO_DATABASE_ID=""
  if gh_auth_available; then
    REPO_DATABASE_ID="$(
      gh api -H "Accept: application/vnd.github+json" "/repos/$REPO" --jq .id 2>/dev/null || true
    )"
    case "$REPO_DATABASE_ID" in
      ''|*[!0-9]*)
        REPO_DATABASE_ID=""
        ;;
    esac
  fi
}

urlencode() {
  local raw="$1"
  local i
  local char
  local encoded
  local out=""

  LC_CTYPE=C
  for ((i = 0; i < ${#raw}; i++)); do
    char="${raw:i:1}"
    case "$char" in
      [A-Za-z0-9.~_-])
        out+="$char"
        ;;
      *)
        printf -v encoded '%%%02X' "'$char"
        out+="$encoded"
        ;;
    esac
  done
  printf "%s" "$out"
}

codespaces_create_url() {
  local encoded_ref
  encoded_ref="$(urlencode "$REF")"

  if [ -n "$REPO_DATABASE_ID" ]; then
    printf "https://github.com/codespaces/new?hide_repo_select=true&repo=%s&ref=%s&devcontainer_path=.devcontainer%%2Fdevcontainer.json\n" \
      "$REPO_DATABASE_ID" \
      "$encoded_ref"
  else
    printf "https://github.com/codespaces/new\n"
  fi
}

print_inside_codespace_commands() {
  cat <<EOF
Inside the Codespace terminal:
  ./tools/play_now_remote.sh --preflight --require-novnc
  ./tools/play_now_remote.sh --require-novnc

Then open the forwarded private port $NOVNC_PORT URL with this path:
  /vnc.html?autoconnect=1
EOF
}

print_web_fallback_hint() {
  echo "Browser Codespaces URL:"
  echo "  $(codespaces_create_url)"
  echo
  echo "Repository/ref:"
  echo "  $REPO@$REF"
  echo
  print_inside_codespace_commands
}

sanitize_display_part() {
  printf "%s" "$1" | tr '/_.' '---' | tr -cd 'A-Za-z0-9-'
}

current_repo() {
  local url

  url="$(git remote get-url origin 2>/dev/null || true)"
  case "$url" in
    https://github.com/*.git)
      url="${url#https://github.com/}"
      printf "%s\n" "${url%.git}"
      ;;
    git@github.com:*.git)
      url="${url#git@github.com:}"
      printf "%s\n" "${url%.git}"
      ;;
    *)
      if gh_auth_available; then
        gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true
      fi
      ;;
  esac
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

validate_positive_integer() {
  local name="$1"
  local value="$2"

  case "$value" in
    ''|*[!0-9]*)
      die "$name must be a positive integer, got '$value'"
      ;;
  esac
  if [ "$value" -lt 1 ]; then
    die "$name must be a positive integer, got '$value'"
  fi
}

select_preferred_codespace_machine() {
  local api_path
  local selected
  local cpus
  local machine_name
  local display_name

  if [ -n "$CODESPACE_MACHINE" ]; then
    MACHINE_SELECTION_SUMMARY="explicit machine selected by --machine/CODESPACE_MACHINE"
    return 0
  fi

  if [ -n "$CODESPACE_NAME" ]; then
    MACHINE_SELECTION_SUMMARY="reusing existing Codespace; inspect/change its machine before play if it is still 2-core"
    return 0
  fi

  api_path="/repos/$REPO/codespaces/machines?ref=$(urlencode "$REF")"
  selected="$(
    gh api -H "Accept: application/vnd.github+json" "$api_path" \
      --jq ".machines[] | select((.cpus // 0) >= $CODESPACES_MIN_INTERACTIVE_CPUS) | [.cpus, .name, .display_name] | @tsv" \
      2>/dev/null \
      | sort -n \
      | head -n 1
  )" || true

  if [ -n "$selected" ]; then
    IFS=$'\t' read -r cpus machine_name display_name <<EOF_MACHINE
$selected
EOF_MACHINE
    CODESPACE_MACHINE="$machine_name"
    MACHINE_SELECTION_SUMMARY="selected $machine_name (${display_name:-${cpus} CPUs}) for smoother interactive play"
  else
    MACHINE_SELECTION_SUMMARY="could not find an available ${CODESPACES_MIN_INTERACTIVE_CPUS}+ CPU machine; using GitHub default and expect possible 2-core stutter"
  fi
}

validate_display_name() {
  local name="$1"

  [ -n "$name" ] || die "Codespaces display name must not be empty"
  case "$name" in
    *$'\n'*|*$'\r'*)
      die "Codespaces display name must be a single line"
      ;;
    *\"*|*\\*)
      die "Codespaces display name must not contain quotes or backslashes"
      ;;
  esac
  if [ "${#name}" -gt "$MAX_DISPLAY_NAME_LENGTH" ]; then
    die "Codespaces display name must be $MAX_DISPLAY_NAME_LENGTH characters or fewer, got ${#name}: '$name'"
  fi
}

validate_codespace_name() {
  local name="$1"

  [ -n "$name" ] || die "Codespace name must not be empty"
  case "$name" in
    *$'\n'*|*$'\r'*|*' '*|*'	'*)
      die "Codespace name must be a single token, got '$name'"
      ;;
  esac
}

default_display_name() {
  local ref="$1"
  local prefix="vibe-play"
  local timestamp
  local ref_part
  local max_ref_len

  timestamp="$(date -u +%Y%m%d%H%M%S)"
  ref_part="$(sanitize_display_part "$ref")"
  [ -n "$ref_part" ] || ref_part="ref"

  max_ref_len=$((MAX_DISPLAY_NAME_LENGTH - ${#prefix} - ${#timestamp} - 2))
  if [ "$max_ref_len" -lt 3 ]; then
    die "internal display-name budget is too small"
  fi
  if [ "${#ref_part}" -gt "$max_ref_len" ]; then
    ref_part="${ref_part:0:$max_ref_len}"
  fi

  printf "%s-%s-%s\n" "$prefix" "$ref_part" "$timestamp"
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
  echo "machine selection: $MACHINE_SELECTION_SUMMARY"
  echo "noVNC wait timeout: ${CODESPACES_PORT_WAIT_SECONDS}s"
  echo "SSH start attempts: $CODESPACES_SSH_ATTEMPTS"
  echo "browser open: $OPEN_BROWSER"
  echo "GitHub Codespaces API: accessible"
  echo "GitHub repo/ref: verified"
  echo "remote play payload: verified on selected ref"
  echo "git state: $GIT_STATE_SUMMARY"
  echo "local artifact transfer: none (no WADs, disk images, pixels, raw audio, or logs copied to the Mac)"
  echo "performance caveat: 2-core Codespaces can play Doom but may stutter during builds or noVNC streaming"
  echo "performance preference: use the selected 4+ CPU machine for interactive Doom when available"
  echo "remote preflight command: ./tools/play_now_remote.sh --preflight --require-novnc"
  echo "remote start command: NOVNC_PORT=$NOVNC_PORT nohup ./tools/play_now_remote.sh --require-novnc"
  echo "dry-run: Codespace was not created or modified"
  echo "next: run without --dry-run when you are ready to start the disposable remote play session"
}

print_web_url_summary() {
  echo "play-now browser Codespaces path"
  echo "repo: $REPO"
  echo "ref: $REF"
  echo "noVNC port: $NOVNC_PORT (private)"
  echo "GitHub repo/ref: verified"
  echo "remote play payload: verified on selected ref"
  echo "local gh Codespaces API: not required for this browser path"
  echo "local gh auth: optional for this browser path"
  echo "local artifact transfer: none (no WADs, disk images, pixels, raw audio, or logs copied to the Mac)"
  echo "machine guidance: choose a 4-core+ Codespaces machine in the browser when available; GitHub defaults to the lowest valid machine"
  echo "Codespaces create URL:"
  echo "$(codespaces_create_url)"
  echo
  print_inside_codespace_commands
  echo "dry-run: Codespace was not created or modified"
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
    echo "remote git fetch failed for the selected play ref; sanitized recent output:" >&2
    sed -E \
      -e 's/((GH|GITHUB|CODESPACES|VSCODE|ACTIONS|NPM|NODE_AUTH|DOCKER|AWS|AZURE|GOOGLE|OPENAI|ANTHROPIC|GEMINI|HF|HUGGINGFACE|VIBE)[A-Z0-9_]*_(TOKEN|KEY|SECRET|PASSWORD|CREDENTIAL|AUTH)[A-Z0-9_]*=)[^[:space:]]+/\1[redacted]/g' \
      -e 's/(access_token=)[^&[:space:]]+/\1[redacted]/Ig' \
      /tmp/vibe-os-play-now-fetch.log | tail -n 40 >&2
    exit 1
  }
  git checkout --detach FETCH_HEAD
  echo "remote play ref: $(git rev-parse --short HEAD)"
fi

./tools/play_now_remote.sh --preflight --require-novnc

pid_file=/tmp/vibe-os-play-now.pid
log_file=/tmp/vibe-os-play-now.log
port_file=/tmp/vibe-os-play-now.novnc-port
current_port="${NOVNC_PORT:-6080}"
if [ -s "$pid_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
  existing_port="$(cat "$port_file" 2>/dev/null || true)"
  if [ -z "$existing_port" ]; then
    echo "vibe-os play-now is already running, but its noVNC port is unknown; stop pid $(cat "$pid_file") before relaunching" >&2
    exit 1
  fi
  if [ "$existing_port" != "$current_port" ]; then
    echo "vibe-os play-now is already running with NOVNC_PORT=$existing_port; rerun with that port or stop pid $(cat "$pid_file")" >&2
    exit 1
  fi
  echo "vibe-os play-now already running in this Codespace: pid=$(cat "$pid_file")"
else
  rm -f "$pid_file" "$log_file" "$port_file"
  printf "%s\n" "$current_port" >"$port_file"
  nohup ./tools/play_now_remote.sh --require-novnc >"$log_file" 2>&1 &
  echo "$!" >"$pid_file"
  echo "vibe-os play-now started in this Codespace: pid=$(cat "$pid_file")"
  sleep 2
  if ! kill -0 "$(cat "$pid_file")" 2>/dev/null; then
    echo "vibe-os play-now exited during startup; recent remote log:" >&2
    tail -n 80 "$log_file" >&2 || true
    exit 1
  fi
fi
echo "remote play log: $log_file"
REMOTE
}

run_remote_start() {
  local attempt
  local err_file
  local rc

  err_file="$(mktemp "${TMPDIR:-/tmp}/vibe-os-codespace-ssh.XXXXXX")" || die "could not create temporary SSH log"

  for ((attempt = 1; attempt <= CODESPACES_SSH_ATTEMPTS; attempt++)); do
    : >"$err_file"
    set +e
    remote_start_payload | gh codespace ssh -c "$CODESPACE_NAME" -- env VIBE_PLAY_REF="$REF" NOVNC_PORT="$NOVNC_PORT" bash -s 2> >(sanitize_remote_error | tee "$err_file" >&2)
    rc=$?
    set -e

    if [ "$rc" -eq 0 ]; then
      rm -f "$err_file"
      return 0
    fi

    if [ "$attempt" -lt "$CODESPACES_SSH_ATTEMPTS" ] && ssh_permission_error "$err_file"; then
      echo "Codespace SSH was not ready yet (attempt $attempt/$CODESPACES_SSH_ATTEMPTS); retrying in ${CODESPACES_SSH_RETRY_SECONDS}s." >&2
      echo "If GitHub asks to authorize Codespaces SSH, approve it in the browser and leave this retry running." >&2
      sleep "$CODESPACES_SSH_RETRY_SECONDS"
      continue
    fi

    {
      echo "Could not start play-now over Codespaces SSH after attempt $attempt/$CODESPACES_SSH_ATTEMPTS."
      echo "The remote command is passed over stdin to bash -s; the launcher does not run a shell payload via bash -lc and does not print remote env."
      print_codespace_cleanup_commands
    } >&2
    rm -f "$err_file"
    return "$rc"
  done

  rm -f "$err_file"
  return 1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      [ "$#" -ge 2 ] || die "--repo requires OWNER/REPO"
      REPO="$2"
      REPO_EXPLICIT=1
      shift
      ;;
    --ref|--branch)
      [ "$#" -ge 2 ] || die "--ref requires a branch or ref"
      REF="$2"
      REF_EXPLICIT=1
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
    --web-url|--browser-url|--print-web-url)
      PRINT_WEB_URL_ONLY=1
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

require_tool git
validate_novnc_port
validate_positive_integer CODESPACES_PORT_WAIT_SECONDS "$CODESPACES_PORT_WAIT_SECONDS"
validate_positive_integer CODESPACES_PORT_WAIT_INTERVAL "$CODESPACES_PORT_WAIT_INTERVAL"
validate_positive_integer CODESPACES_SSH_ATTEMPTS "$CODESPACES_SSH_ATTEMPTS"
validate_positive_integer CODESPACES_SSH_RETRY_SECONDS "$CODESPACES_SSH_RETRY_SECONDS"
validate_positive_integer CODESPACES_MIN_INTERACTIVE_CPUS "$CODESPACES_MIN_INTERACTIVE_CPUS"

if [ -z "$REPO" ]; then
  REPO="$(current_repo)"
fi
[ -n "$REPO" ] || die "could not infer repo; pass --repo OWNER/REPO"

if [ -z "$REF" ]; then
  REF="$(current_ref)"
fi
[ -n "$REF" ] || die "could not infer a git branch; pass --ref BRANCH for explicit remote play"

if [ "$REF_EXPLICIT" = "1" ]; then
  GIT_STATE_SUMMARY="explicit GitHub repo/ref selected; local checkout dirt is ignored"
else
  require_clean_pushed_git_state
  GIT_STATE_SUMMARY="clean and pushed for the inferred current branch"
fi

verify_github_remote_ref
verify_remote_play_payload

if [ "$PRINT_WEB_URL_ONLY" = "1" ]; then
  print_web_url_summary
  exit 0
fi

require_tool gh
require_gh_auth
require_gh_codespaces_access
select_preferred_codespace_machine

if [ -z "$CODESPACE_NAME" ] && [ -z "$DISPLAY_NAME" ]; then
  DISPLAY_NAME="$(default_display_name "$REF")"
fi
if [ -n "$DISPLAY_NAME" ]; then
  validate_display_name "$DISPLAY_NAME"
fi
if [ -n "$CODESPACE_NAME" ]; then
  validate_codespace_name "$CODESPACE_NAME"
fi

if [ "$RUN_PREFLIGHT_ONLY" = "1" ]; then
  print_preflight_summary
  exit 0
fi

if [ -z "$CODESPACE_NAME" ]; then
  echo "Creating disposable Codespace '$DISPLAY_NAME' for $REPO@$REF"
  echo "Running: gh codespace create --repo \"$REPO\" --branch \"$REF\" --devcontainer-path \".devcontainer/devcontainer.json\""
  echo "Machine selection: $MACHINE_SELECTION_SUMMARY"
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
run_remote_start || exit $?

novnc_browse_url=""
echo "Waiting up to ${CODESPACES_PORT_WAIT_SECONDS}s for noVNC port $NOVNC_PORT"
wait_started=$SECONDS
while [ $((SECONDS - wait_started)) -lt "$CODESPACES_PORT_WAIT_SECONDS" ]; do
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
  sleep "$CODESPACES_PORT_WAIT_INTERVAL"
done

echo
echo "Codespace: $CODESPACE_NAME"
print_codespace_cleanup_commands

if [ -z "$novnc_browse_url" ]; then
  echo "noVNC browse URL was not ready yet."
  echo "List ports: gh codespace ports -c \"$CODESPACE_NAME\""
  echo "Fallback tunnel: gh codespace ports forward $NOVNC_PORT:$NOVNC_PORT -c \"$CODESPACE_NAME\""
  echo "Then open: http://127.0.0.1:$NOVNC_PORT/vnc.html?autoconnect=1"
  die "noVNC port $NOVNC_PORT did not become available before the timeout; inspect the remote log above"
fi

novnc_url="$(novnc_url_from_browse_url "$novnc_browse_url")"
echo "Open Doom noVNC: $novnc_url"
echo "Controls: arrows move/turn, Ctrl fires, Space uses, Escape opens menu."
echo "Performance note: 2-core Codespaces can play Doom, but noVNC may stutter during builds or CPU contention; 4+ CPUs are preferred for interactive play."
echo "Slowdown check: run the Diagnostics command above; it prints only safe process/load and OS status-log lines."
if [ "$OPEN_BROWSER" = "1" ] && [ "$(uname -s)" = "Darwin" ] && command -v open >/dev/null 2>&1; then
  open "$novnc_url" || true
fi
