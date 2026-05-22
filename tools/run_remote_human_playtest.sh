#!/usr/bin/env bash
set -euo pipefail

cat >&2 <<'EOF'
The old guided human-playtest bundle wrapper has been retired.

Use the maintained cloud path instead:

  ./tools/play_now_codespaces.sh --repo jadentripp/vibe-os --ref main

For evidence, keep only guest status text and short notes from the disposable
host. Do not store WADs, disk images, screenshots, raw audio, VM logs, tokens,
or one-time codes in git.
EOF
exit 1
