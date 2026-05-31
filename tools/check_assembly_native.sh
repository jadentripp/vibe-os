#!/usr/bin/env sh
set -eu

ROOT="${ROOT:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}"
MAKE="${MAKE:-make}"

recipes="$("$MAKE" --no-print-directory -C "$ROOT" -B -n ALLOW_LOCAL_VM=0 DOOM_WAD= build-only)"

while IFS= read -r path; do
  printf "%s\n" "$recipes" | awk -v path="$path" '
    index($0, " " path " ") &&
      $0 ~ /(^|[[:space:]])-f[[:space:]]+elf32([[:space:]]|$)/ &&
      $0 ~ /[[:space:]]-o[[:space:]]/ { found = 1 }
    END { exit(found ? 0 : 1) }
  ' || {
    printf "Guest assembly build audit missing NASM-owned elf32 recipe for %s\n" "$path" >&2
    exit 1
  }
done <<'EOF'
kernel/c_runtime_probe.asm
user/probe.asm
user/launcher_crt0.asm
user/launcher_main.asm
user/runtime.asm
user/abi_probe.asm
user/launcher.asm
user/libc.asm
doom_port/input.asm
doom_port/music.asm
doom_port/platform.asm
doom_port/save_debug.asm
doom_port/start.asm
quake_port/cd.asm
quake_port/input.asm
quake_port/math.asm
quake_port/setjmp.asm
quake_port/snd.asm
quake_port/start.asm
quake_port/sys.asm
quake_port/vid.asm
EOF

bad_guest_c="$(printf "%s\n" "$recipes" | grep -E ' -c (kernel|user|doom_port|quake_port)/.*\.c|clang .* (kernel|user|doom_port|quake_port)/.*\.c' || true)"
if [ -n "$bad_guest_c" ]; then
  printf "Project-owned C is still compiled into guest artifacts:\n%s\n" "$bad_guest_c" >&2
  exit 1
fi

while IFS= read -r path; do
  if [ -e "$ROOT/$path" ]; then
    printf "Legacy project-owned guest C source still exists: %s\n" "$path" >&2
    exit 1
  fi
done <<'EOF'
kernel/c_runtime_probe.c
user/probe.c
user/abi_probe.c
user/runtime.c
user/libc.c
doom_port/input.c
doom_port/music.c
doom_port/platform.c
doom_port/save_debug.c
doom_port/start.c
quake_port/cd.c
quake_port/input.c
quake_port/math.c
quake_port/setjmp.c
quake_port/snd.c
quake_port/start.c
quake_port/sys.c
quake_port/vid.c
EOF

printf "Assembly-native guest build audit OK: project-owned guest artifacts are NASM-owned.\n"
