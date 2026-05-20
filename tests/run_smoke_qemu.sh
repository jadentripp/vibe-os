#!/usr/bin/env bash
set -u

BUILD_DIR="${BUILD_DIR:-build}"
QEMU="${QEMU:-qemu-system-x86_64}"
QEMU_MACHINE="${QEMU_MACHINE:-pc,accel=tcg}"
IMAGE="${IMAGE:-$BUILD_DIR/disk.img}"
NC="${NC:-nc}"
SMOKE_NC_TIMEOUT="${SMOKE_NC_TIMEOUT:-3}"
SMOKE_QEMU_TIMEOUT="${SMOKE_QEMU_TIMEOUT:-30}"
SMOKE_EARLY_SECONDS="${SMOKE_EARLY_SECONDS:-2}"
SMOKE_SETTLE_SECONDS="${SMOKE_SETTLE_SECONDS:-5}"
SMOKE_SHUTDOWN_TIMEOUT="${SMOKE_SHUTDOWN_TIMEOUT:-5}"
SMOKE_CAPTURE_GFX="${SMOKE_CAPTURE_GFX:-1}"
SMOKE_SENDKEYS="${SMOKE_SENDKEYS:-}"
SMOKE_INPUT_SCRIPT="${SMOKE_INPUT_SCRIPT:-}"

monitor_sock="$BUILD_DIR/monitor.sock"
smoke_log="$BUILD_DIR/smoke.log"
monitor_log="$BUILD_DIR/monitor.log"
qemu_log="$BUILD_DIR/qemu.log"
serial_log="$BUILD_DIR/serial.log"
qemu_pid=""
deadline=0
failing=0

mkdir -p "$BUILD_DIR"
rm -f \
  "$monitor_sock" \
  "$BUILD_DIR"/qemu.pid \
  "$BUILD_DIR"/vga.bin \
  "$BUILD_DIR"/vga.*.bin \
  "$BUILD_DIR"/vga.txt \
  "$BUILD_DIR"/vga.*.txt \
  "$BUILD_DIR"/status.bin \
  "$BUILD_DIR"/status.*.bin \
  "$BUILD_DIR"/status.txt \
  "$BUILD_DIR"/status.*.txt \
  "$BUILD_DIR"/gfx.bin \
  "$smoke_log" \
  "$monitor_log" \
  "$qemu_log" \
  "$serial_log"

log() {
  printf '[%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" | tee -a "$smoke_log"
}

now_s() {
  date +%s
}

seconds_left() {
  local now
  now="$(now_s)"
  echo $((deadline - now))
}

qemu_is_running() {
  local state
  [ -n "$qemu_pid" ] || return 1
  kill -0 "$qemu_pid" 2>/dev/null || return 1
  state="$(ps -p "$qemu_pid" -o stat= 2>/dev/null | tr -d '[:space:]')"
  [ -n "$state" ] || return 1
  case "$state" in
    Z*) return 1 ;;
    *) return 0 ;;
  esac
}

wait_qemu_status() {
  local rc
  if [ -n "$qemu_pid" ]; then
    wait "$qemu_pid" >/dev/null 2>&1
    rc=$?
    log "QEMU process exited with status $rc."
    qemu_pid=""
  fi
}

cleanup() {
  if qemu_is_running; then
    log "Cleaning up QEMU process $qemu_pid."
    kill "$qemu_pid" 2>/dev/null || true
    sleep 1
    if qemu_is_running; then
      kill -9 "$qemu_pid" 2>/dev/null || true
    fi
    wait_qemu_status || true
  fi
}

decode_status() {
  local input="$1"
  local output="$2"
  if [ -s "$input" ]; then
    perl -e 'local $/; $d = <>; $d =~ s/\0/ /g; print $d' "$input" > "$output"
  fi
}

decode_vga() {
  local input="$1"
  local output="$2"
  if [ -s "$input" ]; then
    perl -e 'local $/; $d = <>; for ($i = 0; $i < length($d); $i += 2) { $c = ord(substr($d, $i, 1)); print chr($c || 32); }' "$input" > "$output"
  fi
}

send_monitor() {
  local label="$1"
  local commands="$2"

  log "Sending QEMU monitor commands for $label."
  {
    printf -- '---- %s %s ----\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$label"
    printf '%b' "$commands"
    printf '\n'
  } >> "$monitor_log"

  if ! printf '%b' "$commands" | "$NC" -w "$SMOKE_NC_TIMEOUT" -U "$monitor_sock" >> "$monitor_log" 2>&1; then
    log "QEMU monitor command failed for $label."
    return 1
  fi
}

capture_snapshot() {
  local label="$1"
  local require="$2"
  local suffix=""
  local status_bin
  local status_txt
  local vga_bin
  local vga_txt
  local commands

  if [ "$label" != "final" ]; then
    suffix=".$label"
  fi

  status_bin="$BUILD_DIR/status$suffix.bin"
  status_txt="$BUILD_DIR/status$suffix.txt"
  vga_bin="$BUILD_DIR/vga$suffix.bin"
  vga_txt="$BUILD_DIR/vga$suffix.txt"

  commands="info status\ninfo registers\npmemsave 0xb8000 4000 $vga_bin\npmemsave 0x9d000 2048 $status_bin\n"
  if [ "$label" = "final" ] && [ "$SMOKE_CAPTURE_GFX" = "1" ]; then
    commands="${commands}pmemsave 0xa0000 64000 $BUILD_DIR/gfx.bin\n"
  fi

  if ! send_monitor "$label snapshot" "$commands"; then
    [ "$require" = "1" ] && return 1
    return 0
  fi

  decode_status "$status_bin" "$status_txt"
  decode_vga "$vga_bin" "$vga_txt"

  if [ "$require" = "1" ] && [ ! -s "$status_bin" ]; then
    log "Required status snapshot $status_bin was not created."
    return 1
  fi

  if [ -s "$status_txt" ]; then
    log "Decoded $label status to $status_txt."
  fi
}

fail_smoke() {
  local message="$1"
  log "ERROR: $message"
  if [ "$failing" = "0" ]; then
    failing=1
    if qemu_is_running && [ -S "$monitor_sock" ]; then
      capture_snapshot failure 0 || true
    fi
  fi
  exit 1
}

validate_seconds() {
  local value="$1"
  local label="$2"

  case "$value" in
    ""|*[!0-9]*) fail_smoke "$label must be a non-negative integer, got '$value'." ;;
  esac
}

validate_phase_label() {
  local label="$1"

  case "$label" in
    ""|*[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-]*)
      fail_smoke "input script phase label must use only letters, digits, underscore, or hyphen: '$label'."
      ;;
  esac
}

send_key_action() {
  local key="$1"
  local hold_ms="${2:-}"
  local command
  local label

  if [ -z "$key" ]; then
    fail_smoke "input script key action is empty."
  fi
  command="sendkey $key"
  label="sendkey $key"
  if [ -n "$hold_ms" ]; then
    validate_seconds "$hold_ms" "hold duration for $key"
    command="$command $hold_ms"
    label="$label $hold_ms"
  fi
  send_monitor "$label" "$command\n" || fail_smoke "failed to send key action '$label' to QEMU monitor"
  sleep_checked 1 "$label delivery"
}

run_input_script() {
  local phase
  local label
  local actions
  local action
  local key_hold
  local key
  local hold_ms

  for phase in $SMOKE_INPUT_SCRIPT; do
    if [ "$phase" = "${phase#*:}" ]; then
      fail_smoke "input script phase '$phase' is missing a label:actions separator."
    fi

    label="${phase%%:*}"
    actions="${phase#*:}"
    validate_phase_label "$label"

    IFS=',' read -r -a action_list <<< "$actions"
    for action in "${action_list[@]}"; do
      case "$action" in
        wait=*)
          hold_ms="${action#wait=}"
          validate_seconds "$hold_ms" "wait duration for phase $label"
          sleep_checked "$hold_ms" "input script phase $label wait"
          ;;
        snapshot)
          capture_snapshot "$label" 0 || true
          ;;
        hold=*)
          key_hold="${action#hold=}"
          if [ "$key_hold" = "${key_hold#*:}" ]; then
            fail_smoke "hold action '$action' must be hold=KEY:MILLISECONDS."
          fi
          key="${key_hold%%:*}"
          hold_ms="${key_hold#*:}"
          send_key_action "$key" "$hold_ms"
          ;;
        "")
          fail_smoke "input script phase $label contains an empty action."
          ;;
        *)
          send_key_action "$action"
          ;;
      esac
    done
  done
}

sleep_checked() {
  local seconds="$1"
  local reason="$2"
  local end
  local left

  end=$(( $(now_s) + seconds ))
  while [ "$(now_s)" -lt "$end" ]; do
    if ! qemu_is_running; then
      wait_qemu_status
      fail_smoke "QEMU exited unexpectedly while waiting for $reason."
    fi
    left="$(seconds_left)"
    if [ "$left" -le 0 ]; then
      fail_smoke "QEMU smoke timed out while waiting for $reason after ${SMOKE_QEMU_TIMEOUT}s."
    fi
    sleep 1
  done
}

wait_for_monitor() {
  log "Waiting for QEMU monitor socket $monitor_sock."
  while [ ! -S "$monitor_sock" ]; do
    if ! qemu_is_running; then
      wait_qemu_status
      fail_smoke "QEMU exited before creating the monitor socket."
    fi
    if [ "$(seconds_left)" -le 0 ]; then
      fail_smoke "QEMU monitor socket was not created within ${SMOKE_QEMU_TIMEOUT}s."
    fi
    sleep 1
  done
}

wait_for_shutdown() {
  local end
  end=$(( $(now_s) + SMOKE_SHUTDOWN_TIMEOUT ))
  while qemu_is_running; do
    if [ "$(now_s)" -ge "$end" ]; then
      log "QEMU did not exit after quit within ${SMOKE_SHUTDOWN_TIMEOUT}s; terminating it."
      cleanup
      return 0
    fi
    sleep 1
  done
  wait_qemu_status || true
}

trap cleanup EXIT INT TERM

deadline=$(( $(now_s) + SMOKE_QEMU_TIMEOUT ))
log "Starting QEMU smoke: timeout=${SMOKE_QEMU_TIMEOUT}s early=${SMOKE_EARLY_SECONDS}s settle=${SMOKE_SETTLE_SECONDS}s capture_gfx=${SMOKE_CAPTURE_GFX}."
"$QEMU" \
  -machine "$QEMU_MACHINE" \
  -drive "file=$IMAGE,format=raw,if=ide,index=0,media=disk" \
  -boot c \
  -display none \
  -serial "file:$serial_log" \
  -monitor "unix:$monitor_sock,server,nowait" \
  -no-reboot \
  -no-shutdown \
  > "$qemu_log" 2>&1 &
qemu_pid=$!
printf '%s\n' "$qemu_pid" > "$BUILD_DIR/qemu.pid"
log "QEMU pid is $qemu_pid."

wait_for_monitor
sleep_checked "$SMOKE_EARLY_SECONDS" "early boot snapshot"
capture_snapshot early 0 || true

if [ "$SMOKE_SETTLE_SECONDS" -gt "$SMOKE_EARLY_SECONDS" ]; then
  sleep_checked "$((SMOKE_SETTLE_SECONDS - SMOKE_EARLY_SECONDS))" "final boot settle"
fi

if [ -n "$SMOKE_INPUT_SCRIPT" ]; then
  run_input_script
elif [ -n "$SMOKE_SENDKEYS" ]; then
  for key in $SMOKE_SENDKEYS; do
    if ! qemu_is_running; then
      wait_qemu_status
      fail_smoke "QEMU exited before key injection."
    fi
    send_monitor "sendkey $key" "sendkey $key\n" || fail_smoke "failed to send key $key to QEMU monitor"
    sleep_checked 1 "key $key delivery"
  done
fi

capture_snapshot final 1 || fail_smoke "failed to capture final status snapshot"
send_monitor quit "quit\n" || log "QEMU monitor quit command failed; cleanup will terminate the process if needed."
wait_for_shutdown
trap - EXIT INT TERM
cleanup
log "QEMU smoke runner completed."
