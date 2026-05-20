import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))
try:
    import triage_cloud_status
finally:
    sys.path.pop(0)


def status_line(**overrides):
    fields = {
        "exec": "OK",
        "path": "DOOM.ELF",
        "execsys": "00000001/00000001/00000000/00000001/00000001/00000000",
        "execerr": "00000000",
        "execres": "00000000",
        "target": "00000003",
        "ppid": "00000001",
        "entry": "01000000",
        "stack": "0100EFE0",
        "argc": "00000001",
        "argv": "0100EFE4",
        "envp": "0100EFEC",
        "argv0": "0100F000",
        "envp0": "00000000",
        "doom": "OK",
        "doomrun": "RUN",
        "doomopen": "OK",
        "doomread": "OK",
        "doomwad": "00000001/00000002/00000003/44415749",
        "doominit": "000001FF/00000009",
        "doomerr": "00000000",
        "doomerrno": "00000000",
        "doomexit": "00000000",
        "doomfault": "00000000",
        "doomfaultip": "00000000",
        "doomfaultv": "00000000",
        "doomfaulterr": "00000000",
        "fault": "00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000",
        "panic": "NONE",
        "shutdown": "NONE",
        "doommode": "00000000:00000000",
        "doomlog": "ready",
        "doompresent": "00000008",
        "doompal": "00000001",
        "doomframe": "00000002",
        "gameplay": "OK",
        "gstate": "00000000",
        "gmap": "00000101",
        "gtic": "00000020",
        "leveltime": "00000020",
        "gflags": "00000001",
        "pflags": "000000FF",
        "pdelta": "00000100",
        "keyirq": "00000002",
        "keyqueue": "00000002",
        "keypoll": "00000002",
        "keyseen": "00000071",
        "keylast": "0001001B",
        "mouseirq": "00000002",
        "mousepkt": "00000002",
        "mousepoll": "00000002",
        "mousebtn": "00000001",
        "mousedelta": "00000018:0000000C",
        "gfx": "OK",
        "usr": "OK",
        "wad": "OK",
        "lmp": "OK",
        "heap": "OK",
        "free": "00780000",
        "ticks": "00000300",
        "dtick": "0000010C",
        "preempt": "00000008",
        "pattempt": "00000010",
        "puser": "00000080",
        "pround": "00000018",
        "pctx": "00000020",
        "pfrom": "00000002",
        "pto": "00000003",
        "peip": "01002000:00E80000",
        "pspin": "50524590",
        "pself": "OK",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(
        f"{name}={value}" for name, value in fields.items()
    )


def symbol_map_text():
    return "\n".join(
        (
            "# vibe-os-symbol-map-v1",
            "# address\tsize\ttype\tbind\tsection\tobject\tsymbol",
            "0102F100\t00000200\tFUNC\tGLOBAL\t.text\tbuild/doom/d_main.o\tD_DoomMain",
            "01040000\t00000080\tFUNC\tLOCAL\t.text\tbuild/doom/w_wad.o\tW_CheckNumForName",
            "",
        )
    )


class CloudStatusTriageTests(unittest.TestCase):
    def classify(self, **overrides):
        fields = triage_cloud_status.parse_status(status_line(**overrides))
        return triage_cloud_status.classify(fields)

    def test_triage_rules_cover_next_cloud_failure_classes(self):
        names = {rule.name for rule in triage_cloud_status.TRIAGE_RULES}
        for expected in (
            "exec-not-attempted",
            "exec-failed",
            "doom-user-fault",
            "missing-wad-open-read",
            "doom-init-stalled",
            "frames-no-gameplay",
            "input-no-effect",
            "doom-timer-not-proven",
            "preemption-not-proven",
            "artifact-proof-failure",
            "kernel-panic",
            "os-shutdown-requested",
            "playability-status-green",
        ):
            with self.subTest(expected=expected):
                self.assertIn(expected, names)

        doc = (ROOT / "docs" / "cloud-status-triage.md").read_text()
        for expected in names:
            with self.subTest(doc=expected):
                self.assertIn(f"`{expected}`", doc)

    def test_doc_tracks_green_runtime_but_red_proof_gate_cleanup_lane(self):
        doc = (ROOT / "docs" / "cloud-status-triage.md").read_text()

        for phrase in (
            "input/audio/preemption counters active",
            "proof gates can still fail on snapshot-baseline details",
            "`usr=OK` consistency",
            "scripted `use` phase progression",
            "mouse baseline/effect evidence",
            "audio baseline continuity",
            "early/start/fire/move/use/",
            "mouse/menu snapshots",
            "check_audio_continuity_proof.py",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, doc)

    def test_classifies_exec_not_attempted(self):
        primary, notes = self.classify(
            execsys="00000000/00000000/00000000/00000000/00000000/00000000",
            target="FFFFFFFF",
            entry="00000000",
            stack="00000000",
            argc="00000000",
            argv="00000000",
            envp="00000000",
            argv0="00000000",
            doomrun="WAIT",
        )

        self.assertEqual(primary, "exec-not-attempted")
        self.assertIn("target=FFFFFFFF", notes[0])

    def test_classifies_failed_exec_handoff(self):
        primary, notes = self.classify(
            execsys="00000001/00000000/00000001/00000000/00000000/00000000",
            execerr="FFFFFFFE",
            execres="FFFFFFFE",
            target="FFFFFFFF",
            entry="00000000",
            stack="00000000",
            argc="00000000",
            argv="00000000",
            envp="00000000",
            argv0="00000000",
        )

        self.assertEqual(primary, "exec-failed")
        self.assertIn("failures=0x1", notes[0])
        self.assertIn("execerr=FFFFFFFE", notes[0])

    def test_classifies_doom_fault_before_wad_io(self):
        primary, notes = self.classify(
            doomrun="FAULT",
            doomfault="018F0000",
            doomfaultip="0102F190",
            doomfaultv="0000000E",
            doomfaulterr="00000004",
            fault="0000000E/00000004/0102F190/0000001B/0100FFE0/00000023/018F0000/00000002/00000002/00000001/00000003",
            doomopen="FAIL",
            doomread="FAIL",
            doomwad="00000000/00000000/00000000/00000000",
        )

        self.assertEqual(primary, "doom-user-fault")
        rendered = "\n".join(notes)
        self.assertIn("doomfaultip(EIP)=0102F190", rendered)
        self.assertIn("missing-wad-open-read", rendered)

    def test_symbol_map_resolves_fault_ip_to_doom_function(self):
        symbols = triage_cloud_status.SymbolMap.parse(symbol_map_text())
        hit = symbols.lookup(0x0102F190)

        self.assertIsNotNone(hit)
        self.assertEqual(hit.symbol.name, "D_DoomMain")
        self.assertEqual(hit.offset, 0x90)
        self.assertTrue(hit.inside_declared_size)

    def test_render_diagnosis_adds_doom_fault_symbol_context(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            status_path = tmpdir / "status.txt"
            status_path.write_text(
                status_line(
                    doomrun="FAULT",
                    doomfault="018F0000",
                    doomfaultip="0102F190",
                    doomfaultv="0000000E",
                    doomfaulterr="00000004",
                )
            )
            (tmpdir / "doom.symbols").write_text(symbol_map_text())

            rendered = triage_cloud_status.render_diagnosis(
                status_path.read_text(),
                status_path=status_path,
            )

        self.assertIn("primary: doom-user-fault", rendered)
        self.assertIn("fault-decode: vector=0E (page-fault)", rendered)
        self.assertIn("not-present page", rendered)
        self.assertIn("symbol: 0102F190 -> D_DoomMain+0x90", rendered)

    def test_render_diagnosis_adds_wad_io_context(self):
        rendered = triage_cloud_status.render_diagnosis(
            status_line(
                doomopen="FAIL",
                doomread="FAIL",
                doomwad="00000000/00000000/00000000/00000000",
                doomseek="00000000",
                doomclose="00000000",
                doomerr="00000002",
                doomerrno="FFFFFFFE",
                doommode="00000001:00000000",
                doomlog="W_GetNumForName",
            )
        )

        self.assertIn("primary: missing-wad-open-read", rendered)
        self.assertIn("wad-io: doomopen=FAIL doomread=FAIL", rendered)
        self.assertIn("doomerrno=FFFFFFFE", rendered)
        self.assertIn("wad-hint: disk image and WAD fixture were visible", rendered)

    def test_classifies_kernel_panic_before_other_lanes(self):
        primary, notes = self.classify(
            panic="KEXC",
            fault="0000000D/00000000/00010500/00000008/0006FFE0/00000010/00000000/FFFFFFFF/00000000/00000000/FFFFFFFF",
            execsys="00000000/00000000/00000000/00000000/00000000/00000000",
        )

        self.assertEqual(primary, "kernel-panic")
        self.assertIn("panic=KEXC", notes[0])

    def test_classifies_os_shutdown_request(self):
        primary, notes = self.classify(shutdown="HALT")

        self.assertEqual(primary, "os-shutdown-requested")
        self.assertIn("shutdown=HALT", notes[0])

    def test_classifies_wad_open_read_failure_after_doom_is_running(self):
        primary, notes = self.classify(
            doomopen="FAIL",
            doomread="FAIL",
            doomwad="00000000/00000000/00000000/00000000",
            doomerr="00000002",
            doomerrno="FFFFFFFE",
            doomlog="W_GetNumForName",
        )

        self.assertEqual(primary, "missing-wad-open-read")
        self.assertIn("doomerr=00000002", notes[0])
        self.assertIn("doomerrno=FFFFFFFE", notes[0])

    def test_classifies_missing_wad_seek_or_magic_even_if_legacy_fields_are_ok(self):
        primary, notes = self.classify(doomwad="00000001/00000001/00000000/00000000")

        self.assertEqual(primary, "missing-wad-open-read")
        self.assertIn("doomwad=00000001/00000001/00000000/00000000", notes[0])

    def test_classifies_doom_init_stalled_after_wad_io(self):
        primary, notes = self.classify(doominit="0000003F/00000004", gameplay="WAIT")

        self.assertEqual(primary, "doom-init-stalled")
        self.assertIn("doominit=0000003F/00000004", notes[0])

    def test_classifies_frames_without_gameplay(self):
        primary, notes = self.classify(gameplay="WAIT", leveltime="00000000")

        self.assertEqual(primary, "frames-no-gameplay")
        self.assertIn("doompresent=00000008", notes[0])

    def test_classifies_input_without_game_state_effect(self):
        primary, notes = self.classify(pdelta="00000000")

        self.assertEqual(primary, "input-no-effect")
        self.assertIn("keyirq=00000002", notes[0])
        self.assertIn("keyseen=00000071", notes[0])
        self.assertIn("mousedelta=00000018:0000000C", notes[0])

    def test_classifies_keyboard_input_without_scripted_key_bits(self):
        primary, notes = self.classify(keyseen="00000031")

        self.assertEqual(primary, "input-no-effect")
        self.assertIn("keyseen=00000031", notes[0])

    def test_classifies_mouse_input_without_button_or_motion_proof(self):
        primary, notes = self.classify(mousebtn="00000000", mousedelta="00000000:0000000C")

        self.assertEqual(primary, "input-no-effect")
        self.assertIn("mousebtn=00000000", notes[0])

    def test_classifies_missing_doom_35hz_timer_proof(self):
        primary, notes = self.classify(dtick="0000010B")

        self.assertEqual(primary, "doom-timer-not-proven")
        self.assertIn("ticks=00000300", notes[0])
        self.assertIn("dtick=0000010B", notes[0])
        self.assertIn("gtic=00000020", notes[0])

    def test_classifies_missing_live_preemption_after_gameplay_is_green(self):
        primary, notes = self.classify(preempt="00000000", pspin="50524545")

        self.assertEqual(primary, "preemption-not-proven")
        rendered = "\n".join(notes)
        self.assertIn("preempt=00000000", rendered)
        self.assertIn("pspin=50524545", rendered)

    def test_classifies_green_status_as_needing_full_proof_gates(self):
        primary, notes = self.classify()

        self.assertEqual(primary, "playability-status-green")
        self.assertIn("no obvious first-failure", notes[0])

    def test_cli_prints_primary_and_summary(self):
        with tempfile.TemporaryDirectory() as tmp:
            status_path = Path(tmp) / "status.txt"
            status_path.write_text(
                status_line(
                    doomrun="FAULT",
                    doomfault="018F0000",
                    doomfaultip="0102F190",
                    doomfaultv="0000000E",
                    doomfaulterr="00000004",
                )
            )
            (Path(tmp) / "doom.symbols").write_text(symbol_map_text())
            result = subprocess.run(
                [sys.executable, str(TOOLS / "triage_cloud_status.py"), str(status_path)],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("primary: doom-user-fault", result.stdout)
        self.assertIn("summary:", result.stdout)
        self.assertIn("symbol: 0102F190 -> D_DoomMain+0x90", result.stdout)
        self.assertIn("next: Symbolize doomfaultip", result.stdout)


if __name__ == "__main__":
    unittest.main()
