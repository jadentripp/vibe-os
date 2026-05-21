#!/usr/bin/env bash
set -euo pipefail

PUBLIC_SHAREWARE_WAD_GZ_URL="${PUBLIC_SHAREWARE_WAD_GZ_URL:-https://archive.org/download/wadarchive/DATA/5b.zip/5b%2F2e249b9c5133ec987b3ea77596381dc0d6bc1d%2F5b2e249b9c5133ec987b3ea77596381dc0d6bc1d.wad.gz}"
DOOM_WAD_URL="${DOOM_WAD_URL:-$PUBLIC_SHAREWARE_WAD_GZ_URL}"
WAD_PATH="${WAD_PATH:-/tmp/vibe-os-DOOM1.WAD}"
VNC_DISPLAY="${VNC_DISPLAY:-1}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
NOVNC_WEB_ROOT="${NOVNC_WEB_ROOT:-}"
PLAY_BUILD_DIR="${PLAY_BUILD_DIR:-build/play-now}"
DIAGNOSTICS_SCRIPT="${DIAGNOSTICS_SCRIPT:-/tmp/vibe-os-play-now-diagnostics.sh}"
STOP_SCRIPT="${STOP_SCRIPT:-/tmp/vibe-os-play-now-stop.sh}"
PLAY_NOW_PID_FILE="${PLAY_NOW_PID_FILE:-/tmp/vibe-os-play-now.pid}"
PLAY_NOW_PORT_FILE="${PLAY_NOW_PORT_FILE:-/tmp/vibe-os-play-now.novnc-port}"
VNC_PORT=""
NOVNC_WEB_ROOT_RESOLVED=""
NOVNC_WEB_ROOTS=(
  "/usr/share/novnc"
  "/usr/local/share/novnc"
  "/opt/homebrew/share/novnc"
)

usage() {
  cat <<'EOF'
Usage: tools/play_now_remote.sh [--preflight|--dry-run] [--require-novnc]

Run on a disposable remote Linux host or GitHub Codespace. The default path
fetches the public shareware WAD into /tmp, builds the disk image, exposes QEMU
over loopback-only VNC, and starts a noVNC bridge when available.

Options:
  --preflight, --dry-run  Check host safety and dependencies, then exit before
                         fetching a WAD, building, or launching QEMU.
  --require-novnc        Fail preflight if noVNC/websockify is unavailable.
  -h, --help             Show this help.
EOF
}

fail_remote() {
  echo "play-now remote failed: $*" >&2
  exit 1
}

validate_tcp_port() {
  local name="$1"
  local value="$2"

  case "$value" in
    ''|*[!0-9]*)
      fail_remote "$name must be a TCP port number, got '$value'"
      ;;
  esac
  if [ "$value" -lt 1 ] || [ "$value" -gt 65535 ]; then
    fail_remote "$name must be between 1 and 65535, got '$value'"
  fi
}

validate_vnc_display() {
  local value="$1"
  local display

  case "$value" in
    ''|*[!0-9]*)
      fail_remote "VNC_DISPLAY must be a non-negative integer, got '$value'"
      ;;
  esac
  display=$((10#$value))
  if [ "$display" -gt 59635 ]; then
    fail_remote "VNC_DISPLAY must map to a TCP port between 5900 and 65535, got '$value'"
  fi
  # VNC_PORT is the validated form of 127.0.0.1:$((5900 + VNC_DISPLAY)).
  VNC_PORT=$((5900 + display))
}

loopback_port_in_use() {
  python3 - "$1" <<'PY'
import socket
import sys

port = int(sys.argv[1])
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    sock.bind(("127.0.0.1", port))
except OSError:
    sys.exit(0)
finally:
    sock.close()
sys.exit(1)
PY
}

ensure_loopback_port_free() {
  local label="$1"
  local port="$2"

  if loopback_port_in_use "$port"; then
    fail_remote "$label port 127.0.0.1:$port is already in use; stop the old remote play session or choose another port"
  fi
}

resolve_novnc_web_root() {
  local root

  if [ -n "$NOVNC_WEB_ROOT" ]; then
    [ -d "$NOVNC_WEB_ROOT" ] || fail_remote "NOVNC_WEB_ROOT does not exist: $NOVNC_WEB_ROOT"
    printf "%s\n" "$NOVNC_WEB_ROOT"
    return 0
  fi

  for root in "${NOVNC_WEB_ROOTS[@]}"; do
    if [ -d "$root" ]; then
      printf "%s\n" "$root"
      return 0
    fi
  done
  return 0
}

ensure_wad_path_outside_repo() {
  python3 - "$WAD_PATH" <<'PY'
from pathlib import Path
import subprocess
import sys

wad_path = Path(sys.argv[1]).expanduser().resolve()
try:
    repo_root = Path(
        subprocess.check_output(
            ["git", "rev-parse", "--show-toplevel"],
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    ).resolve()
except Exception:
    repo_root = Path.cwd().resolve()

try:
    wad_path.relative_to(repo_root)
except ValueError:
    sys.exit(0)

print(
    f"WAD_PATH must stay outside the git checkout; refusing repo-local path: {wad_path}",
    file=sys.stderr,
)
sys.exit(1)
PY
}

write_diagnostics_helper() {
  local repo_dir
  local play_build_abs
  local repo_dir_q
  local play_build_abs_q
  local diagnostics_script_q
  local stop_script_q
  local pid_file_q
  local port_file_q

  repo_dir="$(pwd)"
  mkdir -p "$PLAY_BUILD_DIR"
  play_build_abs="$(cd "$PLAY_BUILD_DIR" && pwd)"
  printf -v repo_dir_q '%q' "$repo_dir"
  printf -v play_build_abs_q '%q' "$play_build_abs"
  printf -v diagnostics_script_q '%q' "$DIAGNOSTICS_SCRIPT"
  printf -v stop_script_q '%q' "$STOP_SCRIPT"
  printf -v pid_file_q '%q' "$PLAY_NOW_PID_FILE"
  printf -v port_file_q '%q' "$PLAY_NOW_PORT_FILE"

  cat >"$DIAGNOSTICS_SCRIPT" <<EOF_DIAGNOSTICS
#!/usr/bin/env bash
set -euo pipefail

repo_dir=$repo_dir_q
play_build_dir=$play_build_abs_q
diagnostics_script=$diagnostics_script_q
stop_script=$stop_script_q
pid_file=$pid_file_q
log_file="/tmp/vibe-os-play-now.log"
port_file=$port_file_q
serial_log="\$play_build_dir/serial.log"
novnc_log="\$play_build_dir/novnc.log"

JSON_OUTPUT=0
case "\${1:-}" in
  "")
    ;;
  --json)
    JSON_OUTPUT=1
    ;;
  -h|--help)
    cat <<'EOF_HELP'
Usage: /tmp/vibe-os-play-now-diagnostics.sh [--json]

Print status-only remote play diagnostics. The text view is for humans; --json
emits a machine-readable long-session snapshot without environment variables,
WAD data, pixels, disk images, or raw audio.
EOF_HELP
    exit 0
    ;;
  *)
    echo "unknown diagnostics argument: \$1" >&2
    exit 2
    ;;
esac

redact_stream() {
  sed -E \\
    -e 's/((GH|GITHUB|CODESPACES|VSCODE|ACTIONS|NPM|NODE_AUTH|DOCKER|AWS|AZURE|GOOGLE|OPENAI|ANTHROPIC|GEMINI|HF|HUGGINGFACE|VIBE)[A-Z0-9_]*_(TOKEN|KEY|SECRET|PASSWORD|CREDENTIAL|AUTH)[A-Z0-9_]*=)[^[:space:]]+/\\1[redacted]/g' \\
    -e 's/((GH|GITHUB|CODESPACES|VSCODE|ACTIONS|NPM|NODE_AUTH|DOCKER|AWS|AZURE|GOOGLE|OPENAI|ANTHROPIC|GEMINI|HF|HUGGINGFACE|VIBE)[A-Z0-9_]*=)(gh[pousr]_[A-Za-z0-9_]+)/\\1[redacted]/g' \\
    -e 's/(Authorization: *(Bearer|token) +)[^[:space:]]+/\\1[redacted]/Ig' \\
    -e 's/((access_token|token|signature|X-Amz-Signature|X-Amz-Credential)=)[^&[:space:]]+/\\1[redacted]/Ig'
}

if [ "\$JSON_OUTPUT" = "1" ]; then
  python3 - "\$repo_dir" "\$play_build_dir" "\$pid_file" "\$port_file" "\$log_file" "\$serial_log" "\$novnc_log" <<'PY_JSON'
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

repo_dir, play_build_dir, pid_file, port_file, log_file, serial_log, novnc_log = [
    Path(arg) for arg in sys.argv[1:]
]

STATUS_FIELD_RE = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")
HEX8_RE = re.compile(r"^[0-9A-Fa-f]{8}$")
COUNTERS = (
    "gtic",
    "leveltime",
    "doompresent",
    "dtick",
    "preempt",
    "pirq",
    "pattempt",
    "pskip",
    "puser",
    "inputqueue",
    "inputpoll",
    "audioirq",
    "refill",
    "musicpos",
    "mixunder",
    "musicunder",
    "musicdrops",
)


def read_text(path):
    try:
        return path.read_text(errors="replace").strip()
    except OSError:
        return ""


def parse_cpu_range_list(raw_value):
    count = 0
    for chunk in raw_value.split(","):
        part = chunk.strip()
        if not part:
            continue
        if "-" in part:
            start_raw, end_raw = part.split("-", 1)
            if not start_raw.isdigit() or not end_raw.isdigit():
                return None
            start = int(start_raw, 10)
            end = int(end_raw, 10)
            if end < start:
                return None
            count += end - start + 1
        elif part.isdigit():
            count += 1
        else:
            return None
    return count or None


def effective_cpu_count():
    candidates = [os.cpu_count()]
    root = Path("/sys/fs/cgroup")
    cpu_max = read_text(root / "cpu.max")
    if cpu_max:
        parts = cpu_max.split()
        if len(parts) >= 2 and parts[0] != "max":
            try:
                quota = int(parts[0], 10)
                period = int(parts[1], 10)
            except ValueError:
                pass
            else:
                if quota > 0 and period > 0:
                    candidates.append(max(1, (quota + period - 1) // period))
    quota_raw = read_text(root / "cpu" / "cpu.cfs_quota_us")
    period_raw = read_text(root / "cpu" / "cpu.cfs_period_us")
    if quota_raw and period_raw:
        try:
            quota = int(quota_raw, 10)
            period = int(period_raw, 10)
        except ValueError:
            pass
        else:
            if quota > 0 and period > 0:
                candidates.append(max(1, (quota + period - 1) // period))
    for relative in ("cpuset.cpus.effective", "cpuset.cpus", "cpuset/cpuset.cpus"):
        parsed = parse_cpu_range_list(read_text(root / relative))
        if parsed:
            candidates.append(parsed)
    positive = [candidate for candidate in candidates if candidate and candidate > 0]
    return min(positive) if positive else None


def load_average():
    try:
        return tuple(float(value) for value in os.getloadavg())
    except (AttributeError, OSError):
        return None


def parse_fields(line):
    fields = {}
    for match in STATUS_FIELD_RE.finditer(line):
        fields.setdefault(match.group(1), match.group(2))
    return fields


def hex_value(fields, name):
    value = fields.get(name)
    if value is None or not HEX8_RE.fullmatch(value):
        return None
    return int(value, 16)


def tuple_hex(fields, name, parts):
    raw = fields.get(name)
    if raw is None:
        return None
    chunks = raw.split(":")
    if len(chunks) != parts or any(not HEX8_RE.fullmatch(chunk) for chunk in chunks):
        return None
    return tuple(int(chunk, 16) for chunk in chunks)


def fmt_hex(value):
    return f"{value & 0xFFFFFFFF:08X}"


def fmt_delta(value):
    if value is None:
        return None
    if value < 0:
        return f"-{abs(value):08X}"
    return fmt_hex(value)


def counter_summary(name, first, final):
    start = hex_value(first, name)
    end = hex_value(final, name)
    if start is None or end is None:
        return {"available": False}
    delta = end - start
    return {
        "available": True,
        "first": fmt_hex(start),
        "final": fmt_hex(end),
        "delta": delta,
        "delta_hex": fmt_delta(delta),
    }


def process_summary():
    pid_raw = read_text(pid_file)
    summary = {
        "pid_file": str(pid_file),
        "pid": int(pid_raw) if pid_raw.isdigit() else None,
        "running": False,
        "elapsed_seconds": None,
        "pcpu": None,
        "pmem": None,
        "command": None,
    }
    pid = summary["pid"]
    if pid is None:
        return summary
    try:
        os.kill(pid, 0)
        summary["running"] = True
    except PermissionError:
        summary["running"] = True
    except OSError:
        return summary
    ps = subprocess.run(
        ["ps", "-p", str(pid), "-o", "etimes=,pcpu=,pmem=,comm="],
        check=False,
        capture_output=True,
        text=True,
    )
    parts = ps.stdout.strip().split(None, 3)
    if len(parts) >= 4:
        try:
            summary["elapsed_seconds"] = int(parts[0])
        except ValueError:
            pass
        try:
            summary["pcpu"] = float(parts[1])
        except ValueError:
            pass
        try:
            summary["pmem"] = float(parts[2])
        except ValueError:
            pass
        summary["command"] = parts[3]
    return summary


def cadence_summary():
    if not serial_log.exists() or serial_log.stat().st_size == 0:
        return {
            "serial_log_ready": False,
            "samples": 0,
            "diagnosis": "serial-log-not-ready",
            "counters": {},
        }
    samples = []
    for line in serial_log.read_text(errors="replace").splitlines():
        fields = parse_fields(line)
        if "gtic" in fields and "leveltime" in fields:
            samples.append(fields)
    if len(samples) < 2:
        return {
            "serial_log_ready": True,
            "samples": len(samples),
            "diagnosis": "not-enough-status-samples",
            "counters": {},
        }

    first = samples[0]
    final = samples[-1]
    counters = {name: counter_summary(name, first, final) for name in COUNTERS}
    deltas = {
        name: counters[name].get("delta")
        if counters[name].get("available")
        else None
        for name in COUNTERS
    }
    input_first = tuple_hex(first, "inputdepth", 2)
    input_final = tuple_hex(final, "inputdepth", 2)
    music_first = tuple_hex(first, "musicpull", 2)
    music_final = tuple_hex(final, "musicpull", 2)

    inputdepth = {"available": False}
    input_drop_delta = None
    if input_first is not None and input_final is not None:
        input_drop_delta = input_final[1] - input_first[1]
        inputdepth = {
            "available": True,
            "queued_first": fmt_hex(input_first[0]),
            "queued_final": fmt_hex(input_final[0]),
            "dropped_delta": input_drop_delta,
            "dropped_delta_hex": fmt_delta(input_drop_delta),
        }

    musicpull = {"available": False}
    music_refill_delta = None
    if music_first is not None and music_final is not None:
        music_refill_delta = music_final[1] - music_first[1]
        musicpull = {
            "available": True,
            "requests_delta": music_final[0] - music_first[0],
            "requests_delta_hex": fmt_delta(music_final[0] - music_first[0]),
            "refills_delta": music_refill_delta,
            "refills_delta_hex": fmt_delta(music_refill_delta),
        }

    if any(deltas[name] is None for name in ("gtic", "leveltime", "doompresent", "dtick")):
        diagnosis = "cadence-evidence-gap"
        lane = "core-doom-frame"
    elif any((deltas[name] or 0) <= 0 for name in ("gtic", "leveltime", "doompresent", "dtick")):
        diagnosis = "guest-cadence-stalled"
        lane = "core-doom-frame"
    elif any(deltas[name] is None for name in ("pirq", "preempt", "puser")):
        diagnosis = "cadence-evidence-gap"
        lane = "scheduler"
    elif any((deltas[name] or 0) <= 0 for name in ("pirq", "preempt", "puser")):
        diagnosis = "scheduler-cadence-stalled"
        lane = "scheduler"
    elif input_drop_delta is not None and input_drop_delta > 0:
        diagnosis = "input-loss-observed"
        lane = "input"
    elif any((deltas[name] or 0) > 0 for name in ("mixunder", "musicunder", "musicdrops")):
        diagnosis = "audio-pressure-observed"
        lane = "audio"
    elif any(deltas[name] is None for name in ("audioirq", "refill", "musicpos")) or music_refill_delta is None:
        diagnosis = "cadence-evidence-gap"
        lane = "audio"
    elif any((deltas[name] or 0) <= 0 for name in ("audioirq", "refill", "musicpos")) or music_refill_delta <= 0:
        diagnosis = "audio-cadence-stalled"
        lane = "audio"
    else:
        diagnosis = "remote-presentation-throughput-likely"
        lane = "noVNC/QEMU-display"

    return {
        "serial_log_ready": True,
        "samples": len(samples),
        "diagnosis": diagnosis,
        "primary_lane": lane,
        "counters": counters,
        "inputdepth": inputdepth,
        "musicpull": musicpull,
    }


host_cpus = effective_cpu_count()
loads = load_average()
load_per_cpu = None
pressure = False
if host_cpus and loads is not None:
    load_per_cpu = round(loads[0] / host_cpus, 2)
    pressure = loads[0] >= host_cpus

cadence = cadence_summary()
process = process_summary()
recommendations = []
if host_cpus is not None and host_cpus <= 2:
    recommendations.append("Prefer a 4+ CPU Codespace or cloud VM for longer noVNC play.")
if pressure:
    recommendations.append("Host load is saturated; compare another status snapshot after 60s before changing OS runtime code.")
if cadence["diagnosis"] == "remote-presentation-throughput-likely":
    recommendations.append("OS-side cadence advanced; inspect CPU quota/load and noVNC/QEMU display throughput first.")
elif cadence["diagnosis"] in {"serial-log-not-ready", "not-enough-status-samples"}:
    recommendations.append("Wait for more serial status samples, then rerun this helper.")
else:
    recommendations.append("Use the primary_lane field to rerun only the matching proof lane.")

print(
    json.dumps(
        {
            "schema": "vibe-os-play-now-diagnostics-v1",
            "generated_at_utc": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
            "repo": str(repo_dir),
            "play_build_dir": str(play_build_dir),
            "artifact_policy": {
                "status_only": True,
                "contains_environment": False,
                "contains_wad_data": False,
                "contains_disk_image": False,
                "contains_pixels": False,
                "contains_raw_audio": False,
            },
            "host": {
                "cpus": host_cpus,
                "load_average": {
                    "one_minute": round(loads[0], 2),
                    "five_minute": round(loads[1], 2),
                    "fifteen_minute": round(loads[2], 2),
                }
                if loads is not None
                else None,
                "load_per_cpu_1m": load_per_cpu,
                "load_saturated": pressure,
            },
            "novnc": {
                "port": read_text(port_file) or None,
                "log_ready": novnc_log.exists() and novnc_log.stat().st_size > 0,
            },
            "logs": {
                "launcher_log_ready": log_file.exists() and log_file.stat().st_size > 0,
                "serial_log_ready": cadence["serial_log_ready"],
                "novnc_log_ready": novnc_log.exists() and novnc_log.stat().st_size > 0,
            },
            "process": process,
            "cadence": cadence,
            "recommendations": recommendations,
        },
        indent=2,
        sort_keys=True,
    )
)
PY_JSON
  exit 0
fi

echo "vibe-os play-now diagnostics"
echo "repo: \$repo_dir"
echo "diagnostics helper: \$diagnostics_script"
echo "stop helper: \$stop_script"
host_cpus="\$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || echo unknown)"
echo "host CPUs: \$host_cpus"
if [ -r /proc/loadavg ]; then
  loadavg="\$(cut -d' ' -f1-3 /proc/loadavg)"
  echo "loadavg: \$loadavg"
  python3 - "\$host_cpus" "\$loadavg" <<'PY_LOAD' || true
import sys

try:
    cpus = int(sys.argv[1])
    one_minute = float(sys.argv[2].split()[0])
except (IndexError, ValueError):
    raise SystemExit(0)

if cpus <= 0:
    raise SystemExit(0)

print(f"load per CPU: 1m={one_minute / cpus:.2f}")
if cpus <= 2 and one_minute >= cpus:
    print(
        "slowdown warning: 1m load is at/above available CPUs; "
        "noVNC/QEMU can degrade under sustained contention"
    )
PY_LOAD
fi
echo "performance hint: 2-core hosts can stutter under QEMU/noVNC; prefer 4+ cloud CPUs for interactive Doom."
echo "slowdown snapshot tip: rerun this helper about 60s later and compare status deltas before changing OS runtime code."
if [ -s "\$port_file" ]; then
  echo "noVNC port: \$(cat "\$port_file" 2>/dev/null || true)"
fi

if [ -s "\$pid_file" ]; then
  pid="\$(cat "\$pid_file" 2>/dev/null || true)"
  if [ -n "\$pid" ] && kill -0 "\$pid" 2>/dev/null; then
    echo "play-now pid: \$pid (running)"
    ps -p "\$pid" -o pid=,etime=,pcpu=,pmem=,comm= 2>/dev/null | sed 's/^/play-now process: /' || true
  else
    echo "play-now pid: \${pid:-unknown} (not running)"
  fi
else
  echo "play-now pid: missing"
fi

echo
echo "status cadence summary (safe serial-log subset):"
if [ -s "\$serial_log" ]; then
  python3 - "\$serial_log" <<'PY_DIAGNOSTICS' || true
import re
import sys
from pathlib import Path

STATUS_FIELD_RE = re.compile(r"(?:^|\s)([A-Za-z][A-Za-z0-9_]*)=([^\s]+)")
HEX8_RE = re.compile(r"^[0-9A-Fa-f]{8}$")
COUNTERS = (
    "gtic",
    "leveltime",
    "doompresent",
    "dtick",
    "preempt",
    "pirq",
    "pattempt",
    "pskip",
    "puser",
    "inputqueue",
    "inputpoll",
    "audioirq",
    "refill",
    "musicpos",
    "mixunder",
    "musicunder",
    "musicdrops",
)


def parse_fields(line):
    fields = {}
    for match in STATUS_FIELD_RE.finditer(line):
        fields.setdefault(match.group(1), match.group(2))
    return fields


def hex_value(fields, name):
    value = fields.get(name)
    if value is None or not HEX8_RE.fullmatch(value):
        return None
    return int(value, 16)


def tuple_hex(fields, name, parts):
    raw = fields.get(name)
    if raw is None:
        return None
    chunks = raw.split(":")
    if len(chunks) != parts or any(not HEX8_RE.fullmatch(chunk) for chunk in chunks):
        return None
    return tuple(int(chunk, 16) for chunk in chunks)


def fmt_hex(value):
    return f"{value & 0xFFFFFFFF:08X}"


def fmt_delta(value):
    if value is None:
        return "<missing>"
    if value < 0:
        return f"-{abs(value):08X}"
    return fmt_hex(value)


def counter_line(name, first, final):
    start = hex_value(first, name)
    end = hex_value(final, name)
    if start is None or end is None:
        return f"{name}: <missing>"
    return f"{name}: first={fmt_hex(start)} final={fmt_hex(end)} delta={fmt_delta(end - start)}"


path = Path(sys.argv[1])
lines = path.read_text(errors="replace").splitlines()
samples = []
for line in lines:
    fields = parse_fields(line)
    if "gtic" in fields and "leveltime" in fields:
        samples.append(fields)

if len(samples) < 2:
    print("cadence: not enough status samples yet")
    raise SystemExit(0)

first = samples[0]
final = samples[-1]
print(f"samples: {len(samples)}")
for name in COUNTERS:
    print(counter_line(name, first, final))

input_first = tuple_hex(first, "inputdepth", 2)
input_final = tuple_hex(final, "inputdepth", 2)
music_first = tuple_hex(first, "musicpull", 2)
music_final = tuple_hex(final, "musicpull", 2)
if input_first is not None and input_final is not None:
    print(
        "inputdepth: "
        f"queued={fmt_hex(input_first[0])}->{fmt_hex(input_final[0])} "
        f"dropped_delta={fmt_delta(input_final[1] - input_first[1])}"
    )
else:
    print("inputdepth: <missing>")
if music_first is not None and music_final is not None:
    print(
        "musicpull: "
        f"requests_delta={fmt_delta(music_final[0] - music_first[0])} "
        f"refills_delta={fmt_delta(music_final[1] - music_first[1])}"
    )
else:
    print("musicpull: <missing>")

deltas = {name: None for name in COUNTERS}
for name in COUNTERS:
    start = hex_value(first, name)
    end = hex_value(final, name)
    if start is not None and end is not None:
        deltas[name] = end - start

input_drop_delta = None
if input_first is not None and input_final is not None:
    input_drop_delta = input_final[1] - input_first[1]
music_refill_delta = None
if music_first is not None and music_final is not None:
    music_refill_delta = music_final[1] - music_first[1]

if any(deltas[name] is None for name in ("gtic", "leveltime", "doompresent", "dtick")):
    diagnosis = "cadence-evidence-gap: core Doom/frame counters are missing"
elif any((deltas[name] or 0) <= 0 for name in ("gtic", "leveltime", "doompresent", "dtick")):
    diagnosis = "guest-cadence-stalled: Doom/frame/timer counters did not all advance"
elif any(deltas[name] is None for name in ("pirq", "preempt", "puser")):
    diagnosis = "cadence-evidence-gap: scheduler counters are missing"
elif any((deltas[name] or 0) <= 0 for name in ("pirq", "preempt", "puser")):
    diagnosis = "scheduler-cadence-stalled: timer/preemption/user IRQ counters did not all advance"
elif input_drop_delta is not None and input_drop_delta > 0:
    diagnosis = "input-loss-observed: inputdepth dropped counter increased"
elif any((deltas[name] or 0) > 0 for name in ("mixunder", "musicunder", "musicdrops")):
    diagnosis = "audio-pressure-observed: audio safety counters increased"
elif any(deltas[name] is None for name in ("audioirq", "refill", "musicpos")) or music_refill_delta is None:
    diagnosis = "cadence-evidence-gap: audio cadence counters are missing"
elif any((deltas[name] or 0) <= 0 for name in ("audioirq", "refill", "musicpos")) or music_refill_delta <= 0:
    diagnosis = "audio-cadence-stalled: SB16/music counters did not all advance"
else:
    diagnosis = "remote-presentation-throughput-likely: OS-side cadence advanced; inspect CPU quota/load and noVNC/QEMU display throughput"
print(f"diagnosis: {diagnosis}")
PY_DIAGNOSTICS
else
  echo "serial log not ready: \$serial_log"
fi

echo
echo "recent OS status lines (safe serial-log subset):"
if [ -s "\$serial_log" ]; then
  grep -E 'panic=|doom=|doomrun=|gameplay=|inputdepth=|musicbuf=|musicpull=|mixunder=|dtick=|preempt=|doompresent|sfxmix=|sfxdma=|musicq=|musicmix=|musicstream=|audio=|timer=|keyboard=|mouse=' "\$serial_log" \\
    | tail -n "\${VIBE_DIAG_LINES:-120}" || true
else
  echo "serial log not ready: \$serial_log"
fi

echo
echo "recent play launcher log:"
if [ -s "\$log_file" ]; then
  tail -n 80 "\$log_file" | redact_stream || true
else
  echo "play launcher log not ready: \$log_file"
fi

echo
echo "recent noVNC log:"
if [ -s "\$novnc_log" ]; then
  tail -n 40 "\$novnc_log" | redact_stream || true
else
  echo "noVNC log not ready: \$novnc_log"
fi
EOF_DIAGNOSTICS
  chmod +x "$DIAGNOSTICS_SCRIPT"

  cat >"$STOP_SCRIPT" <<EOF_STOP
#!/usr/bin/env bash
set -euo pipefail

pid_file=$pid_file_q
port_file=$port_file_q
log_file="/tmp/vibe-os-play-now.log"

if [ ! -s "\$pid_file" ]; then
  echo "vibe-os play-now is not running: missing \$pid_file"
  rm -f "\$port_file"
  exit 0
fi

pid="\$(cat "\$pid_file" 2>/dev/null || true)"
if [ -z "\$pid" ] || ! kill -0 "\$pid" 2>/dev/null; then
  echo "vibe-os play-now is not running: stale pid \${pid:-unknown}"
  rm -f "\$pid_file" "\$port_file"
  exit 0
fi

echo "stopping vibe-os play-now pid=\$pid"
kill "\$pid" 2>/dev/null || true
for _ in 1 2 3 4 5 6 7 8 9 10; do
  if ! kill -0 "\$pid" 2>/dev/null; then
    rm -f "\$pid_file" "\$port_file"
    echo "vibe-os play-now stopped"
    exit 0
  fi
  sleep 1
done

echo "vibe-os play-now pid=\$pid still running after TERM; inspect \$log_file before deleting the Codespace" >&2
exit 1
EOF_STOP
  chmod +x "$STOP_SCRIPT"
}

write_play_now_metadata() {
  printf "%s\n" "$$" >"$PLAY_NOW_PID_FILE"
  printf "%s\n" "$NOVNC_PORT" >"$PLAY_NOW_PORT_FILE"
}

cleanup_play_now_metadata() {
  local recorded_pid

  recorded_pid="$(cat "$PLAY_NOW_PID_FILE" 2>/dev/null || true)"
  if [ "$recorded_pid" = "$$" ]; then
    rm -f "$PLAY_NOW_PID_FILE" "$PLAY_NOW_PORT_FILE"
  fi
}

RUN_PREFLIGHT_ONLY=0
REQUIRE_NOVNC=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --preflight|--dry-run)
      RUN_PREFLIGHT_ONLY=1
      ;;
    --require-novnc)
      REQUIRE_NOVNC=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

validate_tcp_port NOVNC_PORT "$NOVNC_PORT"
validate_vnc_display "$VNC_DISPLAY"
if [ "$NOVNC_PORT" -eq "$VNC_PORT" ]; then
  fail_remote "NOVNC_PORT and VNC_DISPLAY both map to 127.0.0.1:$NOVNC_PORT; choose different ports"
fi

if [ "$(uname -s)" = "Darwin" ] && [ "${ALLOW_LOCAL_VM:-0}" != "1" ]; then
  cat >&2 <<'EOF'
Refusing to run QEMU on macOS.

Use this script inside a disposable remote Linux host, GitHub Codespace, or
cloud VM. The supported play-now path keeps QEMU off the local Mac.
EOF
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "missing python3" >&2
  echo "Ubuntu setup: sudo apt-get update && sudo apt-get install -y nasm qemu-system-x86 clang make netcat-openbsd curl novnc websockify" >&2
  exit 1
fi

preflight_args=()
if [ "$REQUIRE_NOVNC" = "1" ]; then
  preflight_args+=(--require-novnc)
fi
python3 tools/check_play_now_remote.py "${preflight_args[@]}"
if [ "$RUN_PREFLIGHT_ONLY" = "1" ]; then
  exit 0
fi

write_diagnostics_helper
echo "Diagnostics helper: $DIAGNOSTICS_SCRIPT"
echo "Stop helper: $STOP_SCRIPT"
echo "From another remote shell, run it to inspect safe slowdown status without printing env."
echo "Machine-readable diagnostics: $DIAGNOSTICS_SCRIPT --json"
echo "The diagnostics helper does not dump environment variables."
echo "Performance diagnostics include host CPUs/load plus filtered status fields such as inputdepth=, dtick=, preempt=, doompresent=, musicbuf=, and mixunder=."
echo "If a 2-core host keeps stuttering while those OS status fields stay healthy across two snapshots, restart on a 4+ CPU Codespace or cloud VM."

if command -v websockify >/dev/null 2>&1; then
  NOVNC_WEB_ROOT_RESOLVED="$(resolve_novnc_web_root)"
fi
ensure_wad_path_outside_repo
ensure_loopback_port_free "QEMU VNC" "$VNC_PORT"
if command -v websockify >/dev/null 2>&1 && [ -n "$NOVNC_WEB_ROOT_RESOLVED" ]; then
  ensure_loopback_port_free "noVNC" "$NOVNC_PORT"
fi

codespaces_novnc_url() {
  if [ -n "${CODESPACE_NAME:-}" ] && [ -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]; then
    printf 'https://%s-%s.%s/vnc.html?autoconnect=1\n' \
      "$CODESPACE_NAME" \
      "$NOVNC_PORT" \
      "$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
  fi
}

cleanup() {
  if [ -n "${QEMU_PID:-}" ]; then
    kill "$QEMU_PID" >/dev/null 2>&1 || true
    wait "$QEMU_PID" 2>/dev/null || true
  fi
  if [ -n "${WEBSOCKIFY_PID:-}" ]; then
    kill "$WEBSOCKIFY_PID" >/dev/null 2>&1 || true
    wait "$WEBSOCKIFY_PID" 2>/dev/null || true
  fi
  cleanup_play_now_metadata
}
terminate() {
  cleanup
  exit 130
}
trap cleanup EXIT
trap terminate INT TERM

write_play_now_metadata

echo "Fetching/validating shareware DOOM1.WAD into $WAD_PATH"
echo "Remote artifact policy: WADs, disk images, pixels, raw audio, and logs stay on this disposable host unless a separate allowlisted proof collector is used."
python3 tools/prepare_shareware_wad.py \
  --url "$DOOM_WAD_URL" \
  --output "$WAD_PATH"

echo "Building vibe-os Doom disk image"
echo "Reusing cached objects when valid; forcing only build/disk.img to bind the validated WAD."
rm -f build/disk.img
make DOOM_WAD="$WAD_PATH"
mkdir -p "$PLAY_BUILD_DIR"

if command -v websockify >/dev/null 2>&1 && [ -n "$NOVNC_WEB_ROOT_RESOLVED" ]; then
  websockify --web="$NOVNC_WEB_ROOT_RESOLVED" "127.0.0.1:$NOVNC_PORT" "127.0.0.1:$VNC_PORT" \
    >"$PLAY_BUILD_DIR/novnc.log" 2>&1 &
  WEBSOCKIFY_PID="$!"
  sleep 1
  if ! kill -0 "$WEBSOCKIFY_PID" >/dev/null 2>&1; then
    wait "$WEBSOCKIFY_PID" 2>/dev/null || true
    fail_remote "websockify exited before noVNC was ready; see $PLAY_BUILD_DIR/novnc.log"
  fi
  echo "noVNC web root: $NOVNC_WEB_ROOT_RESOLVED"
  echo "noVNC tunnel/local URL: http://127.0.0.1:$NOVNC_PORT/vnc.html?autoconnect=1"
  if codespaces_url="$(codespaces_novnc_url)" && [ -n "$codespaces_url" ]; then
    echo "Codespaces noVNC URL: $codespaces_url"
  fi
  echo "In Codespaces, forward port $NOVNC_PORT and open the forwarded URL with path /vnc.html?autoconnect=1."
else
  if [ "$REQUIRE_NOVNC" = "1" ]; then
    fail_remote "noVNC was required but websockify or /usr/share/novnc is unavailable"
  fi
  echo "noVNC not found; use SSH VNC tunnel instead:"
  echo "  ssh -L $VNC_PORT:127.0.0.1:$VNC_PORT user@remote-host"
  echo "Then connect a VNC client to localhost:$VNC_PORT."
fi

echo "Starting remote QEMU VNC display :$VNC_DISPLAY on 127.0.0.1:$VNC_PORT"
echo "Controls: arrows move/turn, Ctrl fires, Space uses, Escape opens menu."
echo "noVNC focus: click inside the canvas before each human-proof action if keyboard input is ambiguous."
echo "Audio: this quick VNC path exposes display/input; record audio as status-only unless you set up remote audio forwarding or an aggregate audio-proof.json."
qemu-system-x86_64 \
  -machine pc,accel=tcg \
  -m 128M \
  -audiodev none,id=snd0 \
  -device sb16,audiodev=snd0 \
  -drive file=build/disk.img,format=raw,if=ide,index=0,media=disk \
  -boot c \
  -display "vnc=127.0.0.1:$VNC_DISPLAY" \
  -serial "file:$PLAY_BUILD_DIR/serial.log" \
  -monitor "unix:$PLAY_BUILD_DIR/monitor.sock,server,nowait" \
  -no-reboot \
  -no-shutdown &
QEMU_PID="$!"
sleep 1
if ! kill -0 "$QEMU_PID" >/dev/null 2>&1; then
  wait "$QEMU_PID" 2>/dev/null || true
  fail_remote "QEMU exited immediately; see $PLAY_BUILD_DIR/serial.log and $PLAY_BUILD_DIR/novnc.log if present"
fi
wait "$QEMU_PID"
