#!/usr/bin/env bash
set -u

BUILD_DIR="${BUILD_DIR:-build}"
QEMU="${QEMU:-qemu-system-x86_64}"
QEMU_MACHINE="${QEMU_MACHINE:-pc,accel=tcg}"
QEMU_EXTRA_ARGS="${QEMU_EXTRA_ARGS:-}"
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
SMOKE_EXPECT_GUEST_EXIT="${SMOKE_EXPECT_GUEST_EXIT:-0}"
SMOKE_GUEST_EXIT_KEYS="${SMOKE_GUEST_EXIT_KEYS:-}"
SMOKE_NO_REBOOT="${SMOKE_NO_REBOOT:-1}"
SMOKE_NO_SHUTDOWN="${SMOKE_NO_SHUTDOWN:-1}"

monitor_sock="$BUILD_DIR/monitor.sock"
smoke_log="$BUILD_DIR/smoke.log"
monitor_log="$BUILD_DIR/monitor.log"
qemu_log="$BUILD_DIR/qemu.log"
serial_log="$BUILD_DIR/serial.log"
qemu_pid=""
qemu_extra_args=()
qemu_control_args=()
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

status_field_value() {
  local field="$1"
  local path="$2"

  awk -v key="$field" '
    BEGIN { prefix = key "=" }
    {
      for (i = 1; i <= NF; i++) {
        if (index($i, prefix) == 1) {
          print substr($i, length(prefix) + 1)
          found = 1
          exit 0
        }
      }
    }
    END {
      if (!found) {
        exit 1
      }
    }
  ' "$path"
}

status_field_matches() {
  local path="$1"
  local field="$2"
  local expected="$3"
  local value

  value="$(status_field_value "$field" "$path" 2>/dev/null)" || return 1
  [ "$value" = "$expected" ]
}

status_field_hex_at_least() {
  local path="$1"
  local field="$2"
  local minimum="$3"
  local value

  value="$(status_field_value "$field" "$path" 2>/dev/null)" || return 1
  case "$value" in
    ""|*[!0123456789abcdefABCDEF]*) return 1 ;;
  esac
  [ $((16#$value)) -ge $((16#$minimum)) ]
}

status_field_hex_part_at_least() {
  local path="$1"
  local field="$2"
  local part="$3"
  local minimum="$4"
  local value
  local normalized
  local index
  local piece
  local -a parts

  value="$(status_field_value "$field" "$path" 2>/dev/null)" || return 1
  normalized="${value//:/\/}"
  IFS='/' read -r -a parts <<< "$normalized"
  index=$((part - 1))
  piece="${parts[$index]:-}"
  case "$piece" in
    ""|*[!0123456789abcdefABCDEF]*) return 1 ;;
  esac
  [ $((16#$piece)) -ge $((16#$minimum)) ]
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

  commands="info status\ninfo registers\npmemsave 0xb8000 4000 $vga_bin\npmemsave 0x9d000 12288 $status_bin\n"
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

validate_signed_integer() {
  local value="$1"
  local label="$2"

  if ! printf '%s\n' "$value" | grep -Eq '^-?[0-9]+$'; then
    fail_smoke "$label must be a signed integer, got '$value'."
  fi
}

validate_mouse_buttons() {
  local value="$1"

  validate_seconds "$value" "mouse button mask"
  if [ "$value" -gt 7 ]; then
    fail_smoke "mouse button mask must be between 0 and 7, got '$value'."
  fi
}

validate_phase_label() {
  local label="$1"

  case "$label" in
    ""|*[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-]*)
      fail_smoke "input script phase label must use only letters, digits, underscore, or hyphen: '$label'."
      ;;
  esac
}

validate_status_field_name() {
  local field="$1"

  case "$field" in
    ""|*[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_]*)
      fail_smoke "status field names must use only letters, digits, or underscore: '$field'."
      ;;
  esac
}

validate_status_expected_value() {
  local value="$1"

  case "$value" in
    ""|*[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.\/:-]*)
      fail_smoke "status expected values must not contain whitespace or shell metacharacters: '$value'."
      ;;
  esac
}

validate_hex_value() {
  local value="$1"
  local label="$2"

  case "$value" in
    ""|*[!0123456789abcdefABCDEF]*)
      fail_smoke "$label must be a hexadecimal value, got '$value'."
      ;;
  esac
}

qemu_key_for_char() {
  local ch="$1"

  case "$ch" in
    [abcdefghijklmnopqrstuvwxyz0123456789]) printf '%s' "$ch" ;;
    [ABCDEFGHIJKLMNOPQRSTUVWXYZ]) printf '%s' "$(printf '%s' "$ch" | tr '[:upper:]' '[:lower:]')" ;;
    " ") printf 'spc' ;;
    "-") printf 'minus' ;;
    "_") printf 'shift-minus' ;;
    ".") printf 'dot' ;;
    "/") printf 'slash' ;;
    ":") printf 'shift-semicolon' ;;
    *) fail_smoke "text action contains unsupported character '$ch'." ;;
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

send_text_action() {
  local text="$1"
  local index
  local ch
  local key
  local commands=""

  if [ -z "$text" ]; then
    fail_smoke "text action is empty."
  fi

  for ((index = 0; index < ${#text}; index++)); do
    ch="${text:index:1}"
    if ! key="$(qemu_key_for_char "$ch")"; then
      fail_smoke "failed to translate text action character '$ch'."
    fi
    commands="${commands}sendkey ${key}\n"
  done

  send_monitor "text $text" "$commands" || fail_smoke "failed to send text action"
  sleep_checked 1 "text action delivery"
}

send_mouse_move_action() {
  local move="$1"
  local dx
  local dy
  local extra

  IFS=':' read -r dx dy extra <<< "$move"
  if [ -z "$dx" ] || [ -z "$dy" ] || [ -n "$extra" ]; then
    fail_smoke "mouse move action must be mouse=DX:DY, got '$move'."
  fi
  validate_signed_integer "$dx" "mouse X delta"
  validate_signed_integer "$dy" "mouse Y delta"
  send_monitor "mouse_move $dx $dy" "mouse_move $dx $dy\n" || fail_smoke "failed to send mouse move '$move' to QEMU monitor"
  sleep_checked 1 "mouse move delivery"
}

send_mouse_button_action() {
  local buttons="$1"

  validate_mouse_buttons "$buttons"
  send_monitor "mouse_button $buttons" "mouse_button $buttons\n" || fail_smoke "failed to send mouse button mask '$buttons' to QEMU monitor"
  sleep_checked 1 "mouse button delivery"
}

wait_status_action() {
  local label="$1"
  local spec="$2"
  local mode="$3"
  local field
  local expected
  local timeout
  local interval
  local extra
  local end
  local now
  local left
  local sleep_for
  local status_bin
  local status_txt

  IFS=':' read -r field expected timeout interval extra <<< "$spec"
  if [ -z "$field" ] || [ -z "$expected" ] || [ -z "$timeout" ] || [ -n "$extra" ]; then
    fail_smoke "$mode action must be ${mode}=FIELD:VALUE:SECONDS[:INTERVAL], got '$spec'."
  fi
  if [ -z "$interval" ]; then
    interval=2
  fi
  validate_status_field_name "$field"
  validate_seconds "$timeout" "timeout for $mode action in phase $label"
  validate_seconds "$interval" "poll interval for $mode action in phase $label"
  if [ "$interval" -eq 0 ]; then
    fail_smoke "poll interval for $mode action in phase $label must be greater than zero."
  fi
  if [ "$mode" = "wait-status-min" ]; then
    validate_hex_value "$expected" "minimum for $mode action in phase $label"
  else
    validate_status_expected_value "$expected"
  fi

  status_bin="$BUILD_DIR/status.$label.wait-$field.bin"
  status_txt="$BUILD_DIR/status.$label.wait-$field.txt"
  end=$(( $(now_s) + timeout ))

  while :; do
    rm -f "$status_bin" "$status_txt"
    send_monitor "$mode $field=$expected" "pmemsave 0x9d000 12288 $status_bin\n" || fail_smoke "failed to capture status for $mode action in phase $label"
    decode_status "$status_bin" "$status_txt"
    if [ "$mode" = "wait-status-min" ]; then
      if status_field_hex_at_least "$status_txt" "$field" "$expected"; then
        log "Observed status field $field >= 0x$expected for phase $label."
        return 0
      fi
    elif status_field_matches "$status_txt" "$field" "$expected"; then
      log "Observed status field $field=$expected for phase $label."
      return 0
    fi

    now="$(now_s)"
    left=$((end - now))
    if [ "$left" -le 0 ]; then
      fail_smoke "Timed out waiting for $field to satisfy $mode target '$expected' in phase $label after ${timeout}s."
    fi
    sleep_for="$interval"
    if [ "$sleep_for" -gt "$left" ]; then
      sleep_for="$left"
    fi
    sleep_checked "$sleep_for" "$mode $field=$expected"
  done
}

wait_status_part_min_action() {
  local label="$1"
  local spec="$2"
  local field
  local part
  local expected
  local timeout
  local interval
  local extra
  local end
  local now
  local left
  local sleep_for
  local status_bin
  local status_txt

  IFS=':' read -r field part expected timeout interval extra <<< "$spec"
  if [ -z "$field" ] || [ -z "$part" ] || [ -z "$expected" ] || [ -z "$timeout" ] || [ -n "$extra" ]; then
    fail_smoke "wait-status-part-min action must be wait-status-part-min=FIELD:PART:HEX:SECONDS[:INTERVAL], got '$spec'."
  fi
  if [ -z "$interval" ]; then
    interval=2
  fi
  validate_status_field_name "$field"
  validate_seconds "$part" "part index for wait-status-part-min action in phase $label"
  if [ "$part" -eq 0 ]; then
    fail_smoke "part index for wait-status-part-min action in phase $label must be greater than zero."
  fi
  validate_hex_value "$expected" "minimum for wait-status-part-min action in phase $label"
  validate_seconds "$timeout" "timeout for wait-status-part-min action in phase $label"
  validate_seconds "$interval" "poll interval for wait-status-part-min action in phase $label"
  if [ "$interval" -eq 0 ]; then
    fail_smoke "poll interval for wait-status-part-min action in phase $label must be greater than zero."
  fi

  status_bin="$BUILD_DIR/status.$label.wait-$field-$part.bin"
  status_txt="$BUILD_DIR/status.$label.wait-$field-$part.txt"
  end=$(( $(now_s) + timeout ))

  while :; do
    rm -f "$status_bin" "$status_txt"
    send_monitor "wait-status-part-min $field[$part]=$expected" "pmemsave 0x9d000 12288 $status_bin\n" || fail_smoke "failed to capture status for wait-status-part-min action in phase $label"
    decode_status "$status_bin" "$status_txt"
    if status_field_hex_part_at_least "$status_txt" "$field" "$part" "$expected"; then
      log "Observed status field $field part $part >= 0x$expected for phase $label."
      return 0
    fi

    now="$(now_s)"
    left=$((end - now))
    if [ "$left" -le 0 ]; then
      fail_smoke "Timed out waiting for $field part $part to reach at least 0x$expected in phase $label after ${timeout}s."
    fi
    sleep_for="$interval"
    if [ "$sleep_for" -gt "$left" ]; then
      sleep_for="$left"
    fi
    sleep_checked "$sleep_for" "wait-status-part-min $field[$part]=$expected"
  done
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
        wait-status=*)
          wait_status_action "$label" "${action#wait-status=}" "wait-status"
          ;;
        wait-status-min=*)
          wait_status_action "$label" "${action#wait-status-min=}" "wait-status-min"
          ;;
        wait-status-part-min=*)
          wait_status_part_min_action "$label" "${action#wait-status-part-min=}"
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
        mouse=*|mousemove=*)
          send_mouse_move_action "${action#*=}"
          ;;
        mousebtn=*|mousebutton=*)
          send_mouse_button_action "${action#*=}"
          ;;
        text=*)
          send_text_action "${action#text=}"
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

wait_for_guest_exit() {
  local end
  end=$(( $(now_s) + SMOKE_SHUTDOWN_TIMEOUT ))
  while qemu_is_running; do
    if [ "$(now_s)" -ge "$end" ]; then
      fail_smoke "QEMU did not exit after the guest-requested shutdown/reboot within ${SMOKE_SHUTDOWN_TIMEOUT}s."
    fi
    sleep 1
  done
  wait_qemu_status || true
}

send_guest_exit_keys() {
  local key
  for key in $SMOKE_GUEST_EXIT_KEYS; do
    if ! qemu_is_running; then
      wait_qemu_status
      fail_smoke "QEMU exited before guest-exit key injection."
    fi
    send_monitor "guest-exit sendkey $key" "sendkey $key\n" || fail_smoke "failed to send guest-exit key $key"
  done
}

trap cleanup EXIT INT TERM

deadline=$(( $(now_s) + SMOKE_QEMU_TIMEOUT ))
if [ -n "$QEMU_EXTRA_ARGS" ]; then
  # Extra smoke arguments are repo-owned cloud knobs such as the SB16 no-audio backend.
  qemu_extra_args=( $QEMU_EXTRA_ARGS )
fi
if [ "$SMOKE_NO_REBOOT" = "1" ]; then
  qemu_control_args+=( -no-reboot )
fi
if [ "$SMOKE_NO_SHUTDOWN" = "1" ]; then
  qemu_control_args+=( -no-shutdown )
fi
log "Starting QEMU smoke: timeout=${SMOKE_QEMU_TIMEOUT}s early=${SMOKE_EARLY_SECONDS}s settle=${SMOKE_SETTLE_SECONDS}s capture_gfx=${SMOKE_CAPTURE_GFX} expect_guest_exit=${SMOKE_EXPECT_GUEST_EXIT} extra_args=${QEMU_EXTRA_ARGS:-<none>}."
"$QEMU" \
  -machine "$QEMU_MACHINE" \
  -drive "file=$IMAGE,format=raw,if=ide,index=0,media=disk" \
  -boot c \
  -display none \
  -serial "file:$serial_log" \
  -monitor "unix:$monitor_sock,server,nowait" \
  "${qemu_control_args[@]}" \
  "${qemu_extra_args[@]}" \
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
if [ "$SMOKE_EXPECT_GUEST_EXIT" = "1" ]; then
  send_guest_exit_keys
  wait_for_guest_exit
else
  send_monitor quit "quit\n" || log "QEMU monitor quit command failed; cleanup will terminate the process if needed."
  wait_for_shutdown
fi
trap - EXIT INT TERM
cleanup
log "QEMU smoke runner completed."
