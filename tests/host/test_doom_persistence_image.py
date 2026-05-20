import importlib.util
import subprocess
import sys
import tempfile
import struct
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / "build"


def load_tool(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


make_wad_image = load_tool("make_wad_image", ROOT / "tools" / "make_wad_image.py")
check_persistence = load_tool(
    "check_doom_persistence_image",
    ROOT / "tools" / "check_doom_persistence_image.py",
)


def doom_player_record():
    record = bytearray(check_persistence.DOOM_PLAYER_RECORD_BYTES)

    def u32(offset, value):
        struct.pack_into("<I", record, offset, value)

    def s32(offset, value):
        struct.pack_into("<i", record, offset, value)

    u32(4, 0)  # PST_LIVE
    s32(16, 41 << 16)
    s32(20, 41 << 16)
    s32(24, 0)
    s32(28, 0)
    s32(32, 100)
    s32(36, 0)
    s32(40, 0)
    u32(112, 1)  # wp_pistol
    u32(116, 10)  # wp_nochange
    u32(120, 1)  # fist
    u32(124, 1)  # pistol
    s32(156, 50)
    s32(160, 0)
    s32(164, 0)
    s32(168, 0)
    s32(172, 200)
    s32(176, 50)
    s32(180, 300)
    s32(184, 50)
    u32(244, 1)
    s32(248, 1)
    return bytes(record)


def doom_save_payload(description="VIBE SAVE", version="version 110", tail_size=4096):
    payload = bytearray()
    payload.extend(description.encode("ascii")[:23].ljust(24, b"\0"))
    payload.extend(version.encode("ascii")[:15].ljust(16, b"\0"))
    payload.extend(b"\x03\x01\x01\x01\x00\x00\x00\x00\x00\x46")
    while len(payload) % 4:
        payload.append(0)
    payload.extend(doom_player_record())
    payload.extend(bytes(((index * 37 + 11) & 0xFF for index in range(tail_size))))
    payload.append(check_persistence.SAVE_CONSISTENCY_MARKER)
    return bytes(payload)


def doom_default_payload(screenblocks=9, chatmacro=b"HELLO"):
    return (
        b"mouse_sensitivity\t\t5\n"
        b"use_mouse\t\t1\n"
        + f"screenblocks\t\t{screenblocks}\n".encode("ascii")
        + b"chatmacro0\t\t\""
        + chatmacro
        + b"\"\n"
    )


def reboot_status(**overrides):
    fields = {
        "exec": "OK",
        "path": "DOOM.ELF",
        "execsys": "00000001/00000001/00000000/00000001/00000001/00000000",
        "execerr": "00000000",
        "execres": "00000000",
        "target": "00000002",
        "ppid": "00000001",
        "entry": "0102F730",
        "stack": "01FFFFB0",
        "argc": "00000001",
        "argv": "01FFFFB4",
        "envp": "01FFFFBC",
        "argv0": "01FFFFC0",
        "envp0": "00000000",
        "doom": "OK",
        "doomrun": "RUN",
        "doomopen": "OK",
        "doomread": "OK",
        "doomseek": "00000001",
        "doomwad": "00000002/00000002/00000001/44415749",
        "doomsbrk": "00000010",
        "doominit": "000001FF/00000009",
        "doomsav": "00000000/FFFFFFFF",
        "saverd": "00000000/00000000",
        "savewr": "00000000/00000000",
        "saveclose": "00000000",
        "savemode": "00000000:00000000",
        "doomexit": "00000000",
        "doomfault": "00000000",
        "doomfaultip": "00000000",
        "doomfaultv": "00000000",
        "doomfaulterr": "00000000",
        "fault": "00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000",
        "panic": "NONE",
        "shutdown": "NONE",
        "gameplay": "OK",
        "gfx": "OK",
        "doompresent": "00000001",
        "leveltime": "00000001",
        "dtick": "00000001",
        "pself": "OK",
        "pg": "ON",
        "pmm": "OK",
        "vmm": "OK",
        "libc": "OK",
        "c": "OK",
        "usr": "OK",
        "wad": "OK",
        "lmp": "OK",
        "heap": "OK",
        "free": "00700000",
        "ticks": "00000003",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(f"{name}={value}" for name, value in fields.items())


def default_write_status(**overrides):
    fields = {
        "doom": "OK",
        "doomrun": "EXIT",
        "doomopen": "OK",
        "doomread": "OK",
        "doomwrite": "00000030",
        "doomclose": "00000003",
        "doommode": "00000301:000001B6",
        "doomexit": "00000000",
        "doomfault": "00000000",
        "doomfaultip": "00000000",
        "doomfaultv": "00000000",
        "doomfaulterr": "00000000",
        "fault": "00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000",
        "panic": "NONE",
        "shutdown": "NONE",
        "gameplay": "OK",
        "usr": "OK",
        "wad": "OK",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(f"{name}={value}" for name, value in fields.items())


def save_write_status(slot=1, **overrides):
    fields = {
        "doom": "OK",
        "doomrun": "RUN",
        "doomopen": "OK",
        "doomread": "OK",
        "doomwrite": "00000018",
        "doomclose": "00000001",
        "doommode": "00000301:000001B6",
        "doomsav": f"0000000D/{slot:08X}",
        "saverd": "00000000/00000000",
        "savewr": "00001000/00000001",
        "saveclose": "00000001",
        "savemode": "00000301:000001B6",
        "doomexit": "00000000",
        "doomfault": "00000000",
        "doomfaultip": "00000000",
        "doomfaultv": "00000000",
        "doomfaulterr": "00000000",
        "fault": "00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000",
        "panic": "NONE",
        "shutdown": "NONE",
        "gameplay": "OK",
        "usr": "OK",
        "wad": "OK",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(f"{name}={value}" for name, value in fields.items())


def load_status(slot=1, read_bytes=0x1200, leveltime=0x60, **overrides):
    fields = {
        "doomsav": f"0000000B/{slot:08X}",
        "saverd": f"{read_bytes:08X}/00000002",
        "savewr": "00000000/00000000",
        "saveclose": "00000002",
        "savemode": "00000000:00000000",
        "leveltime": f"{leveltime:08X}",
        "gmap": "00000101",
    }
    fields.update(overrides)
    return reboot_status(**fields)


class DoomPersistenceImageTests(unittest.TestCase):
    def write_temp_image(self, image):
        tmp = tempfile.NamedTemporaryFile(prefix="vibe-os-persist-", suffix=".img", delete=False)
        self.addCleanup(lambda: Path(tmp.name).unlink(missing_ok=True))
        tmp.write(image)
        tmp.close()
        return Path(tmp.name)

    def write_temp_text(self, text):
        tmp = tempfile.NamedTemporaryFile(
            prefix="vibe-os-persist-", suffix=".txt", mode="w", delete=False
        )
        self.addCleanup(lambda: Path(tmp.name).unlink(missing_ok=True))
        tmp.write(text)
        tmp.close()
        return Path(tmp.name)

    def test_checker_accepts_fresh_image_entries_without_claiming_written_state(self):
        summary = check_persistence.validate_image(BUILD / "disk.img")
        self.assertEqual(summary, ["persistence entries present"])

    def test_checker_accepts_doom_shaped_defaults_and_save_slot(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        image = bytearray(baseline)
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, doom_default_payload())
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[2], doom_save_payload())

        baseline_path = self.write_temp_image(baseline)
        path = self.write_temp_image(image)
        summary = check_persistence.validate_image(
            path,
            baseline_image=baseline_path,
            require_default=True,
            require_save_slots=[2],
        )

        self.assertIn("DEFAULT.CFG bytes=", summary[0])
        self.assertIn("changed-from-baseline", summary[0])
        self.assertIn("DOOMSAV2.DSG bytes=", summary[1])
        self.assertIn("changed-from-baseline", summary[1])
        self.assertIn("description='VIBE SAVE'", summary[1])
        self.assertIn("version='version 110'", summary[1])
        self.assertIn("leveltime=70", summary[1])

    def test_checker_can_require_dynamic_fat_mutation_proof_on_image_copy(self):
        summary = check_persistence.validate_image(
            BUILD / "disk.img",
            require_dynamic_fat_proof=True,
        )

        self.assertIn("dynamic FAT allocation/free/truncate proof=OK", summary[0])
        self.assertIn("scratch=FATPROOF.TMP", summary[0])
        self.assertIn("clusters=2/4/2", summary[0])
        self.assertIn("remount=OK", summary[0])

        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        self.assertIsNone(fs.root_file_metadata(make_wad_image.DYNAMIC_FAT_PROOF_NAME))

    def test_fresh_doom_state_entries_are_unallocated_not_preallocated(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)

        for name in (
            make_wad_image.WRITABLE_DEFAULT_NAME,
            *make_wad_image.WRITABLE_SAVE_NAMES,
        ):
            with self.subTest(name=name):
                meta = fs.root_file_metadata(name)
                self.assertIsNotNone(meta)
                self.assertEqual(meta["cluster"], 0)
                self.assertEqual(meta["size"], 0)
                self.assertEqual(fs.read_root_file(name), b"")

        fs.validate_fat_copies_match()
        fs.validate_allocated_clusters_reachable()

    def test_checker_rejects_dynamic_fat_proof_when_root_directory_is_full(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        root_start = fs.root_lba * make_wad_image.SECTOR_SIZE
        for offset in range(0, fs.root_size, 32):
            entry = root_start + offset
            if image[entry] == 0:
                index = offset // 32
                image[entry:entry + 11] = f"F{index:07d}TMP".encode("ascii")
                image[entry + 11] = make_wad_image.FAT_ATTR_ARCHIVE
                struct.pack_into("<H", image, entry + 26, 0)
                struct.pack_into("<I", image, entry + 28, 0)

        path = self.write_temp_image(image)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "root directory is full"):
            check_persistence.validate_image(path, require_dynamic_fat_proof=True)

    def test_checker_proves_requested_entries_changed_from_baseline_image(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        image = bytearray(baseline)
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, doom_default_payload())
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0], doom_save_payload("REBOOT PROOF"))

        baseline_path = self.write_temp_image(baseline)
        image_path = self.write_temp_image(image)
        summary = check_persistence.validate_image(
            image_path,
            baseline_image=baseline_path,
            require_default=True,
            require_save_slots=[0],
        )

        self.assertIn("DEFAULT.CFG bytes=", summary[0])
        self.assertIn("changed-from-baseline", summary[0])
        self.assertIn("DOOMSAV0.DSG bytes=", summary[1])
        self.assertIn("changed-from-baseline", summary[1])
        self.assertIn("REBOOT PROOF", summary[1])

    def test_checker_proves_requested_entries_survived_reboot_image(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        after_write = bytearray(baseline)
        fs = make_wad_image.Fat16Image(after_write)
        fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, doom_default_payload())
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[3], doom_save_payload("STILL HERE"))

        after_reboot = bytearray(after_write)
        baseline_path = self.write_temp_image(baseline)
        write_path = self.write_temp_image(after_write)
        reboot_path = self.write_temp_image(after_reboot)
        save_status_path = self.write_temp_text(save_write_status(slot=3))

        summary = check_persistence.validate_image(
            reboot_path,
            baseline_image=baseline_path,
            reboot_baseline_image=write_path,
            save_write_status_path=save_status_path,
            require_default=True,
            require_save_slots=[3],
        )

        self.assertIn("changed-from-baseline", summary[0])
        self.assertIn("survived-reboot", summary[0])
        self.assertIn("DOOMSAV3.DSG bytes=", summary[1])
        self.assertIn("survived-reboot", summary[1])
        self.assertIn("STILL HERE", summary[1])
        self.assertIn("save write status closed=OK", summary)

    def test_checker_rejects_save_slot_proof_without_fresh_baseline(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0], doom_save_payload("NO BASELINE"))
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "requires --baseline-image"):
            check_persistence.validate_image(path, require_save_slots=[0])

    def test_checker_rejects_preseeded_save_slot_baseline(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        baseline_fs = make_wad_image.Fat16Image(baseline)
        baseline_fs.write_root_file(
            make_wad_image.WRITABLE_SAVE_NAMES[0],
            doom_save_payload("PRESEEDED"),
        )
        image = bytearray(baseline)
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(
            make_wad_image.WRITABLE_SAVE_NAMES[0],
            doom_save_payload("AFTER WRITE"),
        )

        baseline_path = self.write_temp_image(baseline)
        image_path = self.write_temp_image(image)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "preseeded evidence"):
            check_persistence.validate_image(
                image_path,
                baseline_image=baseline_path,
                require_save_slots=[0],
            )

    def test_checker_gates_reboot_status_when_claiming_reboot_image(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        after_write = bytearray(baseline)
        fs = make_wad_image.Fat16Image(after_write)
        fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, doom_default_payload())
        after_reboot = bytearray(after_write)

        baseline_path = self.write_temp_image(baseline)
        write_path = self.write_temp_image(after_write)
        reboot_path = self.write_temp_image(after_reboot)
        status_path = self.write_temp_text(reboot_status())

        summary = check_persistence.validate_image(
            reboot_path,
            baseline_image=baseline_path,
            reboot_baseline_image=write_path,
            reboot_status_path=status_path,
            require_default=True,
        )

        self.assertIn("survived-reboot", summary[0])
        self.assertIn("reboot status runtime=OK", summary)

    def test_checker_gates_default_write_status_when_claiming_quit_default(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        image = bytearray(baseline)
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, doom_default_payload())

        baseline_path = self.write_temp_image(baseline)
        image_path = self.write_temp_image(image)
        status_path = self.write_temp_text(default_write_status())

        summary = check_persistence.validate_image(
            image_path,
            baseline_image=baseline_path,
            write_status_path=status_path,
            require_default=True,
        )

        self.assertIn("changed-from-baseline", summary[0])
        self.assertIn("default write status closed=OK", summary)

    def test_checker_accepts_running_default_write_status_after_close(self):
        check_persistence.validate_default_write_status(default_write_status(doomrun="RUN"))

    def test_checker_gates_save_write_status_when_claiming_rebooted_save_slot(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        after_write = bytearray(baseline)
        fs = make_wad_image.Fat16Image(after_write)
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[1], doom_save_payload("SAVE WRITE"))
        after_reboot = bytearray(after_write)

        baseline_path = self.write_temp_image(baseline)
        write_path = self.write_temp_image(after_write)
        reboot_path = self.write_temp_image(after_reboot)
        status_path = self.write_temp_text(save_write_status(slot=1))

        summary = check_persistence.validate_image(
            reboot_path,
            baseline_image=baseline_path,
            reboot_baseline_image=write_path,
            save_write_status_path=status_path,
            require_save_slots=[1],
        )

        self.assertIn("DOOMSAV1.DSG bytes=", summary[0])
        self.assertIn("survived-reboot", summary[0])
        self.assertIn("save write status closed=OK", summary)

    def test_checker_gates_save_load_status_when_claiming_playable_save_slot(self):
        save_payload = doom_save_payload("VIBE-SLOT-1")
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        after_write = bytearray(baseline)
        fs = make_wad_image.Fat16Image(after_write)
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[1], save_payload)
        after_reboot = bytearray(after_write)

        baseline_path = self.write_temp_image(baseline)
        write_path = self.write_temp_image(after_write)
        reboot_path = self.write_temp_image(after_reboot)
        status_path = self.write_temp_text(save_write_status(slot=1))
        load_status_path = self.write_temp_text(
            load_status(slot=1, read_bytes=len(save_payload), leveltime=71)
        )

        summary = check_persistence.validate_image(
            reboot_path,
            baseline_image=baseline_path,
            reboot_baseline_image=write_path,
            reboot_status_path=load_status_path,
            save_write_status_path=status_path,
            load_status_path=load_status_path,
            require_save_slots=[1],
            require_save_descriptions={1: "VIBE-SLOT-1"},
        )

        self.assertIn("DOOMSAV1.DSG bytes=", summary[0])
        self.assertIn("description='VIBE-SLOT-1'", summary[0])
        self.assertIn("survived-reboot", summary[0])
        self.assertIn("reboot status runtime=OK", summary)
        self.assertIn("save load status gameplay=OK slot=1", summary)

    def test_checker_rejects_unexpected_save_description(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        image = bytearray(baseline)
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(
            make_wad_image.WRITABLE_SAVE_NAMES[2],
            doom_save_payload("OTHER-SLOT-2"),
        )

        baseline_path = self.write_temp_image(baseline)
        image_path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "description must be"):
            check_persistence.validate_image(
                image_path,
                baseline_image=baseline_path,
                require_save_slots=[2],
                require_save_descriptions={2: "VIBE-SLOT-2"},
            )

    def test_checker_rejects_save_description_without_matching_slot(self):
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "matching --require-save-slot"):
            check_persistence.validate_image(
                BUILD / "disk.img",
                require_save_descriptions={4: "VIBE-SLOT-4"},
            )

    def test_checker_requires_save_write_status_for_rebooted_save_slot(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        after_write = bytearray(baseline)
        fs = make_wad_image.Fat16Image(after_write)
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[1], doom_save_payload("NEEDS STATUS"))

        baseline_path = self.write_temp_image(baseline)
        write_path = self.write_temp_image(after_write)
        reboot_path = self.write_temp_image(bytearray(after_write))

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "--save-write-status"):
            check_persistence.validate_image(
                reboot_path,
                baseline_image=baseline_path,
                reboot_baseline_image=write_path,
                require_save_slots=[1],
            )

    def test_checker_rejects_save_write_status_without_save_output(self):
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "doomwrite"):
            check_persistence.validate_save_write_status(save_write_status(doomwrite="00000000"))
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "doomclose"):
            check_persistence.validate_save_write_status(save_write_status(doomclose="00000000"))
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "O_WRONLY"):
            check_persistence.validate_save_write_status(save_write_status(doommode="00000000:000001B6"))
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "doomsav"):
            check_persistence.validate_save_write_status(save_write_status(doomsav="00000009/00000001"))
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "savewr"):
            check_persistence.validate_save_write_status(save_write_status(savewr="00000000/00000000"))

    def test_checker_rejects_save_load_status_without_full_payload_read(self):
        save_payload = doom_save_payload("MENU ONLY")
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        after_write = bytearray(baseline)
        fs = make_wad_image.Fat16Image(after_write)
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0], save_payload)

        baseline_path = self.write_temp_image(baseline)
        write_path = self.write_temp_image(after_write)
        reboot_path = self.write_temp_image(bytearray(after_write))
        status_path = self.write_temp_text(save_write_status(slot=0))
        menu_only_path = self.write_temp_text(load_status(slot=0, read_bytes=24, leveltime=80))

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "full DOOMSAV payload"):
            check_persistence.validate_image(
                reboot_path,
                baseline_image=baseline_path,
                reboot_baseline_image=write_path,
                reboot_status_path=menu_only_path,
                save_write_status_path=status_path,
                load_status_path=menu_only_path,
                require_save_slots=[0],
            )

    def test_checker_rejects_save_load_status_before_saved_leveltime_or_wrong_slot(self):
        save_payload = doom_save_payload("WRONG LOAD")
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        after_write = bytearray(baseline)
        fs = make_wad_image.Fat16Image(after_write)
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[2], save_payload)

        baseline_path = self.write_temp_image(baseline)
        write_path = self.write_temp_image(after_write)
        reboot_path = self.write_temp_image(bytearray(after_write))
        status_path = self.write_temp_text(save_write_status(slot=2))
        low_time_path = self.write_temp_text(load_status(slot=2, read_bytes=len(save_payload), leveltime=1))
        wrong_slot_path = self.write_temp_text(load_status(slot=1, read_bytes=len(save_payload), leveltime=80))

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "leveltime"):
            check_persistence.validate_image(
                reboot_path,
                baseline_image=baseline_path,
                reboot_baseline_image=write_path,
                reboot_status_path=low_time_path,
                save_write_status_path=status_path,
                load_status_path=low_time_path,
                require_save_slots=[2],
            )
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "slot must be 2"):
            check_persistence.validate_image(
                reboot_path,
                baseline_image=baseline_path,
                reboot_baseline_image=write_path,
                reboot_status_path=wrong_slot_path,
                save_write_status_path=status_path,
                load_status_path=wrong_slot_path,
                require_save_slots=[2],
            )

    def test_checker_rejects_default_write_status_before_default_close(self):
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "doomclose"):
            check_persistence.validate_default_write_status(
                default_write_status(doomrun="RUN", doomclose="00000002")
            )

    def test_checker_reports_write_status_failure_before_default_bytes(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        image = bytearray(baseline)
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, b"screenblocks\t\t10")

        baseline_path = self.write_temp_image(baseline)
        image_path = self.write_temp_image(image)
        status_path = self.write_temp_text(default_write_status(doomclose="00000002"))

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "doomclose"):
            check_persistence.validate_image(
                image_path,
                baseline_image=baseline_path,
                write_status_path=status_path,
                require_default=True,
            )

    def test_checker_rejects_faulting_reboot_status(self):
        fault = reboot_status(
            doomrun="FAULT",
            gameplay="WAIT",
            usr="FAIL",
            doomfault="01946000",
            doomfaultip="01029F20",
            doomfaultv="0000000E",
            doomfaulterr="00000007",
            fault="0000000E/00000007/01029F20/0000001B/01FFFDB4/00000023/01946000/00000002/00000002/00000002/00000005",
        )

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "doomrun"):
            check_persistence.validate_reboot_status(fault)

    def test_checker_rejects_requested_entry_that_changed_during_reboot(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        after_write = bytearray(baseline)
        fs = make_wad_image.Fat16Image(after_write)
        fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, doom_default_payload())

        after_reboot = bytearray(after_write)
        reboot_fs = make_wad_image.Fat16Image(after_reboot)
        reboot_fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, doom_default_payload(10))

        baseline_path = self.write_temp_image(baseline)
        write_path = self.write_temp_image(after_write)
        reboot_path = self.write_temp_image(after_reboot)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "did not survive reboot"):
            check_persistence.validate_image(
                reboot_path,
                baseline_image=baseline_path,
                reboot_baseline_image=write_path,
                require_default=True,
            )

    def test_checker_rejects_save_slot_that_changed_during_reboot(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        after_write = bytearray(baseline)
        fs = make_wad_image.Fat16Image(after_write)
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0], doom_save_payload("WRITE BOOT"))

        after_reboot = bytearray(after_write)
        reboot_fs = make_wad_image.Fat16Image(after_reboot)
        reboot_fs.write_root_file(
            make_wad_image.WRITABLE_SAVE_NAMES[0],
            doom_save_payload("REBOOT MUTATE"),
        )

        baseline_path = self.write_temp_image(baseline)
        write_path = self.write_temp_image(after_write)
        reboot_path = self.write_temp_image(after_reboot)
        status_path = self.write_temp_text(save_write_status(slot=0))

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "did not survive reboot"):
            check_persistence.validate_image(
                reboot_path,
                baseline_image=baseline_path,
                reboot_baseline_image=write_path,
                save_write_status_path=status_path,
                require_save_slots=[0],
            )

    def test_checker_rejects_protected_wad_or_elf_mutation_from_baseline(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        image = bytearray(baseline)
        fs = make_wad_image.Fat16Image(image)
        wad_meta = fs.root_file_metadata(make_wad_image.PROTECTED_ROOT_NAMES[0])
        image[fs.cluster_offset(wad_meta["cluster"])] ^= 0x01
        fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, doom_default_payload())

        baseline_path = self.write_temp_image(baseline)
        image_path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "protected entry DOOM1"):
            check_persistence.validate_image(
                image_path,
                baseline_image=baseline_path,
                require_default=True,
            )

    def test_checker_rejects_divergent_fat_copies(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        second_fat = (fs.partition_lba + fs.reserved + fs.sectors_per_fat) * make_wad_image.SECTOR_SIZE
        struct.pack_into("<H", image, second_fat + 2 * 2, fs.fat_entry(2) ^ 0x0001)
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "FAT copy 1 differs"):
            check_persistence.validate_image(path)

    def test_checker_rejects_orphaned_shared_or_duplicate_root_storage(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        leaked_chain = fs.write_root_file(b"LEAK    BIN", b"L" * 700)
        leaked_entry = fs.root_entry_offset(b"LEAK    BIN")
        image[leaked_entry] = 0xE5
        path = self.write_temp_image(image)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "not reachable"):
            check_persistence.validate_image(path)
        self.assertGreater(len(leaked_chain), 0)

        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        first_chain = fs.write_root_file(b"ALPHA   TXT", b"A" * 700)
        fs.write_root_file(b"BETA    TXT", b"B" * 700)
        beta_entry = fs.root_entry_offset(b"BETA    TXT")
        struct.pack_into("<H", image, beta_entry + 26, first_chain[0])
        path = self.write_temp_image(image)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "shared by"):
            check_persistence.validate_image(path)

        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        source_entry = fs.root_entry_offset(make_wad_image.WRITABLE_DEFAULT_NAME)
        root_start = fs.root_lba * make_wad_image.SECTOR_SIZE
        duplicate_entry = None
        for offset in range(0, fs.root_size, 32):
            entry = root_start + offset
            if image[entry] == 0:
                duplicate_entry = entry
                break
        self.assertIsNotNone(duplicate_entry)
        image[duplicate_entry:duplicate_entry + 32] = image[source_entry:source_entry + 32]
        path = self.write_temp_image(image)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "duplicate live"):
            check_persistence.validate_image(path)

    def test_checker_accepts_readonly_subdirectory_lookup_and_listing(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)

        directory_cluster = fs.create_subdirectory(b"CONFIG  DIR")
        file_chain = fs.write_directory_file(b"CONFIG  DIR", b"LEVELS  TXT", b"E1M1\nE1M2\n")

        root_names = {entry["name"] for entry in fs.list_root_directory()}
        self.assertIn(b"CONFIG  DIR", root_names)
        self.assertEqual(
            fs.entry_metadata_at_path((b"CONFIG  DIR",))["cluster"],
            directory_cluster,
        )
        self.assertEqual(
            fs.read_file_at_path((b"CONFIG  DIR", b"LEVELS  TXT")),
            b"E1M1\nE1M2\n",
        )
        self.assertEqual(
            fs.entry_metadata_at_path((b"CONFIG  DIR", b"LEVELS  TXT"))["cluster"],
            file_chain[0],
        )
        with self.assertRaises(IsADirectoryError):
            fs.read_root_file(b"CONFIG  DIR")
        with self.assertRaises(IsADirectoryError):
            fs.truncate_root_file(b"CONFIG  DIR")

        path = self.write_temp_image(image)
        self.assertEqual(check_persistence.validate_image(path), ["persistence entries present"])

    def test_checker_rejects_orphans_and_crosslinks_inside_subdirectories(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        fs.create_subdirectory(b"CONFIG  DIR")
        file_chain = fs.write_directory_file(b"CONFIG  DIR", b"LEVELS  TXT", b"L" * 700)
        file_entry = fs.entry_metadata_at_path((b"CONFIG  DIR", b"LEVELS  TXT"))["entry"]
        image[file_entry] = 0xE5
        path = self.write_temp_image(image)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "not reachable"):
            check_persistence.validate_image(path)
        self.assertGreater(len(file_chain), 0)

        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        root_chain = fs.write_root_file(b"ROOT    TXT", b"R" * 700)
        fs.create_subdirectory(b"CONFIG  DIR")
        fs.write_directory_file(b"CONFIG  DIR", b"LEVELS  TXT", b"L" * 700)
        child_entry = fs.entry_metadata_at_path((b"CONFIG  DIR", b"LEVELS  TXT"))["entry"]
        struct.pack_into("<H", image, child_entry + 26, root_chain[0])
        path = self.write_temp_image(image)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "shared by"):
            check_persistence.validate_image(path)

    def test_fat_image_detects_corrupt_dynamic_chains(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        name = b"RUNTIME TXT"

        chain = fs.write_root_file(name, b"A" * 700)
        fs.set_fat_entry(chain[-1], chain[0])
        with self.assertRaisesRegex(ValueError, "contains a loop"):
            fs.read_root_file(name)

        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        chain = fs.write_root_file(name, b"B" * 700)
        fs.set_fat_entry(chain[0], 0)
        with self.assertRaisesRegex(ValueError, "free cluster"):
            fs.read_root_file(name)

    def test_delete_reuses_root_slot_and_restores_free_cluster_budget(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        name = b"RUNTIME TXT"
        before_free = fs.free_data_clusters()

        chain = fs.write_root_file(name, b"A" * 700)
        self.assertEqual(fs.free_data_clusters(), before_free - len(chain))

        freed = fs.delete_root_file(name)
        self.assertEqual(freed, chain)
        self.assertIsNone(fs.root_file_metadata(name))
        self.assertEqual(fs.free_data_clusters(), before_free)

        new_chain = fs.write_root_file(name, b"new runtime bytes")
        self.assertEqual(fs.read_root_file(name), b"new runtime bytes")
        self.assertEqual(fs.free_data_clusters(), before_free - len(new_chain))

    def test_dynamic_file_growth_sparse_write_and_resize_preserve_fat_copies(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        name = b"GROWTH  BIN"
        before_free = fs.free_data_clusters()

        first_chain = fs.write_root_file(name, b"A" * 600)
        self.assertEqual(len(first_chain), 2)

        grown_chain = fs.write_root_file_at(name, 1500, b"END")
        grown = fs.read_root_file(name)
        self.assertEqual(len(grown), 1503)
        self.assertEqual(grown[:600], b"A" * 600)
        self.assertEqual(grown[600:1500], b"\0" * 900)
        self.assertEqual(grown[1500:], b"END")
        self.assertEqual(fs.free_data_clusters(), before_free - len(grown_chain))

        shrunk_chain = fs.resize_root_file(name, 513)
        shrunk = fs.read_root_file(name)
        self.assertEqual(len(shrunk), 513)
        self.assertEqual(shrunk, b"A" * 513)
        self.assertEqual(fs.free_data_clusters(), before_free - len(shrunk_chain))
        self.assertLess(len(shrunk_chain), len(grown_chain))

        emptied_chain = fs.resize_root_file(name, 0)
        self.assertEqual(emptied_chain, shrunk_chain)
        self.assertEqual(fs.read_root_file(name), b"")
        self.assertEqual(fs.free_data_clusters(), before_free)
        fs.validate_fat_copies_match()

    def test_doom_state_files_allocate_sparse_extend_and_free_dynamic_chains(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        before_free = fs.free_data_clusters()
        default_name = make_wad_image.WRITABLE_DEFAULT_NAME
        save_name = make_wad_image.WRITABLE_SAVE_NAMES[0]
        cluster_bytes = make_wad_image.cluster_size()

        default_payload = b"D" * (cluster_bytes + 23)
        default_chain = fs.write_root_file(default_name, default_payload)
        default_meta = fs.root_file_metadata(default_name)
        self.assertEqual(len(default_chain), 2)
        self.assertEqual(default_meta["cluster"], default_chain[0])
        self.assertEqual(default_meta["size"], len(default_payload))
        self.assertEqual(fs.read_root_file(default_name), default_payload)
        default_tail_start = fs.cluster_offset(default_chain[-1]) + 23
        self.assertEqual(
            image[default_tail_start:fs.cluster_offset(default_chain[-1]) + cluster_bytes],
            b"\0" * (cluster_bytes - 23),
        )

        save_offset = cluster_bytes * 2 + 17
        save_chain = fs.write_root_file_at(save_name, save_offset, b"SAVE")
        save_payload = fs.read_root_file(save_name)
        self.assertEqual(len(save_chain), 3)
        self.assertEqual(save_payload[:save_offset], b"\0" * save_offset)
        self.assertEqual(save_payload[save_offset:], b"SAVE")
        self.assertEqual(fs.free_data_clusters(), before_free - len(default_chain) - len(save_chain))
        fs.validate_fat_copies_match()

        replacement_chain = fs.write_root_file(default_name, b"short defaults\n")
        self.assertEqual(fs.read_root_file(default_name), b"short defaults\n")
        self.assertEqual(fs.fat_entry(default_chain[-1]), 0)
        self.assertEqual(replacement_chain, default_chain[:1])

        shrunk_save_chain = fs.resize_root_file(save_name, cluster_bytes + 1)
        self.assertEqual(shrunk_save_chain, save_chain[:2])
        self.assertEqual(fs.fat_entry(shrunk_save_chain[-1]), make_wad_image.FAT16_EOC_VALUE)
        self.assertEqual(fs.fat_entry(save_chain[-1]), 0)
        second_cluster_clear = fs.cluster_offset(shrunk_save_chain[-1]) + 1
        self.assertEqual(
            image[second_cluster_clear:fs.cluster_offset(shrunk_save_chain[-1]) + cluster_bytes],
            b"\0" * (cluster_bytes - 1),
        )

        freed_save_chain = fs.truncate_root_file(save_name)
        self.assertEqual(freed_save_chain, shrunk_save_chain)
        self.assertEqual(fs.root_file_metadata(save_name)["cluster"], 0)
        self.assertEqual(fs.root_file_metadata(save_name)["size"], 0)
        self.assertEqual(fs.free_data_clusters(), before_free - len(replacement_chain))
        fs.validate_fat_copies_match()

    def test_dynamic_truncate_rejects_corrupt_chain_without_partial_free(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        name = b"CORRUPT BIN"
        chain = fs.write_root_file(name, b"C" * 900)
        fs.set_fat_entry(chain[-1], chain[0])
        corrupt_entries = {cluster: fs.fat_entry(cluster) for cluster in chain}

        with self.assertRaisesRegex(ValueError, "contains a loop"):
            fs.truncate_root_file(name)

        for cluster, value in corrupt_entries.items():
            self.assertEqual(fs.fat_entry(cluster), value)
        self.assertEqual(fs.root_file_metadata(name)["size"], 900)

    def test_host_image_mutator_refuses_writes_to_protected_entries(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)

        for name in make_wad_image.PROTECTED_ROOT_NAMES:
            with self.subTest(name=name):
                with self.assertRaisesRegex(ValueError, "protected WAD/ELF"):
                    fs.write_root_file(name, b"mutated")
                with self.assertRaisesRegex(ValueError, "protected WAD/ELF"):
                    fs.truncate_root_file(name)
                with self.assertRaisesRegex(ValueError, "protected WAD/ELF"):
                    fs.delete_root_file(name)

    def test_checker_rejects_baseline_comparison_without_requested_entries(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "requires --require-default"):
            check_persistence.validate_image(path, baseline_image=path)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "requires --require-default"):
            check_persistence.validate_image(path, reboot_baseline_image=path)

    def test_checker_rejects_requested_entry_unchanged_from_baseline(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, doom_default_payload())
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "DEFAULT.CFG did not change"):
            check_persistence.validate_image(path, baseline_image=path, require_default=True)

    def test_checker_rejects_empty_default_or_non_doom_save(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0], b"not a doom save")
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "DEFAULT.CFG is still empty"):
            check_persistence.validate_image(path, require_default=True)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "too small"):
            check_persistence.validate_image(path, require_save_slots=[0])

    def test_checker_rejects_malformed_default_config_values(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(
            make_wad_image.WRITABLE_DEFAULT_NAME,
            b"mouse_sensitivity\t\tfast\n"
            b"use_mouse\t\t1\n"
            b"screenblocks\t\t9\n"
            b"chatmacro0\t\t\"HELLO\"\n",
        )
        path = self.write_temp_image(image)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "mouse_sensitivity"):
            check_persistence.validate_image(path, require_default=True)

        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(
            make_wad_image.WRITABLE_DEFAULT_NAME,
            b"mouse_sensitivity\t\t5\n"
            b"use_mouse\t\t1\n"
            b"screenblocks\t\t12\n"
            b"chatmacro0\t\tHELLO\n",
        )
        path = self.write_temp_image(image)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "screenblocks"):
            check_persistence.validate_image(path, require_default=True)

    def test_checker_rejects_save_header_without_serialized_game_state(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        payload = bytearray(doom_save_payload("EMPTY STATE"))
        player_end = (
            check_persistence.SAVE_GAMESTATE_OFFSET
            + 2
            + check_persistence.DOOM_PLAYER_RECORD_BYTES
        )
        payload[player_end:-1] = b"\0" * (len(payload) - player_end - 1)
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0], bytes(payload))
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "serialized game-state"):
            check_persistence.validate_image(path, require_save_slots=[0])

    def test_checker_rejects_fake_save_header_with_arbitrary_tail_bytes(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        payload = bytearray()
        payload.extend(b"FAKE SAVE".ljust(24, b"\0"))
        payload.extend(b"version 110".ljust(16, b"\0"))
        payload.extend(b"\x03\x01\x01\x01\x00\x00\x00\x00\x00\x46")
        payload.extend(bytes((index & 0xFF for index in range(check_persistence.MIN_SAVE_BYTES))))
        payload[-1] = check_persistence.SAVE_CONSISTENCY_MARKER
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0], bytes(payload))
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "plausible archived Doom player"):
            check_persistence.validate_image(path, require_save_slots=[0])

    def test_checker_rejects_save_without_final_consistency_marker(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        payload = bytearray(doom_save_payload())
        payload[-1] = 0
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0], bytes(payload))
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "consistency marker"):
            check_persistence.validate_image(path, require_save_slots=[0])

    def test_checker_rejects_save_without_player_one_active(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        payload = bytearray(doom_save_payload())
        payload[43] = 0
        payload[44] = 1
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0], bytes(payload))
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "player 1 active"):
            check_persistence.validate_image(path, require_save_slots=[0])

    def test_checker_rejects_partial_default_and_tiny_fake_save_header(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, b"screenblocks\t\t10\n")
        fs.write_root_file(
            make_wad_image.WRITABLE_SAVE_NAMES[0],
            doom_save_payload("SHORT SAVE", tail_size=16),
        )
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "complete Doom defaults"):
            check_persistence.validate_image(path, require_default=True)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "real Doom save payload"):
            check_persistence.validate_image(path, require_save_slots=[0])

    def test_checker_rejects_save_with_invalid_game_header(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        payload = bytearray(doom_save_payload())
        payload[40] = 9
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0], bytes(payload))
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "invalid skill"):
            check_persistence.validate_image(path, require_save_slots=[0])

    def test_checker_rejects_reboot_claim_without_fresh_baseline(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, doom_default_payload())
        path = self.write_temp_image(image)

        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "requires --baseline-image"):
            check_persistence.validate_image(path, reboot_baseline_image=path, require_default=True)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "--reboot-status"):
            check_persistence.validate_image(path, reboot_status_path=path, require_default=True)
        with self.assertRaisesRegex(check_persistence.PersistenceProofError, "--write-status"):
            check_persistence.validate_image(path, write_status_path=path, require_save_slots=[0])

    def test_checker_cli_reports_written_state_without_exporting_image_data(self):
        baseline = bytearray((BUILD / "disk.img").read_bytes())
        image = bytearray(baseline)
        fs = make_wad_image.Fat16Image(image)
        fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, doom_default_payload(10, b"REMOTE"))
        fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[1], doom_save_payload("REMOTE PROOF"))
        baseline_path = self.write_temp_image(baseline)
        path = self.write_temp_image(image)
        status_path = self.write_temp_text(reboot_status())
        write_status_path = self.write_temp_text(default_write_status())
        save_status_path = self.write_temp_text(save_write_status())

        result = subprocess.run(
            [
                sys.executable,
                str(ROOT / "tools" / "check_doom_persistence_image.py"),
                "--require-default",
                "--require-save-slot",
                "1",
                "--require-dynamic-fat-proof",
                "--baseline-image",
                str(baseline_path),
                "--reboot-baseline-image",
                str(path),
                "--reboot-status",
                str(status_path),
                "--write-status",
                str(write_status_path),
                "--save-write-status",
                str(save_status_path),
                str(path),
            ],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
        )

        self.assertIn("DEFAULT.CFG bytes=", result.stdout)
        self.assertIn("DOOMSAV1.DSG bytes=", result.stdout)
        self.assertIn("dynamic FAT allocation/free/truncate proof=OK", result.stdout)
        self.assertIn("remount=OK", result.stdout)
        self.assertIn("survived-reboot", result.stdout)
        self.assertIn("reboot status runtime=OK", result.stdout)
        self.assertIn("default write status closed=OK", result.stdout)
        self.assertIn("REMOTE PROOF", result.stdout)
        self.assertNotIn("IWAD", result.stdout)
        self.assertEqual(result.stderr, "")

    def test_persistence_doc_keeps_dynamic_fs_and_storage_boot_gaps_explicit(self):
        persistent_doc = (ROOT / "docs" / "persistent-fat16.md").read_text()
        gap_doc = (ROOT / "docs" / "post-checkpoint-gaps.md").read_text()
        makefile = (ROOT / "Makefile").read_text()

        for phrase in (
            "Writable semantics are still deliberately narrow",
            "root-level 8.3 files",
            "no subdirectories",
            "no rename",
            "no long filenames",
            "no POSIX delete-while-open behavior",
            "broader storage boot",
            "archived",
            "real-WAD cloud",
            "--require-dynamic-fat-proof",
            "dynamic filesystem behavior",
            "FATPROOF.TMP",
            "PERSISTENCE_REQUIRE_DYNAMIC_FAT_PROOF=1 make persistence-image-check",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, persistent_doc)
        self.assertIn("PERSISTENCE_REQUIRE_DYNAMIC_FAT_PROOF ?= 0", makefile)
        self.assertIn("--require-dynamic-fat-proof", makefile)
        self.assertIn("dynamic writable FS", gap_doc)
        self.assertIn("dynamic FAT allocation, free", gap_doc)
        self.assertIn("storage boot path", gap_doc)


if __name__ == "__main__":
    unittest.main()
