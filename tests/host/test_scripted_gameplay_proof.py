import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOL = ROOT / "tools" / "check_scripted_gameplay_proof.py"
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))
spec = importlib.util.spec_from_file_location("check_scripted_gameplay_proof", TOOL)
check_scripted_gameplay_proof = importlib.util.module_from_spec(spec)
try:
    spec.loader.exec_module(check_scripted_gameplay_proof)
finally:
    sys.path.pop(0)


def make_status(**overrides):
    fields = {
        "gameplay": "OK",
        "gstate": "00000000",
        "gmap": "00000101",
        "gtic": "00000020",
        "leveltime": "00000020",
        "gflags": "00000000",
        "gaction": "00000000",
        "pflags": "00000001",
        "pbuttons": "00000000",
        "ppos": "00010000:00020000",
        "pdelta": "00000000",
        "pcmd": "00000000",
        "pangle": "10000000",
        "pangledelta": "00000000",
        "pammo": "00000032",
        "prefire": "00000000",
        "pweapon": "00000002",
        "inputqueue": "00000000",
        "inputpoll": "00000000",
        "inputlast": "00000000:00000000:00000000",
        "keyirq": "00000000",
        "keyqueue": "00000000",
        "keypoll": "00000000",
        "keyseen": "00000000",
        "keylast": "00000000",
        "mouse": "OK",
        "mouseirq": "00000000",
        "mousepkt": "00000000",
        "mousepoll": "00000000",
        "mousebtn": "00000000",
        "mousedelta": "00000000:00000000",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(
        f"{name}={value}" for name, value in fields.items()
    )


def scripted_statuses():
    return {
        "start": make_status(
            gtic="00000020",
            leveltime="00000020",
        ),
        "fire": make_status(
            gtic="00000040",
            leveltime="00000040",
            keyirq="00000001",
            keyqueue="00000001",
            keypoll="00000001",
            inputqueue="00000001",
            inputpoll="00000001",
            inputlast="00000040:00000001:00000001",
            keyseen="00000010",
            keylast="0001019D",
            pflags="000000C5",
            pcmd="00010001",
            pammo="00000031",
            prefire="00000001",
        ),
        "movement": make_status(
            gtic="00000060",
            leveltime="00000060",
            keyirq="00000002",
            keyqueue="00000002",
            keypoll="00000002",
            inputqueue="00000002",
            inputpoll="00000002",
            inputlast="00000060:00000001:00000001",
            keyseen="00000011",
            keylast="000101AD",
            pflags="000000E7",
            ppos="00010020:00020000",
            pdelta="00000020",
            pcmd="00003200",
            pammo="00000031",
        ),
        "use": make_status(
            gtic="00000080",
            leveltime="00000080",
            keyirq="00000003",
            keyqueue="00000003",
            keypoll="00000003",
            inputqueue="00000003",
            inputpoll="00000003",
            inputlast="00000080:00000001:00000001",
            keyseen="00000031",
            keylast="00010020",
            pflags="000000EF",
            ppos="00010020:00020000",
            pdelta="00000020",
            pcmd="00000002",
            pammo="00000031",
        ),
        "mouse": make_status(
            gtic="000000A0",
            leveltime="000000A0",
            keyirq="00000003",
            keyqueue="00000003",
            keypoll="00000003",
            inputqueue="00000005",
            inputpoll="00000005",
            inputlast="000000A0:00000002:00000002",
            keyseen="00000031",
            keylast="00010020",
            pflags="000001EF",
            ppos="00010020:00020000",
            pdelta="00000020",
            pammo="00000031",
            pangle="11000000",
            pangledelta="01000000",
            mouseirq="00000002",
            mousepkt="00000002",
            mousepoll="00000002",
            mousebtn="00000001",
            mousedelta="00000018:0000000C",
        ),
        "menu": make_status(
            gtic="000000C0",
            leveltime="000000C0",
            gflags="00000001",
            keyirq="00000004",
            keyqueue="00000004",
            keypoll="00000004",
            inputqueue="00000006",
            inputpoll="00000006",
            inputlast="000000C0:00000001:00000001",
            keyseen="00000071",
            keylast="0001001B",
            pflags="000001FF",
            ppos="00010020:00020000",
            pdelta="00000020",
            pammo="00000031",
            pangle="11000000",
            pangledelta="01000000",
            mouseirq="00000002",
            mousepkt="00000002",
            mousepoll="00000002",
            mousebtn="00000001",
            mousedelta="00000018:0000000C",
        ),
        "final": make_status(
            gtic="000000C0",
            leveltime="000000C0",
            gflags="00000001",
            keyirq="00000004",
            keyqueue="00000004",
            keypoll="00000004",
            inputqueue="00000006",
            inputpoll="00000006",
            inputlast="000000C0:00000001:00000001",
            keyseen="00000071",
            keylast="0001001B",
            pflags="000001FF",
            ppos="00010020:00020000",
            pdelta="00000020",
            pammo="00000031",
            pangle="11000000",
            pangledelta="01000000",
            mouseirq="00000002",
            mousepkt="00000002",
            mousepoll="00000002",
            mousebtn="00000001",
            mousedelta="00000018:0000000C",
        ),
    }


def write_status_files(tmpdir, statuses):
    paths = {}
    for phase, status in statuses.items():
        path = Path(tmpdir) / check_scripted_gameplay_proof.AUTO_STATUS_NAMES[phase]
        path.write_text(status)
        paths[phase] = path
    return paths


class ScriptedGameplayProofTests(unittest.TestCase):
    def test_accepts_cumulative_scripted_phase_timeline(self):
        statuses = scripted_statuses()
        check_scripted_gameplay_proof.validate_statuses(statuses)
        manifest = check_scripted_gameplay_proof.build_manifest(statuses)

        self.assertEqual(manifest["schema"], check_scripted_gameplay_proof.SCHEMA)
        self.assertEqual(manifest["phase_order"], list(check_scripted_gameplay_proof.PHASE_ORDER))
        self.assertEqual(manifest["start_state"]["pdelta"], "00000000")
        self.assertEqual(manifest["start_state"]["pangle"], "10000000")
        self.assertEqual(manifest["transitions"]["fire"]["pammo"], "00000031")
        self.assertEqual(manifest["transitions"]["movement"]["movement_ppos"], "00010020:00020000")
        self.assertEqual(manifest["transitions"]["mouse"]["pangledelta"], "01000000")
        self.assertEqual(manifest["transitions"]["mouse"]["pflags"], "000001EF")
        check_scripted_gameplay_proof.validate_manifest(manifest, snapshots=statuses)

    def test_rejects_dirty_start_or_non_cumulative_player_proof(self):
        dirty_start = scripted_statuses()
        dirty_start["start"] = make_status(keyseen="00000010")
        with self.assertRaisesRegex(AssertionError, "start keyseen"):
            check_scripted_gameplay_proof.validate_statuses(dirty_start)

        lost_fire = scripted_statuses()
        lost_fire["movement"] = make_status(
            gtic="00000060",
            leveltime="00000060",
            keyirq="00000002",
            keyqueue="00000002",
            keypoll="00000002",
            keyseen="00000011",
            pflags="00000023",
            ppos="00010020:00020000",
            pdelta="00000020",
        )
        with self.assertRaisesRegex(AssertionError, "pflags"):
            check_scripted_gameplay_proof.validate_statuses(lost_fire)

    def test_shared_status_parser_rejects_duplicate_fields_and_keeps_tuples(self):
        fields = check_scripted_gameplay_proof._status_fields(
            "Aurora gameplay=OK inputlast=00000040:00000001:00000001 "
            "execsys=00000001/00000002/00000003"
        )
        self.assertEqual(fields["inputlast"], "00000040:00000001:00000001")
        self.assertEqual(fields["execsys"], "00000001/00000002/00000003")
        self.assertEqual(
            check_scripted_gameplay_proof._position_field(
                "Aurora ppos=00010000:00020000", "ppos"
            ),
            (0x00010000, 0x00020000),
        )

        duplicate_start = scripted_statuses()
        duplicate_start["start"] += " pflags=00000001"
        with self.assertRaisesRegex(AssertionError, "start snapshot: duplicate pflags= field"):
            check_scripted_gameplay_proof.validate_statuses(duplicate_start)

    def test_rejects_missing_state_change_in_each_runtime_lane(self):
        cases = {
            "movement ppos": {
                "movement": make_status(
                    gtic="00000060",
                    leveltime="00000060",
                    keyirq="00000002",
                    keyqueue="00000002",
                    keypoll="00000002",
                    keyseen="00000011",
                    pflags="000000E7",
                    pdelta="00000020",
                )
            },
            "mousepoll": {
                "mouse": make_status(
                    gtic="000000A0",
                    leveltime="000000A0",
                    keyirq="00000003",
                    keyqueue="00000003",
                    keypoll="00000003",
                    keyseen="00000031",
                    pflags="000001EF",
                    ppos="00010020:00020000",
                    pdelta="00000020",
                    mouseirq="00000002",
                    mousepkt="00000002",
                    mousepoll="00000000",
                    mousebtn="00000001",
                    mousedelta="00000018:0000000C",
                )
            },
            "mouse turn pflags": {
                "mouse": make_status(
                    gtic="000000A0",
                    leveltime="000000A0",
                    keyirq="00000003",
                    keyqueue="00000003",
                    keypoll="00000003",
                    keyseen="00000031",
                    pflags="000000EF",
                    ppos="00010020:00020000",
                    pdelta="00000020",
                    mouseirq="00000002",
                    mousepkt="00000002",
                    mousepoll="00000002",
                    mousebtn="00000001",
                    mousedelta="00000018:0000000C",
                )
            },
            "fire raw weapon state": {
                "fire": make_status(
                    gtic="00000040",
                    leveltime="00000040",
                    keyirq="00000001",
                    keyqueue="00000001",
                    keypoll="00000001",
                    keyseen="00000010",
                    keylast="0001019D",
                    pflags="000000C5",
                    pammo="00000032",
                    prefire="00000000",
                )
            },
            "mouse raw angle state": {
                "mouse": make_status(
                    gtic="000000A0",
                    leveltime="000000A0",
                    keyirq="00000003",
                    keyqueue="00000003",
                    keypoll="00000003",
                    keyseen="00000031",
                    keylast="00010020",
                    pflags="000001EF",
                    ppos="00010020:00020000",
                    pdelta="00000020",
                    pammo="00000031",
                    mouseirq="00000002",
                    mousepkt="00000002",
                    mousepoll="00000002",
                    mousebtn="00000001",
                    mousedelta="00000018:0000000C",
                    pangle="10000000",
                    pangledelta="00000000",
                )
            },
            "menu gflags": {
                "menu": make_status(
                    gtic="000000C0",
                    leveltime="000000C0",
                    keyirq="00000004",
                    keyqueue="00000004",
                    keypoll="00000004",
                    keyseen="00000071",
                    pflags="000001FF",
                    ppos="00010020:00020000",
                    pdelta="00000020",
                    mouseirq="00000002",
                    mousepkt="00000002",
                    mousepoll="00000002",
                    mousebtn="00000001",
                    mousedelta="00000018:0000000C",
                )
            },
        }
        for label, replacements in cases.items():
            with self.subTest(label=label):
                statuses = scripted_statuses()
                statuses.update(replacements)
                with self.assertRaises(AssertionError):
                    check_scripted_gameplay_proof.validate_statuses(statuses)

    def test_cli_auto_discovers_statuses_and_writes_manifest(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            statuses = scripted_statuses()
            paths = write_status_files(tmpdir, statuses)
            manifest_path = tmpdir / "gameplay-proof.json"

            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOL),
                    "--write-json",
                    str(manifest_path),
                    str(paths["final"]),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

            manifest = json.loads(manifest_path.read_text())

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("scripted gameplay proof OK", result.stdout)
        self.assertEqual(manifest["status_files"]["final"]["path"], "status.txt")

    def test_tool_is_status_only_and_repo_wiring_is_present(self):
        source = TOOL.read_text()
        for forbidden in ("qemu-system", "pmemsave 0xa0000", "gfx.bin", "subprocess.run"):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, source)

        result = subprocess.run(
            [sys.executable, str(TOOL), "--repo-contract"],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("repo contract OK", result.stdout)


if __name__ == "__main__":
    unittest.main()
