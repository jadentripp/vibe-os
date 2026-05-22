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
echo "vibe_status_check self-test OK"
