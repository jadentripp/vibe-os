#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
if [ -z "$mode" ]; then
  echo "usage: tools/pi4_local_qemu.sh {smoke|launcher-framebuffer|uart-select-doom|uart-select-quake}" >&2
  exit 2
fi

PI4_BUILD_DIR="${PI4_BUILD_DIR:-build/pi4}"
PI4_HW_EQUIVALENT_QEMU="${PI4_HW_EQUIVALENT_QEMU:-qemu-system-aarch64}"
PI4_IMAGE="${PI4_IMAGE:-$PI4_BUILD_DIR/pi4-fat16.img}"
PI4_KERNEL8_IMG="${PI4_KERNEL8_IMG:-$PI4_BUILD_DIR/kernel8.img}"
PI4_QEMU_AUDIO_ARGS_SMOKE="${PI4_QEMU_AUDIO_ARGS_SMOKE:-}"
PI4_LOCAL_QEMU_SMOKE_SECONDS="${PI4_LOCAL_QEMU_SMOKE_SECONDS:-12}"
PI4_LOCAL_QEMU_SELECT_DELAY_SECONDS="${PI4_LOCAL_QEMU_SELECT_DELAY_SECONDS:-6}"
PI4_LOCAL_QEMU_SELECT_SETTLE_SECONDS="${PI4_LOCAL_QEMU_SELECT_SETTLE_SECONDS:-12}"
PI4_LOCAL_QEMU_DOOM_SELECT_PORT="${PI4_LOCAL_QEMU_DOOM_SELECT_PORT:-39241}"
PI4_LOCAL_QEMU_QUAKE_SELECT_PORT="${PI4_LOCAL_QEMU_QUAKE_SELECT_PORT:-39242}"
PI4_LOCAL_QEMU_SERIAL_LOG="${PI4_LOCAL_QEMU_SERIAL_LOG:-$PI4_BUILD_DIR/local-qemu-serial.log}"
PI4_LOCAL_QEMU_DOOM_SERIAL_LOG="${PI4_LOCAL_QEMU_DOOM_SERIAL_LOG:-$PI4_BUILD_DIR/local-qemu-doom-uart-select.log}"
PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG="${PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG:-$PI4_BUILD_DIR/local-qemu-quake-uart-select.log}"
PI4_LOCAL_QEMU_FRAMEBUFFER_LOG="${PI4_LOCAL_QEMU_FRAMEBUFFER_LOG:-$PI4_BUILD_DIR/local-qemu-launcher-framebuffer.log}"
PI4_LOCAL_QEMU_FRAMEBUFFER_PPM="${PI4_LOCAL_QEMU_FRAMEBUFFER_PPM:-$PI4_BUILD_DIR/local-qemu-launcher-framebuffer.ppm}"
PI4_LOCAL_QEMU_MONITOR_SOCK="${PI4_LOCAL_QEMU_MONITOR_SOCK:-$PI4_BUILD_DIR/local-qemu-monitor.sock}"
NC="${NC:-nc}"

qpid=""
ncpid=""
fifo=""
audio_args=()

if [ -n "$PI4_QEMU_AUDIO_ARGS_SMOKE" ]; then
  read -r -a audio_args <<< "$PI4_QEMU_AUDIO_ARGS_SMOKE"
fi

require_qemu() {
  command -v "$PI4_HW_EQUIVALENT_QEMU" >/dev/null || {
    echo "missing $PI4_HW_EQUIVALENT_QEMU" >&2
    exit 127
  }
}

qemu_common_args() {
  printf '%s\0' \
    -M raspi4b,usb=on \
    -cpu cortex-a72 \
    -m 2G \
    -kernel "$PI4_KERNEL8_IMG" \
    -drive "file=$PI4_IMAGE,if=sd,format=raw" \
    -device usb-kbd \
    -device usb-mouse
  if [ "${#audio_args[@]}" -gt 0 ]; then
    printf '%s\0' "${audio_args[@]}"
  fi
}

run_qemu() {
  local -a args
  args=()
  while IFS= read -r -d '' arg; do
    args+=( "$arg" )
  done < <(qemu_common_args)
  "$PI4_HW_EQUIVALENT_QEMU" "${args[@]}" "$@" &
  qpid=$!
}

cleanup() {
  if [ -n "$ncpid" ] && kill -0 "$ncpid" >/dev/null 2>&1; then
    kill "$ncpid" >/dev/null 2>&1 || true
  fi
  if [ -n "$qpid" ] && kill -0 "$qpid" >/dev/null 2>&1; then
    kill "$qpid" >/dev/null 2>&1 || true
  fi
  if [ -n "$ncpid" ]; then
    wait "$ncpid" >/dev/null 2>&1 || true
  fi
  if [ -n "$qpid" ]; then
    wait "$qpid" >/dev/null 2>&1 || true
  fi
  if [ -n "$fifo" ]; then
    rm -f "$fifo"
  fi
}

wait_for_monitor_socket() {
  local sock="$1"
  local i
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
    test -S "$sock" && return 0
    sleep 0.2
  done
  return 1
}

assert_pi4_audio_capture() {
  local path="$PI4_BUILD_DIR/pi4-local-qemu-audio.wav"
  test -s "$path"
  perl -e 'my $p=shift; open my $fh,"<:raw",$p or die $!; read $fh,my $b,-s $fh; my $d=substr($b,44); my $n=($d=~tr/\x00\x80//c); die "flat Pi audio capture\n" unless $n > 0; print "pi4audio_wav_bytes=",length($b)," pi4audio_wav_nonflat=$n/",length($d),"\n";' "$path"
}

print_last_status_fields() {
  local log="$1"
  local last_status
  last_status="$(grep -a "pi4audio=OK" "$log" | tail -n 1)"
  printf '%s\n' "$last_status" | tr ' ' '\n' | grep -E '^(path|upath|pi4exec|pi4appreq|pi4appvfs|pi4inputevt|fbpresent|fbchange|pi4preempt|pi4mem|pi4vfs|pi4audio|pi4audiohw|pi4audiousb|pi4audioq|pi4audiocount|panic|shutdown)='
}

pi4_smoke() {
  rm -f "$PI4_LOCAL_QEMU_SERIAL_LOG"
  printf "Booting exact Pi 4 image headlessly for %s seconds: %s\n" "$PI4_LOCAL_QEMU_SMOKE_SECONDS" "$PI4_IMAGE"
  trap cleanup EXIT INT TERM
  run_qemu \
    -serial "file:$PI4_LOCAL_QEMU_SERIAL_LOG" \
    -display none \
    -monitor none \
    -no-reboot \
    -no-shutdown
  sleep "$PI4_LOCAL_QEMU_SMOKE_SECONDS"
  cleanup
  trap - EXIT INT TERM
  test -s "$PI4_LOCAL_QEMU_SERIAL_LOG"
  tail -n 80 "$PI4_LOCAL_QEMU_SERIAL_LOG"
  grep -a -F -q "vibe-status arch=AARCH64 machine=PI4" "$PI4_LOCAL_QEMU_SERIAL_LOG"
}

launcher_framebuffer() {
  rm -f "$PI4_LOCAL_QEMU_FRAMEBUFFER_LOG" "$PI4_LOCAL_QEMU_FRAMEBUFFER_PPM" "$PI4_LOCAL_QEMU_MONITOR_SOCK"
  printf "Booting exact Pi 4 image and dumping the launcher framebuffer.\n"
  trap cleanup EXIT INT TERM
  run_qemu \
    -serial "file:$PI4_LOCAL_QEMU_FRAMEBUFFER_LOG" \
    -display vnc=127.0.0.1:8 \
    -monitor "unix:$PI4_LOCAL_QEMU_MONITOR_SOCK,server,nowait" \
    -no-reboot \
    -no-shutdown
  wait_for_monitor_socket "$PI4_LOCAL_QEMU_MONITOR_SOCK"
  sleep "$PI4_LOCAL_QEMU_SELECT_DELAY_SECONDS"
  printf 'screendump %s\nquit\n' "$PI4_LOCAL_QEMU_FRAMEBUFFER_PPM" | "$NC" -U "$PI4_LOCAL_QEMU_MONITOR_SOCK" >/dev/null 2>&1 || true
  wait "$qpid" >/dev/null 2>&1 || true
  qpid=""
  trap - EXIT INT TERM
  test -s "$PI4_LOCAL_QEMU_FRAMEBUFFER_LOG"
  test -s "$PI4_LOCAL_QEMU_FRAMEBUFFER_PPM"
  file "$PI4_LOCAL_QEMU_FRAMEBUFFER_PPM"
  grep -a -F -q "exec=OK path=/SYSTEM/INIT.ELF" "$PI4_LOCAL_QEMU_FRAMEBUFFER_LOG"
  grep -a -F -q "fbpresent=" "$PI4_LOCAL_QEMU_FRAMEBUFFER_LOG"
  grep -a -F -q "fbchange=" "$PI4_LOCAL_QEMU_FRAMEBUFFER_LOG"
  grep -a -F -q "pi4runtime=OK" "$PI4_LOCAL_QEMU_FRAMEBUFFER_LOG"
  grep -a -F -q "panic=NONE" "$PI4_LOCAL_QEMU_FRAMEBUFFER_LOG"
  grep -a -F -q "shutdown=NONE" "$PI4_LOCAL_QEMU_FRAMEBUFFER_LOG"
}

uart_select_app() {
  local app="$1"
  local key
  local port
  local log
  local path
  local appvfs

  case "$app" in
    doom)
      key=1
      port="$PI4_LOCAL_QEMU_DOOM_SELECT_PORT"
      log="$PI4_LOCAL_QEMU_DOOM_SERIAL_LOG"
      path=/APPS/DOOM/APP.ELF
      appvfs=0x000000000000000e/0x00000000464f4f4b
      ;;
    quake)
      key=2
      port="$PI4_LOCAL_QEMU_QUAKE_SELECT_PORT"
      log="$PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG"
      path=/APPS/QUAKE/APP.ELF
      appvfs=0x000000000000000f/0x00000000464f4f4b
      ;;
    *)
      echo "unknown Pi app selection '$app'" >&2
      exit 2
      ;;
  esac

  fifo="$PI4_BUILD_DIR/local-qemu-$app-uart.fifo"
  rm -f "$log" "$fifo"
  mkfifo "$fifo"
  printf "Booting exact Pi 4 image and selecting %s through the live UART input lane.\n" "$app"
  trap cleanup EXIT INT TERM
  run_qemu \
    -serial "tcp:127.0.0.1:$port,server,nowait" \
    -display none \
    -monitor none \
    -no-reboot \
    -no-shutdown
  sleep 2
  "$NC" 127.0.0.1 "$port" < "$fifo" > "$log" &
  ncpid=$!
  exec 3>"$fifo"
  sleep "$PI4_LOCAL_QEMU_SELECT_DELAY_SECONDS"
  printf '%s' "$key" >&3
  sleep "$PI4_LOCAL_QEMU_SELECT_SETTLE_SECONDS"
  exec 3>&-
  cleanup
  trap - EXIT INT TERM

  grep -a -F -q "path=$path" "$log"
  grep -a -F -q "pi4exec=OK" "$log"
  grep -a -F -q "pi4appvfs=$appvfs" "$log"
  grep -a -F -q "pi4preempt=OK" "$log"
  grep -a -F -q "pi4audio=OK" "$log"
  grep -a -F -q "pi4audiohw=USB-AUDIO" "$log"
  grep -a -F -q "panic=NONE" "$log"
  grep -a -F -q "shutdown=NONE" "$log"
  assert_pi4_audio_capture
  print_last_status_fields "$log"
}

require_qemu

case "$mode" in
  smoke)
    pi4_smoke
    ;;
  launcher-framebuffer)
    launcher_framebuffer
    ;;
  uart-select-doom)
    uart_select_app doom
    ;;
  uart-select-quake)
    uart_select_app quake
    ;;
  *)
    echo "unknown Pi QEMU mode '$mode'" >&2
    exit 2
    ;;
esac
