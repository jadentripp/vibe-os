#!/usr/bin/env sh
set -eu

ROOT="${ROOT:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}"
out="${1:-}"

usage() {
  echo "usage: tools/build_pi4_kernel_source.sh output.S input1.S [input2.S ...]" >&2
}

if [ -z "$out" ] || [ "$#" -lt 2 ]; then
  usage
  exit 2
fi

shift
{
  for src do
    case "$src" in
      /*) include_path="$src" ;;
      *) include_path="$ROOT/$src" ;;
    esac
    printf '#include "%s"\n' "$include_path"
  done
} > "$out"
