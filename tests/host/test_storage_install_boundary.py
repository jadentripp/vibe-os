import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / "build"
TOOL = ROOT / "tools" / "check_storage_install_boundary.py"

spec = importlib.util.spec_from_file_location("check_storage_install_boundary", TOOL)
check_storage_install_boundary = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check_storage_install_boundary)


class StorageInstallBoundaryTests(unittest.TestCase):
    def assertContainsPhrase(self, text, phrase):
        self.assertIn(" ".join(phrase.split()), " ".join(text.split()))

    def test_storage_boundary_rows_keep_install_claim_unclaimed(self):
        rows = check_storage_install_boundary.validate_repo_contract(ROOT)
        self.assertEqual(rows["GENERATED_FAT16_IMAGE"]["status"], "claimed")
        self.assertEqual(rows["CLOUD_MUTATE_REBOOT"]["status"], "proven")
        self.assertEqual(rows["HOST_RECOVERY_INSPECTION"]["gate"], "install-image-manifest")
        self.assertEqual(rows["ARBITRARY_DISK_INSTALL"]["status"], "unclaimed")
        self.assertEqual(rows["ARBITRARY_DISK_INSTALL"]["evidence"], "none")
        self.assertEqual(rows["ARBITRARY_DISK_RECOVERY"]["status"], "unclaimed")
        self.assertEqual(rows["ARBITRARY_DISK_RECOVERY"]["evidence"], "none")

    def test_checker_rejects_unbounded_install_or_recovery_claims(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "docs").mkdir()
            (root / "tests").mkdir()
            (root / "tools").mkdir()

            for relative in (
                "README.md",
                "tests/README.md",
                "docs/persistent-fat16.md",
                "docs/post-checkpoint-gaps.md",
                "tools/check_storage_install_boundary.py",
            ):
                src = ROOT / relative
                dst = root / relative
                dst.parent.mkdir(parents=True, exist_ok=True)
                dst.write_text(src.read_text())

            (root / "docs" / "storage-install-boundary.md").write_text(
                (ROOT / "docs" / "storage-install-boundary.md").read_text()
            )
            check_storage_install_boundary.validate_repo_contract(root)

            readme = root / "README.md"
            bad_claim = "This OS installs to " + "arbitrary disk media."
            readme.write_text(readme.read_text() + f"\n{bad_claim}\n")
            with self.assertRaisesRegex(
                check_storage_install_boundary.StorageBoundaryError,
                "possible unbounded storage install/recovery claim",
            ):
                check_storage_install_boundary.validate_repo_contract(root)

    def test_install_boundary_is_visible_from_main_claim_surfaces(self):
        readme = (ROOT / "README.md").read_text()
        persistence_doc = (ROOT / "docs" / "persistent-fat16.md").read_text()
        gap_doc = (ROOT / "docs" / "post-checkpoint-gaps.md").read_text()
        tests_readme = (ROOT / "tests" / "README.md").read_text()

        for text, phrase in (
            (readme, "not an installable general OS on arbitrary disks"),
            (readme, "docs/storage-install-boundary.md"),
            (readme, "tools/check_storage_install_boundary.py --image build/disk.img"),
            (persistence_doc, "not an arbitrary-disk install or recovery proof"),
            (persistence_doc, "install-image-manifest"),
            (gap_doc, "STORAGE_BOUNDARY[ARBITRARY_DISK_INSTALL] status=unclaimed"),
            (gap_doc, "blank-disk-to-bootable-vibe-os"),
            (tests_readme, "tools/check_storage_install_boundary.py"),
            (tests_readme, "install-image-manifest"),
        ):
            with self.subTest(phrase=phrase):
                self.assertContainsPhrase(text, phrase)

    def test_generated_image_manifest_verifies_layout_and_root_inventory(self):
        manifest = check_storage_install_boundary.inspect_image(BUILD / "disk.img")

        self.assertEqual(manifest["schema"], "vibe-os-install-image-manifest-v1")
        self.assertEqual(manifest["mbr"]["partition_type"], "0x06")
        self.assertEqual(manifest["mbr"]["partition_lba"], 2048)
        self.assertEqual(manifest["raw_regions"]["stage2_lba"], 1)
        self.assertEqual(manifest["raw_regions"]["kernel_lba"], 17)
        self.assertLess(
            manifest["raw_regions"]["kernel_end_lba"],
            manifest["fat16"]["lba"],
        )
        self.assertEqual(manifest["fat16"]["lba"], 2048)
        self.assertEqual(manifest["fat16"]["end_lba"], 131072)
        self.assertEqual(manifest["fat16"]["fat_lba"], 2049)
        self.assertEqual(manifest["fat16"]["root_lba"], 2561)
        self.assertEqual(manifest["fat16"]["data_lba"], 2593)
        self.assertEqual(manifest["fat16"]["bytes_per_sector"], 512)
        self.assertEqual(manifest["fat16"]["total_sectors"], 129024)
        self.assertEqual(manifest["fat16"]["media_descriptor"], "0xf8")
        self.assertGreater(
            manifest["fat16"]["fat_entry_capacity"],
            manifest["fat16"]["last_data_cluster"],
        )
        self.assertLess(
            manifest["fat16"]["data_sectors"] - manifest["fat16"]["usable_data_sectors"],
            manifest["fat16"]["sectors_per_cluster"],
        )
        self.assertGreater(manifest["fat16"]["free_clusters"], 4096)
        root_names = {entry["name"] for entry in manifest["root_entries"]}
        self.assertIn("DOOM1.WAD", root_names)
        self.assertIn("USERPROB.ELF", root_names)
        self.assertIn("DOOM.ELF", root_names)
        self.assertIn("DEFAULT.CFG", root_names)
        self.assertIn("DOOMSAV0.DSG", root_names)
        self.assertIn("DEFAULT.CFG", manifest["required_writable_root_entries"])
        self.assertIn("DOOMSAV5.DSG", manifest["required_writable_root_entries"])
        self.assertEqual(
            manifest["claim_boundary"],
            "generated-image-layout-only; not arbitrary-disk-install-proof",
        )

    def test_manifest_cli_outputs_json(self):
        result = subprocess.run(
            [
                sys.executable,
                str(TOOL),
                "--repo-contract",
                "--image",
                str(BUILD / "disk.img"),
                "--json",
            ],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
        )
        manifest = json.loads(result.stdout)
        self.assertEqual(manifest["schema"], "vibe-os-install-image-manifest-v1")
        self.assertEqual(manifest["fat16"]["lba"], 2048)

    def test_manifest_rejects_wrong_partition_type(self):
        with tempfile.TemporaryDirectory() as tmp:
            bad = Path(tmp) / "bad.img"
            image = bytearray((BUILD / "disk.img").read_bytes())
            image[446 + 4] = 0x83
            bad.write_bytes(image)
            with self.assertRaisesRegex(
                check_storage_install_boundary.StorageBoundaryError,
                "partition type",
            ):
                check_storage_install_boundary.inspect_image(bad)

    def test_manifest_rejects_missing_writable_placeholder(self):
        with tempfile.TemporaryDirectory() as tmp:
            bad = Path(tmp) / "bad.img"
            image = bytearray((BUILD / "disk.img").read_bytes())
            root = (2048 + 1 + 2 * 256) * 512
            found = False
            for offset in range(root, root + 512 * 32, 32):
                if image[offset:offset + 11] == b"DEFAULT CFG":
                    image[offset:offset + 11] = b"MISSING CFG"
                    found = True
                    break
            self.assertTrue(found)
            bad.write_bytes(image)
            with self.assertRaisesRegex(
                check_storage_install_boundary.StorageBoundaryError,
                "missing writable root placeholder DEFAULT.CFG",
            ):
                check_storage_install_boundary.inspect_image(bad)

    def test_manifest_rejects_extra_mbr_partition_entry(self):
        with tempfile.TemporaryDirectory() as tmp:
            bad = Path(tmp) / "bad.img"
            image = bytearray((BUILD / "disk.img").read_bytes())
            image[446 + 16 + 4] = 0x06
            bad.write_bytes(image)
            with self.assertRaisesRegex(
                check_storage_install_boundary.StorageBoundaryError,
                "unused MBR partition entry",
            ):
                check_storage_install_boundary.inspect_image(bad)

    def test_manifest_rejects_fat_hidden_sector_mismatch(self):
        with tempfile.TemporaryDirectory() as tmp:
            bad = Path(tmp) / "bad.img"
            image = bytearray((BUILD / "disk.img").read_bytes())
            boot = 2048 * 512
            image[boot + 28:boot + 32] = (2047).to_bytes(4, "little")
            bad.write_bytes(image)
            with self.assertRaisesRegex(
                check_storage_install_boundary.StorageBoundaryError,
                "hidden-sector",
            ):
                check_storage_install_boundary.inspect_image(bad)

    def test_manifest_rejects_fat_total_sector_mismatch(self):
        with tempfile.TemporaryDirectory() as tmp:
            bad = Path(tmp) / "bad.img"
            image = bytearray((BUILD / "disk.img").read_bytes())
            boot = 2048 * 512
            image[boot + 32:boot + 36] = (129023).to_bytes(4, "little")
            bad.write_bytes(image)
            with self.assertRaisesRegex(
                check_storage_install_boundary.StorageBoundaryError,
                "total-sector",
            ):
                check_storage_install_boundary.inspect_image(bad)

    def test_manifest_rejects_bad_fat_reserved_entries(self):
        with tempfile.TemporaryDirectory() as tmp:
            bad = Path(tmp) / "bad.img"
            image = bytearray((BUILD / "disk.img").read_bytes())
            first_fat = (2048 + 1) * 512
            image[first_fat:first_fat + 2] = (0).to_bytes(2, "little")
            bad.write_bytes(image)
            with self.assertRaisesRegex(
                check_storage_install_boundary.StorageBoundaryError,
                "reserved entries",
            ):
                check_storage_install_boundary.inspect_image(bad)


if __name__ == "__main__":
    unittest.main()
