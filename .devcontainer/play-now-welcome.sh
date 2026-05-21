#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
vibe-os Doom cloud play is ready in this Codespace.

Start the real vibe-os QEMU boot here, not on the Mac:
  ./tools/play_now_remote.sh --preflight --require-novnc
  ./tools/play_now_remote.sh --require-novnc

Open the forwarded private port 6080 URL and add:
  /vnc.html?autoconnect=1

Default 2-core Codespaces can play Doom, but noVNC may stutter while QEMU and
the first build share CPU. A 4-core+ Codespace is the smoother target for
longer human playtests.

If play slows down, open a second Codespaces terminal and run:
  /tmp/vibe-os-play-now-diagnostics.sh
  /tmp/vibe-os-play-now-diagnostics.sh --json

That helper prints process/load and filtered OS status-log lines only; it does
not dump environment variables.

Controls: arrows move/turn, Ctrl fires, Space uses, Escape opens menu.
EOF
