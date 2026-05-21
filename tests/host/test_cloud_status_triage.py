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
        "uexec": "OK",
        "upath": "USERPROB.ELF",
        "upid": "00000004",
        "uentry": "00E80000",
        "execsys": "00000001/00000001/00000000/00000001/00000001/00000000",
        "execerr": "00000000",
        "execres": "00000000",
        "target": "00000005",
        "ppid": "00000004",
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
        "ata": "OK",
        "ataop": "READ",
        "atawait": "IDLE",
        "atalba": "00000800",
        "atastat": "00000040",
        "ataerr": "00000000",
        "atafail": "00000000",
        "atatmo": "00000000",
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
        "pflags": "000001FF",
        "pdelta": "00000100",
        "pangle": "11000000",
        "pangledelta": "01000000",
        "pammo": "00000031",
        "prefire": "00000000",
        "inputqueue": "00000007",
        "inputpoll": "00000007",
        "inputdepth": "00000000:00000000",
        "inputlast": "00000060:00000001:00000001",
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
        "audio": "SB16",
        "audioirq": "00000040",
        "refill": "00000040",
        "musicpos": "00040000",
        "musicbuf": "00002000",
        "musicpull": "00000020:00000020",
        "mixunder": "00000000",
        "musicunder": "00000000",
        "musicdrops": "00000000",
        "preempt": "00000008",
        "pirq": "00000008",
        "pattempt": "00000010",
        "pskip": "00000002",
        "puser": "00000080",
        "pround": "00000018",
        "pctx": "00000020",
        "pmask": "00000003",
        "pfrom": "00000002",
        "pto": "00000003",
        "pkind": "00000002:00000003",
        "peip": "01002000:00E80000",
        "pcr3": "00082000:00083000",
        "pkstk": "00073000:00072000",
        "pframe": "00000008/00E80000/0000001B/00E9FFE0/00000023",
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
            "persistence-save-write-failed",
            "persistence-save-growth-allocation-partial",
            "persistence-load-malformed-stream",
            "persistence-load-not-completed",
            "doom-init-stalled",
            "frames-no-gameplay",
            "input-no-effect",
            "doom-timer-not-proven",
            "preemption-not-proven",
            "long-run-cadence-not-proven",
            "artifact-proof-failure",
            "kernel-panic",
            "os-shutdown-requested",
            "ata-storage-stalled",
            "playability-status-green",
        ):
            with self.subTest(expected=expected):
                self.assertIn(expected, names)

        doc = (ROOT / "docs" / "proof.md").read_text()
        for expected in names:
            with self.subTest(doc=expected):
                self.assertIn(f"`{expected}`", doc)

    def test_doc_tracks_green_runtime_but_red_proof_gate_cleanup_lane(self):
        doc = (ROOT / "docs" / "proof.md").read_text()

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

    def test_shared_status_parser_rejects_duplicate_fields(self):
        with self.assertRaisesRegex(ValueError, "duplicate doomrun= field"):
            triage_cloud_status.parse_status("Aurora doomrun=RUN doomrun=FAULT")

    def test_shared_status_parser_keeps_tuple_values_intact(self):
        fields = triage_cloud_status.parse_status(
            "Aurora execsys=00000001/00000002/00000000/00000003/00000004/00000000"
        )

        primary, notes = triage_cloud_status.classify(fields)
        self.assertEqual(primary, "exec-failed")
        self.assertIn("successes=0x2", notes[0])

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

    def test_classifies_ata_wait_before_doom_frames(self):
        primary, notes = self.classify(
            doomrun="WAIT",
            gameplay="WAIT",
            doompresent="00000000",
            doompal="00000000",
            doomframe="00000000",
            atawait="READY",
            atastat="00000080",
            atalba="00002013",
        )

        self.assertEqual(primary, "ata-storage-stalled")
        self.assertIn("atawait=READY", notes[0])
        self.assertIn("atastat=00000080", notes[0])
        self.assertIn("atalba=00002013", notes[0])

    def test_classifies_ready_wait_before_doom_frames(self):
        primary, notes = self.classify(
            doomrun="WAIT",
            gameplay="WAIT",
            doompresent="00000000",
            doompal="00000000",
            doomframe="00000000",
            atawait="READY",
            atastat="00000050",
            atalba="00000A01",
        )

        self.assertEqual(primary, "ata-storage-stalled")
        self.assertIn("atawait=READY", notes[0])

    def test_classifies_data_transfer_before_doom_frames(self):
        primary, notes = self.classify(
            doomrun="WAIT",
            gameplay="WAIT",
            doompresent="00000000",
            doompal="00000000",
            doomframe="00000000",
            atawait="DATA",
            atastat="00000050",
            atalba="00000A01",
        )

        self.assertEqual(primary, "ata-storage-stalled")
        self.assertIn("atawait=DATA", notes[0])

    def test_classifies_ata_timeout_even_after_exec_started(self):
        primary, notes = self.classify(ata="FAIL", atawait="BUSY", atafail="00000001", atatmo="00000001")

        self.assertEqual(primary, "ata-storage-stalled")
        self.assertIn("atatmo=00000001", notes[0])

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

    def test_classifies_persistence_save_write_fat_allocation_failure(self):
        primary, notes = self.classify(
            doomerrno="FFFFFFFB",
            doommode="00000301:000001B6",
            doomsav="00000009/00000000",
            savewr="00000000/00000000",
            saveclose="00000001",
            savemode="00000301:000001B6",
            fwr="00000005/FFFFFFFB/00000001/00000003/00006276/00000200/00000200/00007046/00000000/00040000/00000001",
            fal="000000E0/00000002/0000F5E0/00000001",
            fio="00000004/00000001/00000003/00006476/00040000/00006276/00000200/00007046/00000003/00000001/0000F5E0/0000FFFF/0000F5E0/00007046/00000002/00000002/0000F5E0/00000000/0000FFFF/0000F5E0",
        )

        self.assertEqual(primary, "persistence-save-write-failed")
        rendered = "\n".join(notes)
        self.assertIn("doomerrno=FFFFFFFB", rendered)
        self.assertIn("savewr=00000000/00000000", rendered)
        self.assertIn("fal=000000E0/00000002/0000F5E0/00000001", rendered)

    def test_render_diagnosis_adds_persistence_save_context(self):
        rendered = triage_cloud_status.render_diagnosis(
            status_line(
                doomerrno="FFFFFFFB",
                doommode="00000301:000001B6",
                doomsav="00000009/00000000",
                savewr="00000000/00000000",
                saveclose="00000001",
                savemode="00000301:000001B6",
                fwr="00000005/FFFFFFFB/00000001/00000003/00006276/00000200/00000200/00007046/00000000/00040000/00000001",
                fal="000000E0/00000002/0000F5E0/00000001",
                fio="00000004/00000001/00000003/00006476/00040000/00006276/00000200/00007046/00000003/00000001/0000F5E0/0000FFFF/0000F5E0/00007046/00000002/00000002/0000F5E0/00000000/0000FFFF/0000F5E0",
            )
        )

        self.assertIn("primary: persistence-save-write-failed", rendered)
        self.assertIn("persistence-save: doomerrno=FFFFFFFB", rendered)
        self.assertIn("FAT allocation exhausted", rendered)
        self.assertIn("next: Inspect the persistence status", rendered)

    def test_classifies_one_cluster_partial_save_growth_allocation_failure(self):
        primary, notes = self.classify(
            doomerrno="FFFFFFFE",
            doommode="00000301:000001B6",
            doomsav="0000000D/00000000",
            savewr="00000400/00000001",
            saveclose="00000001",
            savemode="00000301:000001B6",
            fwr="0000000B/00000400/00000001/00000003/00006076/00000400/00000200/00007048/00000000/00040000/00000001",
            fal="000000E0/00000002/0000FAF0/00000001",
            fio="00000004/00000001/00000003/00006476/00040000/00006076/00000400/00007048/00000003/00000002/0000FAF0/0000FFFF/0000FAF0/00007048/00000002/00000002/0000FAF0/00000000/0000FFFF/0000FAF0",
            keyseen="00000001",
            pflags="00000023",
            pangledelta="00000000",
            mousepkt="00000000",
            mousepoll="00000000",
            mousebtn="00000000",
            mousedelta="00000000:00000000",
        )

        self.assertEqual(primary, "persistence-save-growth-allocation-partial")
        rendered = "\n".join(notes)
        self.assertIn("savewr=00000400/00000001", rendered)
        self.assertIn("fal=000000E0/00000002/0000FAF0/00000001", rendered)

    def test_render_diagnosis_adds_one_cluster_partial_save_context(self):
        rendered = triage_cloud_status.render_diagnosis(
            status_line(
                doomerrno="FFFFFFFE",
                doommode="00000301:000001B6",
                doomsav="0000000D/00000000",
                savewr="00000400/00000001",
                saveclose="00000001",
                savemode="00000301:000001B6",
                fwr="0000000B/00000400/00000001/00000003/00006076/00000400/00000200/00007048/00000000/00040000/00000001",
                fal="000000E0/00000002/0000FAF0/00000001",
                fio="00000004/00000001/00000003/00006476/00040000/00006076/00000400/00007048/00000003/00000002/0000FAF0/0000FFFF/0000FAF0/00007048/00000002/00000002/0000FAF0/00000000/0000FFFF/0000FAF0",
                keyseen="00000001",
                pflags="00000023",
                pangledelta="00000000",
                mousepkt="00000000",
                mousepoll="00000000",
                mousebtn="00000000",
                mousedelta="00000000:00000000",
            )
        )

        self.assertIn("primary: persistence-save-growth-allocation-partial", rendered)
        self.assertIn("persistence-short-write: wrote=0x400", rendered)
        self.assertIn("persistence-partial-save: wrote=0x400", rendered)
        self.assertIn("requested=0x40000", rendered)
        self.assertIn("FAT allocation exhausted", rendered)
        self.assertIn("next: Hand off to FAT save-growth allocation", rendered)

    def test_classifies_persistence_load_malformed_specials_stream(self):
        primary, notes = self.classify(
            doomrun="EXIT",
            doomerr="00000070",
            doomsav="0000000B/00000000",
            saverd="00006476/00000003",
            savewr="00000000/00000000",
            saveclose="00000002",
            savemode="00000000:00000000",
            saveact="00000020/00000003/00000000/00000004",
            savestm="00000017/00000000/00002A64/70000000/00000008",
            savethk="00002A64/00000000/00002A64/00000000",
        )

        self.assertEqual(primary, "persistence-load-malformed-stream")
        rendered = "\n".join(notes)
        self.assertIn("kind=specials", rendered)
        self.assertIn("doomerr=00000070", rendered)
        self.assertIn("savestm=00000017/00000000/00002A64/70000000/00000008", rendered)

    def test_render_diagnosis_adds_persistence_load_malformed_stream_context(self):
        rendered = triage_cloud_status.render_diagnosis(
            status_line(
                doomrun="EXIT",
                doomerr="00000070",
                doomsav="0000000B/00000000",
                saverd="00006476/00000003",
                saveclose="00000002",
                saveact="00000020/00000003/00000000/00000004",
                savestm="00000017/00000000/00002A64/70000000/00000008",
                savethk="00002A64/00000000/00002A64/00000000",
            )
        )

        self.assertIn("primary: persistence-load-malformed-stream", rendered)
        self.assertIn("kind=specials", rendered)
        self.assertIn("persistence-load-stream: stage=0x17", rendered)
        self.assertIn("unarchive-specials-before", rendered)
        self.assertIn("value=0x70000000", rendered)
        self.assertIn("next_byte=0x70", rendered)
        self.assertIn("persistence-status: unknown_tclass=112 (0x70) from savestm", rendered)
        self.assertIn("malformed specials stream", rendered)

    def test_render_diagnosis_derives_unknown_tclass_from_status_without_doomlog(self):
        rendered = triage_cloud_status.render_diagnosis(
            status_line(
                doomrun="EXIT",
                doomexit="00000001",
                doomerr="00000006",
                doomerrno="FFFFFFEA",
                doomsav="0000000B/00000000",
                saverd="00006476/00000001",
                saveclose="00000001",
                saveact="00000060/00000003/00000000/0000003A",
                savestm="00000017/00000000/00002A65/70016D08/00000008",
                savethk="FFFFFFFF/00000000/00002A64/01006C08",
                doomlog="ready",
            )
        )

        self.assertIn("primary: persistence-load-malformed-stream", rendered)
        self.assertIn("kind=specials", rendered)
        self.assertIn("persistence-status: unknown_tclass=112 (0x70) from savestm", rendered)
        self.assertNotIn("persistence-doomlog: unknown_tclass", rendered)
        self.assertIn("offset=0x2A65", rendered)

    def test_render_diagnosis_recovers_unknown_tclass_from_raw_doomlog(self):
        rendered = triage_cloud_status.render_diagnosis(
            status_line(
                doomrun="EXIT",
                doomexit="00000001",
                doomerr="00000006",
                doomerrno="FFFFFFEA",
                doomsav="0000000B/00000000",
                saverd="00006476/00000001",
                saveclose="00000001",
                saveact="00000060/00000003/00000000/0000003A",
                savestm="00000017/00000000/00002A65/70016D08/00000007",
                savethk="FFFFFFFF/00000000/00002A64/01006C08",
                doomlog="Unknown tclass 112 in savegame",
            )
        )

        self.assertIn("primary: persistence-load-malformed-stream", rendered)
        self.assertIn("kind=specials", rendered)
        self.assertIn("unknown_tclass=112 (0x70)", rendered)
        self.assertIn("offset=0x2A65", rendered)

    def test_latest_packed_save_stream_values_do_not_false_positive_malformed(self):
        rendered = triage_cloud_status.render_diagnosis(
            status_line(
                doomrun="EXIT",
                doomerr="00000006",
                doomerrno="FFFFFFEA",
                doomsav="0000000B/00000000",
                saverd="00006476/00000001",
                saveclose="00000001",
                saveact="00000060/00000003/00000000/0000003A",
                savestm="00000018/00000000/00006475/1D017D08/00000008",
                savethk="FFFFFFFF/00000000/00002A64/01006C08",
            )
        )

        self.assertIn("primary: persistence-load-not-completed", rendered)
        self.assertIn("unarchive-specials-after", rendered)
        self.assertIn("next_byte=0x1D", rendered)
        self.assertIn("unarchive_next_byte=0x01", rendered)
        self.assertIn("load-done was sampled before post-load ga_nothing", rendered)

    def test_classifies_persistence_load_not_completed_before_input_lanes(self):
        primary, notes = self.classify(
            doomsav="00000003/00000000",
            saverd="00006476/00000003",
            savewr="00000000/00000000",
            saveclose="00000000",
            savemode="00000000:00000000",
            saveact="00000020/00000003/00000000/00000003",
            keyseen="00000001",
            pflags="00000023",
            pangledelta="00000000",
            mousepkt="00000000",
            mousepoll="00000000",
            mousebtn="00000000",
            mousedelta="00000000:00000000",
        )

        self.assertEqual(primary, "persistence-load-not-completed")
        rendered = "\n".join(notes)
        self.assertIn("saveclose=00000000", rendered)
        self.assertIn("saveact=00000020/00000003/00000000/00000003", rendered)

    def test_unset_savestream_fields_do_not_create_load_attempt(self):
        primary, notes = self.classify(
            doomsav="00000000/FFFFFFFF",
            saverd="00000000/00000000",
            saveclose="00000000",
            saveact="00000000/00000000/FFFFFFFF/00000000",
            savestm="00000000/FFFFFFFF/FFFFFFFF/00000000/00000000",
            savethk="FFFFFFFF/00000000/FFFFFFFF/00000000",
        )

        self.assertEqual(primary, "playability-status-green")
        self.assertIn("no obvious first-failure", "\n".join(notes))

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

    def test_classifies_mouse_input_without_raw_angle_delta(self):
        primary, notes = self.classify(pangledelta="00000000")

        self.assertEqual(primary, "input-no-effect")
        self.assertIn("pangledelta=00000000", notes[0])

    def test_classifies_missing_doom_35hz_timer_proof(self):
        primary, notes = self.classify(dtick="0000010B")

        self.assertEqual(primary, "doom-timer-not-proven")
        self.assertIn("ticks=00000300", notes[0])
        self.assertIn("dtick=0000010B", notes[0])
        self.assertIn("gtic=00000020", notes[0])

    def test_classifies_missing_live_preemption_after_gameplay_is_green(self):
        primary, notes = self.classify(
            preempt="00000000",
            pirq="00000000",
            pmask="00000000",
            pframe="00000000/00000000/00000000/00000000/00000000",
            pspin="50524545",
        )

        self.assertEqual(primary, "preemption-not-proven")
        rendered = "\n".join(notes)
        self.assertIn("preempt=00000000", rendered)
        self.assertIn("pirq=00000000", rendered)
        self.assertIn("pmask=00000000", rendered)
        self.assertIn("pframe=00000000/00000000/00000000/00000000/00000000", rendered)
        self.assertIn("pspin=50524545", rendered)

    def test_classifies_missing_long_run_cadence_after_core_proofs_are_green(self):
        primary, notes = self.classify(audioirq="00000000", refill="00000000")

        self.assertEqual(primary, "long-run-cadence-not-proven")
        rendered = "\n".join(notes)
        self.assertIn("zero SB16/music cadence fields", rendered)
        self.assertIn("audioirq=00000000", rendered)
        self.assertIn("refill=00000000", rendered)

    def test_classifies_audio_pressure_as_long_run_cadence_lane(self):
        primary, notes = self.classify(musicdrops="00000001")

        self.assertEqual(primary, "long-run-cadence-not-proven")
        self.assertIn("audio pressure counters are nonzero", "\n".join(notes))

    def test_classifies_green_status_as_needing_full_proof_gates(self):
        primary, notes = self.classify()

        self.assertEqual(primary, "playability-status-green")
        self.assertIn("no obvious first-failure", "\n".join(notes))
        self.assertIn("long-run-cadence", "\n".join(notes))

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
