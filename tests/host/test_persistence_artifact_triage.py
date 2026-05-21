import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))
try:
    import triage_persistence_artifacts
finally:
    sys.path.pop(0)


def status_line(**overrides):
    fields = {
        "exec": "OK",
        "path": "DOOM.ELF",
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
        "preempt": "00000008",
        "pirq": "00000008",
        "pattempt": "00000010",
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
        "doomsav": "00000000/FFFFFFFF",
        "saverd": "00000000/00000000",
        "savewr": "00000000/00000000",
        "saveclose": "00000000",
        "savemode": "00000000:00000000",
        "saveact": "00000000/00000000/FFFFFFFF/00000000",
        "savedesc": "00000000/00000000",
        "savestm": "00000000/FFFFFFFF/FFFFFFFF/00000000/00000000",
        "savethk": "FFFFFFFF/00000000/FFFFFFFF/00000000",
        "fwr": "00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000",
        "fal": "00000000/00000000/00000000/00000000",
        "fio": "00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(
        f"{name}={value}" for name, value in fields.items()
    )


def write_green_package(artifact):
    (artifact / "status.txt").write_text(status_line(), encoding="utf-8")
    (artifact / "status.persistence-write.txt").write_text(
        status_line(
            doomsav="00000009/00000000",
            savewr="00006476/00000003",
            saveclose="00000001",
            savemode="00000301:000001B6",
            savedesc="00000001/00000001",
        ),
        encoding="utf-8",
    )
    (artifact / "status.persistence-load.txt").write_text(
        status_line(
            doomsav="0000000A/00000000",
            saverd="00006476/00000003",
            savewr="00000000/00000000",
            saveclose="00000001",
            saveact="00000060/00000000/00000000/00000005",
        ),
        encoding="utf-8",
    )
    (artifact / "status.persistence-write-proof.txt").write_text(
        "persistence write proof OK\n",
        encoding="utf-8",
    )
    (artifact / "status.persistence-load-proof.txt").write_text(
        "persistence load proof OK\n",
        encoding="utf-8",
    )


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_manifest(artifact, *, corrupt_hash=False):
    status_files = {}
    for phase, relpath in (
        ("final", "status.txt"),
        ("write", "status.persistence-write.txt"),
        ("load", "status.persistence-load.txt"),
    ):
        digest = sha256(artifact / relpath)
        if corrupt_hash and phase == "load":
            digest = "0" * 64
        status_files[phase] = {
            "path": relpath,
            "sha256": digest,
            "bytes": (artifact / relpath).stat().st_size,
        }
    (artifact / "gameplay-proof.json").write_text(
        json.dumps(
            {
                "schema": "scripted-gameplay-proof-v1",
                "phase_order": ["final", "write", "load"],
                "status_files": status_files,
            },
            sort_keys=True,
        )
        + "\n",
        encoding="utf-8",
    )


class PersistenceArtifactTriageTests(unittest.TestCase):
    def test_green_write_and_load_proof(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_green_package(artifact)
            write_manifest(artifact)

            result = triage_persistence_artifacts.triage_artifact_dir(artifact)
            rendered = triage_persistence_artifacts.render_report(result)

        self.assertEqual(result.overall, "persistence-proof-green")
        self.assertEqual(result.phase("save-write").classification, "persistence-save-write-green")
        self.assertEqual(result.phase("reboot-load").classification, "persistence-reboot-load-green")
        self.assertIn("savewr=0/0 is expected on a pure load boot", rendered)

    def test_load_not_completed_is_load_phase_failure(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_green_package(artifact)
            (artifact / "status.persistence-load.txt").write_text(
                status_line(
                    doomsav="00000002/00000000",
                    saverd="00006476/00000003",
                    savewr="00000000/00000000",
                    saveclose="00000000",
                    saveact="00000020/00000003/00000000/00000003",
                ),
                encoding="utf-8",
            )
            write_manifest(artifact)

            result = triage_persistence_artifacts.triage_artifact_dir(artifact)

        self.assertEqual(result.overall, "persistence-load-not-completed")
        self.assertEqual(result.phase("reboot-load").state, "fail")
        self.assertEqual(result.phase("reboot-load").classification, "persistence-load-not-completed")
        self.assertIn("reboot/load phase", result.interpretation)

    def test_manifest_status_mismatch_outranks_green_statuses(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_green_package(artifact)
            write_manifest(artifact, corrupt_hash=True)

            result = triage_persistence_artifacts.triage_artifact_dir(artifact)
            rendered = triage_persistence_artifacts.render_report(result)

        self.assertEqual(result.overall, "manifest-status-mismatch")
        self.assertEqual(result.phase("manifest/status").state, "fail")
        self.assertIn("sha256 mismatch", rendered)
        self.assertIn("artifact/checker evidence is inconsistent", result.interpretation)

    def test_save_write_input_no_effect_is_green_when_save_write_is_proven(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            write_green_package(artifact)
            (artifact / "status.persistence-write.txt").write_text(
                status_line(
                    pflags="00000023",
                    keyseen="00000001",
                    pdelta="00000000",
                    pangledelta="00000000",
                    mousepkt="00000000",
                    doomsav="0000000D/00000000",
                    savewr="00006476/00000001",
                    saveclose="00000001",
                    savemode="00000301:000001B6",
                    savedesc="00000009/0A118936",
                ),
                encoding="utf-8",
            )
            write_manifest(artifact)

            result = triage_persistence_artifacts.triage_artifact_dir(artifact)
            rendered = triage_persistence_artifacts.render_report(result)

        self.assertEqual(result.overall, "persistence-proof-green")
        self.assertEqual(result.phase("save-write").state, "pass")
        self.assertEqual(result.phase("save-write").classification, "persistence-save-write-green")
        self.assertIn("persistence triage only requires nonzero DOOMSAV write/close", rendered)

    def test_load_phase_save_write_zero_does_not_become_save_write_failure(self):
        with tempfile.TemporaryDirectory() as tmp:
            artifact = Path(tmp)
            (artifact / "status.txt").write_text(status_line(), encoding="utf-8")
            (artifact / "status.persistence-load.txt").write_text(
                status_line(
                    doomsav="00000002/00000000",
                    saverd="00006476/00000003",
                    savewr="00000000/00000000",
                    saveclose="00000000",
                    saveact="00000020/00000003/00000000/00000003",
                ),
                encoding="utf-8",
            )

            result = triage_persistence_artifacts.triage_artifact_dir(artifact)
            rendered = triage_persistence_artifacts.render_report(result)

        self.assertEqual(result.overall, "persistence-load-not-completed")
        self.assertEqual(result.phase("save-write").state, "missing")
        self.assertNotIn("persistence-save-write-failed", rendered)
        self.assertIn("savewr=0/0 is expected on a pure load boot", rendered)


if __name__ == "__main__":
    unittest.main()
