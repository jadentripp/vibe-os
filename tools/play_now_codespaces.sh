#!/usr/bin/env bash
set -euo pipefail

REPO="${VIBE_REPO:-}"
REF="${VIBE_REF:-}"
PLAY_MODE="${VIBE_PLAY_MODE:-${VIBE_PLAY_KIND:-pi4}}"
REPO_EXPLICIT=0
REF_EXPLICIT=0
CODESPACE_NAME="${CODESPACE_NAME:-}"
DISPLAY_NAME="${DISPLAY_NAME:-}"
CODESPACE_MACHINE="${CODESPACE_MACHINE:-}"
IDLE_TIMEOUT="${IDLE_TIMEOUT:-30m}"
RETENTION_PERIOD="${RETENTION_PERIOD:-1h}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
NOVNC_VNC_PATH="${NOVNC_VNC_PATH:-/vnc.html?autoconnect=1&resize=scale}"
OPEN_BROWSER="${OPEN_BROWSER:-1}"
CODESPACES_PORT_WAIT_SECONDS="${CODESPACES_PORT_WAIT_SECONDS:-300}"
CODESPACES_PORT_WAIT_INTERVAL="${CODESPACES_PORT_WAIT_INTERVAL:-5}"
CODESPACES_READY_WAIT_SECONDS="${CODESPACES_READY_WAIT_SECONDS:-420}"
CODESPACES_READY_WAIT_INTERVAL="${CODESPACES_READY_WAIT_INTERVAL:-5}"
CODESPACES_SSH_ATTEMPTS="${CODESPACES_SSH_ATTEMPTS:-18}"
CODESPACES_SSH_RETRY_SECONDS="${CODESPACES_SSH_RETRY_SECONDS:-10}"
CODESPACES_MIN_INTERACTIVE_CPUS="${CODESPACES_MIN_INTERACTIVE_CPUS:-4}"
PI4_REMOTE_QEMU_INPUT_ARGS="-M raspi4b,usb=on -device usb-kbd -device usb-mouse"
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
  "tools/prepare_game_assets.sh"
  "tools/link_elf32.c"
  "tools/make_wad_image.c"
  "tools/pi4_qemu_command.c"
  "tools/vibe_status_check.c"
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

Create or reuse a disposable GitHub Codespace, start vibe-os there through
tools/play_now_remote.sh, make noVNC private, and print/open the browser URL.

This script is safe to run on the Mac: it uses gh to control Codespaces only.
QEMU, WAD/PAK inputs, disk images, pixels, and raw audio stay inside the
Codespace. The selected GitHub branch must already contain the devcontainer
and remote play scripts; local uncommitted launcher edits are never copied.

Options:
  --repo OWNER/REPO       Repository to create the Codespace from.
                          Default: gh repo view for the current checkout.
  --ref BRANCH            Branch/ref to use. Default: current git branch.
  --pi4                   Boot the Pi 4 hardware-equivalent real-assets
                          desktop over noVNC. Default.
                          The remote launcher prints the exact image/kernel
                          paths, hashes, and visible QEMU argv before launch.
  --x86                   Boot the legacy x86 Doom image over noVNC.
  --mode MODE             MODE may be x86 or pi4.
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

Environment:
  NOVNC_VNC_PATH='/vnc.html?autoconnect=1&resize=scale'
                          noVNC page/options. The default autoconnects and
                          scales the Pi desktop to the browser window.
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
    -e 's/(gh[pousr]_[A-Za-z0-9_]+)/[redacted]/g' \
    -e 's/(^|[^A-Z0-9])([A-Z0-9]{4}-[A-Z0-9]{4})([^A-Z0-9]|$)/\1[redacted-code]\3/g' \
    -e 's/(Authorization: *(Bearer|token) +)[^[:space:]]+/\1[redacted]/Ig' \
    -e 's/((access_token|token|signature|X-Amz-Signature|X-Amz-Credential)=)[^&[:space:]]+/\1[redacted]/Ig'
}

ssh_permission_error() {
  grep -Eiq \
    'Permission denied|publickey|Could not resolve hostname|connection reset|connection refused|failed to connect|The codespace is not running|codespace.*starting|codespace.*not ready' \
    "$1" || grep -Eiq \
    'failed to poll state changes|failed to start SSH server|ssh server details|get post create output|run command: exit status 255' \
    "$1"
}

print_codespace_cleanup_commands() {
  echo "Diagnostics: gh codespace ssh -c \"$CODESPACE_NAME\" -- /tmp/vibe-os-play-now-diagnostics.sh"
  echo "Diagnostics JSON: gh codespace ssh -c \"$CODESPACE_NAME\" -- /tmp/vibe-os-play-now-diagnostics.sh --json"
  echo "Diagnostics watch: gh codespace ssh -c \"$CODESPACE_NAME\" -- /tmp/vibe-os-play-now-diagnostics.sh --watch"
  echo "Startup log tail: gh codespace ssh -c \"$CODESPACE_NAME\" -- 'tail -n 120 /tmp/vibe-os-play-now.log'"
  echo "Status: gh codespace ssh -c \"$CODESPACE_NAME\" -- /tmp/vibe-os-play-now-diagnostics.sh"
  echo "List ports: gh codespace ports -c \"$CODESPACE_NAME\""
  echo "Inspect machine: gh api /user/codespaces/$CODESPACE_NAME --jq .machine"
  echo "List machine choices: gh api \"/repos/$REPO/codespaces/machines?ref=$(urlencode "$REF")\" --jq '.machines[] | [.cpus, .name, .display_name] | @tsv'"
  echo "Resize for smoother play: gh codespace edit -c \"$CODESPACE_NAME\" --machine <4-plus-cpu-machine-name>"
  echo "Stop play-now: gh codespace ssh -c \"$CODESPACE_NAME\" -- /tmp/vibe-os-play-now-stop.sh"
  echo "Fallback stop: gh codespace ssh -c \"$CODESPACE_NAME\" -- 'if [ -s /tmp/vibe-os-play-now.pid ]; then kill \"\$(cat /tmp/vibe-os-play-now.pid)\"; fi'"
  echo "Delete when done: gh codespace delete -c \"$CODESPACE_NAME\" --force"
  echo "Browser cleanup: GitHub repo > Code > Codespaces > ... > Delete"
  echo "Artifact hygiene: leave WADs, PAKs, disk images, screenshots, raw audio, and VM logs inside the disposable Codespace."
}

verify_remote_play_ref() {
  local path
  local ref_tmp
  local remote_url
  local missing=()

  ref_tmp="$(mktemp -d "${TMPDIR:-/tmp}/vibe-os-play-now-ref.XXXXXX")" || die "could not create temporary ref check directory"
  remote_url="https://github.com/${REPO}.git"

  (
    cd "$ref_tmp"
    git init -q
    git remote add origin "$remote_url"
    GIT_TERMINAL_PROMPT=0 git fetch --depth=1 --filter=blob:none origin "refs/heads/$REF" >/dev/null 2>&1
  ) || {
    rm -rf "$ref_tmp"
    die "could not fetch GitHub branch '$REF' from '$REPO' for play-now ref verification"
  }

  for path in "${REMOTE_PLAY_PATHS[@]}"; do
    if ! (cd "$ref_tmp" && git cat-file -e "FETCH_HEAD:$path" >/dev/null 2>&1); then
      missing+=("$path")
    fi
  done

  rm -rf "$ref_tmp"
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
  ./tools/play_now_remote.sh --$PLAY_MODE --preflight --require-novnc
  ./tools/play_now_remote.sh --$PLAY_MODE --require-novnc

For Pi mode, the start command prepares the real WAD/PAK desktop image, then
prints the exact PI4_REAL_ASSET_IMAGE path, handoff file, kernel hash, and
visible-play QEMU argv before launch. The QEMU input path is:
  $PI4_REMOTE_QEMU_INPUT_ARGS
The noVNC canvas is scaled; use browser fullscreen for the zoomed play surface.
Click the canvas once, then press 1/click Doom or press 2/click Quake. That
visible session is not a proof gate.

Then open the forwarded private port $NOVNC_PORT URL with this path:
  $NOVNC_VNC_PATH
EOF
}

print_pi4_codespaces_handoff() {
  echo "Pi 4 prepared image: remote launcher builds and boots PI4_REAL_ASSET_IMAGE, then prints its path and sha256."
  echo "Pi 4 noVNC view: open the private URL in browser fullscreen; resize=scale keeps the guest desktop fitted to the window."
  echo "Pi 4 focus: click the noVNC canvas once before keyboard or mouse input."
  echo "Pi 4 launcher: press 1/click Doom or press 2/click Quake inside vibe-os."
  echo "Pi 4 QEMU input args: $PI4_REMOTE_QEMU_INPUT_ARGS"
}

print_visible_play_controls() {
  cat <<'EOF'
Visible play controls:
  noVNC focus: click the scaled canvas once before typing or using the mouse.
  Launcher: 1/click Doom, 2/click Quake, or W/S plus Enter from inside vibe-os.
  Pi Doom: W/Up forward, S/Down back, A/Left and D/Right turn, Space/Enter/Ctrl or left mouse fires.
  Pi Quake: WASD moves, arrows look, Ctrl/Enter or left mouse fires, Space/Shift jumps, Escape toggles menu.
  x86 Doom: arrows move/turn, Ctrl fires, Space uses, Escape opens menu.
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

validate_novnc_path() {
  case "$NOVNC_VNC_PATH" in
    *$'\n'*|*$'\r'*|*' '*|*'	'*|*\'*)
      die "NOVNC_VNC_PATH must not contain whitespace or quotes, got '$NOVNC_VNC_PATH'"
      ;;
  esac
  case "$NOVNC_VNC_PATH" in
    /vnc.html|/vnc.html\?*)
      ;;
    /*)
      die "NOVNC_VNC_PATH must point at /vnc.html with noVNC options, got '$NOVNC_VNC_PATH'"
      ;;
    *)
      die "NOVNC_VNC_PATH must start with /vnc.html, got '$NOVNC_VNC_PATH'"
      ;;
  esac
}

validate_play_mode() {
  case "$PLAY_MODE" in
    x86|pi4)
      ;;
    *)
      die "play mode must be x86 or pi4, got '$PLAY_MODE'"
      ;;
  esac
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

codespace_state() {
  gh codespace view \
    -c "$CODESPACE_NAME" \
    --json state \
    --jq .state \
    2> >(sanitize_remote_error >&2) || true
}

wait_for_codespace_state() {
  local state
  local wait_started
  local last_state=""

  echo "Waiting up to ${CODESPACES_READY_WAIT_SECONDS}s for Codespace control-plane state"
  wait_started=$SECONDS
  while [ $((SECONDS - wait_started)) -lt "$CODESPACES_READY_WAIT_SECONDS" ]; do
    state="$(codespace_state)"
    if [ -n "$state" ] && [ "$state" != "$last_state" ]; then
      echo "Codespace state: $state"
      last_state="$state"
    fi

    case "$state" in
      Available|Ready|Running)
        return 0
        ;;
      Shutdown|Stopped)
        echo "Codespace is stopped; Codespaces SSH will request startup and retry until the SSH server is ready."
        return 0
        ;;
      Failed|Deleted|Unavailable)
        die "Codespace '$CODESPACE_NAME' entered state '$state'; delete it and recreate"
        ;;
      *)
        sleep "$CODESPACES_READY_WAIT_INTERVAL"
        ;;
    esac
  done

  echo "Codespace state did not report Available before timeout; trying SSH retries anyway because GitHub state names can lag." >&2
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
      printf "%s%s\n" "${browse_url%%\?*}" "$NOVNC_VNC_PATH"
      ;;
    *)
      printf "%s%s\n" "${browse_url%/}" "$NOVNC_VNC_PATH"
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
  echo "mode: $PLAY_MODE"
  if [ -n "$CODESPACE_NAME" ]; then
    echo "codespace: reuse $CODESPACE_NAME"
  else
    echo "codespace: create $DISPLAY_NAME"
  fi
  echo "machine: ${CODESPACE_MACHINE:-default}"
  echo "idle timeout: $IDLE_TIMEOUT"
  echo "retention period: $RETENTION_PERIOD"
  echo "noVNC port: $NOVNC_PORT (private)"
  echo "noVNC browser path: $NOVNC_VNC_PATH"
  echo "visible display: open noVNC in browser fullscreen; resize=scale keeps the Pi desktop zoomed to the window"
  echo "launcher controls: click the noVNC canvas first, then press 1/click Doom or press 2/click Quake"
  print_visible_play_controls
  if [ "$PLAY_MODE" = "pi4" ]; then
    echo "guest UX: Pi 4 real-assets launcher desktop with Doom and Quake choices inside vibe-os"
    echo "guest input: USB keyboard and USB mouse through QEMU/noVNC"
    print_pi4_codespaces_handoff
  fi
  echo "machine selection: $MACHINE_SELECTION_SUMMARY"
  echo "machine choices: gh api \"/repos/$REPO/codespaces/machines?ref=$(urlencode "$REF")\" --jq '.machines[] | [.cpus, .name, .display_name] | @tsv'"
  echo "resize existing Codespace: gh codespace edit -c <codespace-name> --machine <4-plus-cpu-machine-name>"
  echo "Codespace ready-state wait timeout: ${CODESPACES_READY_WAIT_SECONDS}s"
  echo "noVNC wait timeout: ${CODESPACES_PORT_WAIT_SECONDS}s"
  echo "SSH start attempts: $CODESPACES_SSH_ATTEMPTS"
  echo "browser open: $OPEN_BROWSER"
  echo "GitHub Codespaces API: accessible"
  echo "GitHub repo/ref: verified"
  echo "remote play ref: verified on selected ref"
  echo "git state: $GIT_STATE_SUMMARY"
  echo "local artifact transfer: none (no WADs, disk images, pixels, raw audio, or logs copied to the Mac)"
  echo "proof boundary: Codespaces/noVNC is visible play only; status/workflow gates remain the proof surface"
  echo "performance caveat: 2-core Codespaces can play but may stutter during builds or noVNC streaming"
  echo "performance preference: use the selected 4+ CPU machine for interactive play when available"
  echo "remote preflight command: ./tools/play_now_remote.sh --$PLAY_MODE --preflight --require-novnc"
  echo "remote start command: NOVNC_PORT=$NOVNC_PORT NOVNC_VNC_PATH='$NOVNC_VNC_PATH' VIBE_PLAY_MODE=$PLAY_MODE nohup ./tools/play_now_remote.sh --$PLAY_MODE --require-novnc"
  echo "remote diagnostics watch command: /tmp/vibe-os-play-now-diagnostics.sh --watch"
  echo "dry-run: Codespace was not created or modified"
  echo "next: run without --dry-run when you are ready to start the disposable remote play session"
}

print_web_url_summary() {
  echo "play-now browser Codespaces path"
  echo "repo: $REPO"
  echo "ref: $REF"
  echo "mode: $PLAY_MODE"
  echo "noVNC port: $NOVNC_PORT (private)"
  echo "noVNC browser path: $NOVNC_VNC_PATH"
  echo "visible display: open noVNC in browser fullscreen; resize=scale keeps the Pi desktop zoomed to the window"
  echo "launcher controls: click the noVNC canvas first, then press 1/click Doom or press 2/click Quake"
  print_visible_play_controls
  if [ "$PLAY_MODE" = "pi4" ]; then
    echo "guest UX: Pi 4 real-assets launcher desktop with Doom and Quake choices inside vibe-os"
    echo "guest input: USB keyboard and USB mouse through QEMU/noVNC"
    print_pi4_codespaces_handoff
  fi
  echo "GitHub repo/ref: verified"
  echo "remote play ref: verified on selected ref"
  echo "local gh Codespaces API: not required for this browser path"
  echo "local gh auth: optional for this browser path"
  echo "local artifact transfer: none (no WADs, disk images, pixels, raw audio, or logs copied to the Mac)"
  echo "proof boundary: browser-created Codespaces/noVNC is visible play only; status/workflow gates remain the proof surface"
  echo "machine guidance: choose a 4-core+ Codespaces machine in the browser when available; GitHub defaults to the lowest valid machine"
  echo "machine choices after create: gh api \"/repos/$REPO/codespaces/machines?ref=$(urlencode "$REF")\" --jq '.machines[] | [.cpus, .name, .display_name] | @tsv'"
  echo "resize existing Codespace: gh codespace edit -c <codespace-name> --machine <4-plus-cpu-machine-name>"
  echo "Codespaces create URL:"
  echo "$(codespaces_create_url)"
  echo
  print_inside_codespace_commands
  echo "dry-run: Codespace was not created or modified"
}

remote_start_script() {
  cat <<'REMOTE'
repo_dir="${VIBE_CODESPACE_REPO_DIR:-}"
redact_remote_stream() {
  sed -E \
    -e 's/((GH|GITHUB|CODESPACES|VSCODE|ACTIONS|NPM|NODE_AUTH|DOCKER|AWS|AZURE|GOOGLE|OPENAI|ANTHROPIC|GEMINI|HF|HUGGINGFACE|VIBE)[A-Z0-9_]*_(TOKEN|KEY|SECRET|PASSWORD|CREDENTIAL|AUTH)[A-Z0-9_]*=)[^[:space:]]+/\1[redacted]/g' \
    -e 's/((GH|GITHUB|CODESPACES|VSCODE|ACTIONS|NPM|NODE_AUTH|DOCKER|AWS|AZURE|GOOGLE|OPENAI|ANTHROPIC|GEMINI|HF|HUGGINGFACE|VIBE)[A-Z0-9_]*=)(gh[pousr]_[A-Za-z0-9_]+)/\1[redacted]/g' \
    -e 's/(gh[pousr]_[A-Za-z0-9_]+)/[redacted]/g' \
    -e 's/(^|[^A-Z0-9])([A-Z0-9]{4}-[A-Z0-9]{4})([^A-Z0-9]|$)/\1[redacted-code]\3/g' \
    -e 's/(Authorization: *(Bearer|token) +)[^[:space:]]+/\1[redacted]/Ig' \
    -e 's/((access_token|token|signature|X-Amz-Signature|X-Amz-Credential)=)[^&[:space:]]+/\1[redacted]/Ig'
}

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

case "${VIBE_PLAY_MODE:-pi4}" in
  x86)
    play_mode_arg=--x86
    ;;
  pi4)
    play_mode_arg=--pi4
    ;;
  *)
    echo "invalid VIBE_PLAY_MODE: ${VIBE_PLAY_MODE:-}" >&2
    exit 2
    ;;
esac

if [ -n "${VIBE_PLAY_REF:-}" ]; then
  git fetch --depth=1 origin "$VIBE_PLAY_REF" >/tmp/vibe-os-play-now-fetch.log 2>&1 || {
    echo "remote git fetch failed for the selected play ref; sanitized recent output:" >&2
    redact_remote_stream </tmp/vibe-os-play-now-fetch.log | tail -n 40 >&2
    exit 1
  }
  git checkout --detach FETCH_HEAD
  echo "remote play ref: $(git rev-parse --short HEAD)"
fi

./tools/play_now_remote.sh "$play_mode_arg" --preflight --require-novnc

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
  nohup ./tools/play_now_remote.sh "$play_mode_arg" --require-novnc >"$log_file" 2>&1 &
  echo "$!" >"$pid_file"
  echo "vibe-os play-now started in this Codespace: pid=$(cat "$pid_file")"
  echo "remote noVNC readiness: the launcher waits for vnc.html before it prints its noVNC URL"
  sleep 2
  if ! kill -0 "$(cat "$pid_file")" 2>/dev/null; then
    echo "vibe-os play-now exited during startup; recent remote log:" >&2
    tail -n 80 "$log_file" | redact_remote_stream >&2 || true
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
    remote_start_script | gh codespace ssh -c "$CODESPACE_NAME" -- env VIBE_PLAY_REF="$REF" VIBE_PLAY_MODE="$PLAY_MODE" NOVNC_PORT="$NOVNC_PORT" NOVNC_VNC_PATH="$NOVNC_VNC_PATH" bash -euo pipefail -s > >(sanitize_remote_error) 2> >(sanitize_remote_error | tee "$err_file" >&2)
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
      echo "The remote command is passed over stdin to bash -euo pipefail -s; the launcher does not use bash -lc, does not print remote env, and filters token-shaped output."
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
    --x86)
      PLAY_MODE=x86
      ;;
    --pi4)
      PLAY_MODE=pi4
      ;;
    --mode|--kind)
      [ "$#" -ge 2 ] || die "$1 requires x86 or pi4"
      PLAY_MODE="$2"
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
validate_play_mode
validate_novnc_port
validate_novnc_path
validate_positive_integer CODESPACES_PORT_WAIT_SECONDS "$CODESPACES_PORT_WAIT_SECONDS"
validate_positive_integer CODESPACES_PORT_WAIT_INTERVAL "$CODESPACES_PORT_WAIT_INTERVAL"
validate_positive_integer CODESPACES_READY_WAIT_SECONDS "$CODESPACES_READY_WAIT_SECONDS"
validate_positive_integer CODESPACES_READY_WAIT_INTERVAL "$CODESPACES_READY_WAIT_INTERVAL"
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
verify_remote_play_ref

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

wait_for_codespace_state
echo "Starting vibe-os $PLAY_MODE play inside Codespace '$CODESPACE_NAME'"
run_remote_start || exit $?

novnc_browse_url=""
echo "Waiting up to ${CODESPACES_PORT_WAIT_SECONDS}s for noVNC port $NOVNC_PORT and its forwarded browser URL"
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
  echo "Then open: http://127.0.0.1:$NOVNC_PORT$NOVNC_VNC_PATH"
  die "noVNC port $NOVNC_PORT did not become available before the timeout; inspect the remote log above"
fi

novnc_url="$(novnc_url_from_browse_url "$novnc_browse_url")"
echo "Open vibe-os $PLAY_MODE noVNC: $novnc_url"
if [ "$PLAY_MODE" = "x86" ]; then
  echo "Controls: arrows move/turn, Ctrl fires, Space uses, Escape opens menu."
else
  print_pi4_codespaces_handoff
fi
print_visible_play_controls
echo "Human handoff tip: click the noVNC canvas before play; keep any notes short and status-only."
echo "Proof boundary: this is a visible play session, not a replacement for status/workflow proof gates."
echo "Audio boundary: VNC is display/input only; do not copy raw audio back to the Mac."
echo "Performance note: 2-core Codespaces can play, but noVNC may stutter during builds or CPU contention; 4+ CPUs are preferred for interactive play."
echo "Slowdown check: run the Diagnostics command above twice, about 60s apart; it prints only safe process/load and OS status-log lines."
echo "Slowdown watch: run the Diagnostics watch command above while playing to sample cgroup CPU pressure and status counters over time."
echo "If status counters keep advancing but 2-core noVNC keeps degrading, recreate on a 4+ CPU Codespace before changing OS runtime code."
if [ "$OPEN_BROWSER" = "1" ] && [ "$(uname -s)" = "Darwin" ] && command -v open >/dev/null 2>&1; then
  open "$novnc_url" || true
fi
