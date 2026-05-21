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
the first build share CPU.

Controls: arrows move/turn, Ctrl fires, Space uses, Escape opens menu.
EOF
