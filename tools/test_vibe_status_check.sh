#!/usr/bin/env sh
set -eu

ROOT="${ROOT:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}"
BUILD_DIR="${BUILD_DIR:-$ROOT/build}"
HOST_CC="${HOST_CC:-cc}"
CHECKER="$BUILD_DIR/vibe_status_check"

mkdir -p "$BUILD_DIR"
"$HOST_CC" -std=c99 -Wall -Wextra -Werror -O2 \
  "$ROOT/tools/vibe_status_check.c" -o "$CHECKER"

"$CHECKER" --repo-contract
"$CHECKER" --require-exec --require-preempt \
  "$ROOT/tests/fixtures/vm_status_krelhaz_ok.txt"

DEVICE_OK="$BUILD_DIR/vm_status_devices_ok.txt"
DEVICE_BAD="$BUILD_DIR/vm_status_devices_bad.txt"
cp "$ROOT/tests/fixtures/vm_status_krelhaz_ok.txt" "$DEVICE_OK"
{
  printf ' %s' 'inputqueue=00000004'
  printf ' %s' 'inputdepth=00000001:00000001'
  printf ' %s' 'inputstat=00000004:00000002:00000001:0000003F'
  printf ' %s' 'inputpolicy=00000001:0000003F'
  printf ' %s' 'inputdev=00000001:00000001'
  printf ' %s' 'inputdevices=00000002:00000003:0000001F:00000001:00000001'
  printf ' %s' 'inabi=0000000F/0000000F/00000008/00000004/00000000'
  printf ' %s' 'inputmods=00000003'
  printf ' %s' 'inputlast=00000020:00000002:00000002'
  printf ' %s' 'audio=SB16'
  printf ' %s' 'adev=00000001:00000001:0000000F'
  printf ' %s' 'pcmbuf=00001000:00000800:00000000:00000000'
  printf ' %s' 'pcmstream=00000002:50430001:00000001:00000040:00000040'
  printf ' %s' 'pcmqueue=00010000:00000040:00000000:00000000:00000000:00000040'
  printf ' %s' 'pcmpull=00000002:00000001:00000001'
  printf ' %s' 'pcmdma=00000001:00000000:00000000:00008000:00000000:00000FFF'
  printf ' %s' 'audabi=000001FF/000001FF/00000100/00000010'
  printf ' %s' 'execcopy=00000003/00000003/00000003/00089000/00082000/01000000/01001000/00000200/00000300'
  printf ' %s' 'vfsops=00000001/00000001/00000001/00000001/00000001/00000001/00000001/00000001/00000001/00000001'
  printf ' %s' 'vfsabi=000003FF/000003FF/00000200'
  printf ' %s' 'fatdyn=00000003/00000000/00000002/00000002/00000001/00000002/00000003/0000000E/00000000'
  printf ' %s' 'fatacct=0000D317/000027D8/0000FAEF/0000FAF0/00000000'
  printf ' %s' 'fatabi=000001FF/000001FF/00000100/00000002/00000000'
  printf ' %s' 'fb=LFB'
  printf ' %s' 'fbdev=00000001:00000002:00000003:00000001'
  printf ' %s' 'fbcap=00000017'
  printf ' %s' 'fbsrc=00000001:00000140:000000C8:00000140:000000F0:00000100:00000003'
  printf ' %s' 'fbacct=00000001:00000001:00000000:00000000:00000000:00000001:0000FA00:0000FA00:00000300'
  printf ' %s' 'fbabi=0000000F/0000000F/00000001/00000000/00000004'
  printf ' %s' 'fbpresent=00000002:00000001:00000001:00000000:00000003:00000004:00000002:00000140:000000C8'
  printf ' %s' 'fbinfo=00000001:00000003:00000004'
  printf ' %s' 'fbmmio=E0000000:00000080:00000380:00000000'
  printf ' %s' 'fbpolicy=ASP'
  printf ' %s' 'fbgeom=00000000:00000014:00000140:000000F0:00000001'
  printf ' %s\n' 'fbdirty=00000000:00000000:00000140:000000C8:00000001'
} >> "$DEVICE_OK"
"$CHECKER" --require-exec --require-preempt "$DEVICE_OK"
sed 's/inputstat=00000004:00000002:00000001:0000003F/inputstat=00000004:00000002:00000002:0000003F/' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt "$DEVICE_BAD" >/tmp/vibe-status-check-devices-bad.out 2>&1; then
  echo "vibe_status_check accepted inconsistent device status accounting" >&2
  cat /tmp/vibe-status-check-devices-bad.out >&2
  exit 1
fi
sed 's|inabi=0000000F/0000000F/00000008/00000004/00000000|inabi=0000000B/0000000F/00000008/00000004/00000000|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt "$DEVICE_BAD" >/tmp/vibe-status-check-inabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete generic input ABI proof" >&2
  cat /tmp/vibe-status-check-inabi-bad.out >&2
  exit 1
fi
sed 's|execcopy=00000003/00000003/00000003/00089000/00082000|execcopy=00000003/00000003/00000002/00089000/00082000|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt "$DEVICE_BAD" >/tmp/vibe-status-check-execcopy-bad.out 2>&1; then
  echo "vibe_status_check accepted unbalanced exec CR3 copy accounting" >&2
  cat /tmp/vibe-status-check-execcopy-bad.out >&2
  exit 1
fi
sed 's|vfsabi=000003FF/000003FF/00000200|vfsabi=000003FE/000003FF/00000200|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt "$DEVICE_BAD" >/tmp/vibe-status-check-vfsabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete generic VFS ABI proof" >&2
  cat /tmp/vibe-status-check-vfsabi-bad.out >&2
  exit 1
fi
sed 's|fatabi=000001FF/000001FF/00000100/00000002/00000000|fatabi=000001BF/000001FF/00000100/00000002/00000000|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt "$DEVICE_BAD" >/tmp/vibe-status-check-fatabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete generic FAT operation proof" >&2
  cat /tmp/vibe-status-check-fatabi-bad.out >&2
  exit 1
fi
sed 's|audabi=000001FF/000001FF/00000100/00000010|audabi=000001DF/000001FF/00000100/00000010|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt "$DEVICE_BAD" >/tmp/vibe-status-check-audabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete generic audio ABI proof" >&2
  cat /tmp/vibe-status-check-audabi-bad.out >&2
  exit 1
fi
sed 's|fbabi=0000000F/0000000F/00000001/00000000/00000004|fbabi=0000000B/0000000F/00000001/00000000/00000004|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt "$DEVICE_BAD" >/tmp/vibe-status-check-fbabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete generic framebuffer ABI proof" >&2
  cat /tmp/vibe-status-check-fbabi-bad.out >&2
  exit 1
fi
sed 's|preemptabi=000001FF/000001FF/00000100/00000001/00000001|preemptabi=000001DF/000001FF/00000100/00000001/00000001|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt "$DEVICE_BAD" >/tmp/vibe-status-check-preemptabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete timer-preemption ABI proof" >&2
  cat /tmp/vibe-status-check-preemptabi-bad.out >&2
  exit 1
fi
sed 's|khabi=000003FF/000003FF/00000200/00000002/00000001|khabi=000001FF/000003FF/00000100/00000002/00000001|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt "$DEVICE_BAD" >/tmp/vibe-status-check-khabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete higher-half kernel ABI proof" >&2
  cat /tmp/vibe-status-check-khabi-bad.out >&2
  exit 1
fi
sed 's|krelabi=000003FF/000003FF/00000200/00000001/00000001|krelabi=000001FF/000003FF/00000100/00000001/00000001|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt "$DEVICE_BAD" >/tmp/vibe-status-check-krelabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete relocation-directory ABI proof" >&2
  cat /tmp/vibe-status-check-krelabi-bad.out >&2
  exit 1
fi

for bad in \
  vm_status_krelhaz_bad_identity_return.txt \
  vm_status_krelhaz_bad_high_return.txt \
  vm_status_krelhaz_bad_mismatch.txt
do
  if "$CHECKER" "$ROOT/tests/fixtures/$bad" >/tmp/vibe-status-check-bad.out 2>&1; then
    echo "vibe_status_check accepted bad fixture: $bad" >&2
    cat /tmp/vibe-status-check-bad.out >&2
    exit 1
  fi
done

rm -f /tmp/vibe-status-check-bad.out
rm -f /tmp/vibe-status-check-devices-bad.out
rm -f /tmp/vibe-status-check-inabi-bad.out
rm -f /tmp/vibe-status-check-execcopy-bad.out
rm -f /tmp/vibe-status-check-vfsabi-bad.out
rm -f /tmp/vibe-status-check-fatabi-bad.out
rm -f /tmp/vibe-status-check-audabi-bad.out
rm -f /tmp/vibe-status-check-fbabi-bad.out
rm -f /tmp/vibe-status-check-preemptabi-bad.out
rm -f /tmp/vibe-status-check-khabi-bad.out
rm -f /tmp/vibe-status-check-krelabi-bad.out
echo "vibe_status_check self-test OK"
