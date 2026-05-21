import hashlib
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
        self.assertEqual(rows["BLANK_IMAGE_HOST_INSTALL"]["status"], "proven")
        self.assertEqual(rows["BLANK_IMAGE_HOST_INSTALL"]["gate"], "blank-disk-installer-manifest")
        self.assertEqual(rows["DAMAGED_IMAGE_REFUSAL"]["status"], "proven")
        self.assertEqual(rows["DAMAGED_IMAGE_REFUSAL"]["gate"], "damaged-image-refusal-report")
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
                "tests/strategy.txt",
                "docs/architecture.md",
                "docs/proof.md",
                "tools/check_storage_install_boundary.py",
            ):
                src = ROOT / relative
                dst = root / relative
                dst.parent.mkdir(parents=True, exist_ok=True)
                dst.write_text(src.read_text())

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
        persistence_doc = (ROOT / "docs" / "architecture.md").read_text()
        gap_doc = (ROOT / "docs" / "proof.md").read_text()
        tests_readme = (ROOT / "tests" / "strategy.txt").read_text()

        for text, phrase in (
            (readme, "not an installable OS for arbitrary disks"),
            (readme, "docs/architecture.md"),
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
        self.assertEqual(
            manifest["fat16"]["free_clusters"] + manifest["fat16"]["used_clusters"],
            manifest["fat16"]["data_clusters"],
        )
        self.assertEqual(
            manifest["fat16"]["accounted_clusters"],
            manifest["fat16"]["data_clusters"],
        )
        self.assertEqual(
            manifest["fat16"]["minimum_os_created_file_clusters"],
            check_storage_install_boundary.load_make_wad_image().MIN_OS_CREATED_FILE_CLUSTERS,
        )
        integrity = manifest["artifact_integrity"]
        self.assertEqual(integrity["schema"], "vibe-os-image-artifact-integrity-v1")
        self.assertTrue(integrity["all_match"])
        self.assertTrue(integrity["stage1_mbr"]["matches_patched_artifact"])
        self.assertEqual(integrity["stage1_mbr"]["lba"], 0)
        self.assertEqual(
            {region["label"] for region in integrity["raw_regions"]},
            {"stage2", "kernel"},
        )
        for digest_name in ("image_sha256",):
            self.assertEqual(len(integrity[digest_name]), 64)
        for region in integrity["raw_regions"]:
            with self.subTest(region=region["label"]):
                self.assertTrue(region["matches_installed_region"])
                self.assertGreater(region["padded_zero_bytes"], 0)
                self.assertEqual(len(region["sha256"]), 64)
        construction = manifest["bootable_image_construction"]
        self.assertEqual(construction["schema"], "vibe-os-bootable-image-construction-v1")
        self.assertEqual(
            construction["output_kind"],
            "fixed-size raw BIOS MBR disk image with FAT16 partition",
        )
        self.assertFalse(construction["qemu_executed_by_checker"])
        self.assertEqual(construction["image_size"], manifest["image_size"])
        self.assertEqual(
            {entry["component"] for entry in construction["boot_flow"]},
            {"stage1-mbr", "stage2", "kernel", "fat16-payload"},
        )
        self.assertEqual(
            {entry["name"] for entry in construction["declared_write_ranges"]},
            {"mbr-stage1-partition-table", "stage2", "kernel", "fat16-partition"},
        )
        self.assertIn("arbitrary existing disks", construction["unsupported_targets"])
        self.assertEqual(
            construction["claim_boundary"],
            "fixed-raw-bootable-image-construction-only; not arbitrary-device-installer",
        )
        self.assertEqual(
            manifest["fat16"]["packaged_asset_count"],
            len(check_storage_install_boundary.load_make_wad_image().PACKAGED_ASSET_FILES),
        )
        self.assertGreaterEqual(
            manifest["fat16"]["filesystem_file_count"],
            manifest["fat16"]["packaged_asset_count"],
        )
        root_names = {entry["name"] for entry in manifest["root_entries"]}
        self.assertIn("DOOM1.WAD", root_names)
        self.assertIn("USERPROB.ELF", root_names)
        self.assertIn("DOOM.ELF", root_names)
        self.assertIn("DEFAULT.CFG", root_names)
        self.assertIn("DOOMSAV0.DSG", root_names)
        self.assertIn("DEFAULT.CFG", manifest["required_writable_root_entries"])
        self.assertIn("DOOMSAV5.DSG", manifest["required_writable_root_entries"])
        packaged_paths = {entry["path"] for entry in manifest["packaged_assets"]}
        self.assertEqual(
            packaged_paths,
            {
                "/ASSETS/README.TXT",
                "/ASSETS/MAPS/E1M1.MAP",
                "/ASSETS/TEXTURES/PAL0.BIN",
            },
        )
        for entry in manifest["packaged_assets"]:
            with self.subTest(path=entry["path"]):
                self.assertGreater(entry["cluster"], 1)
                self.assertGreater(entry["size"], 0)
                self.assertGreater(entry["clusters"], 0)
                self.assertEqual(len(entry["sha256"]), 64)
        filesystem_paths = {entry["path"] for entry in manifest["filesystem_entries"]}
        self.assertIn("/ASSETS", filesystem_paths)
        self.assertIn("/ASSETS/MAPS/E1M1.MAP", filesystem_paths)
        self.assertEqual(manifest["fat16"]["filesystem_max_depth"], 3)
        self.assertEqual(manifest["fat16"]["kernel_syscall_max_file_depth"], 2)
        fat_vfs = manifest["fat_vfs_boundary"]
        self.assertEqual(fat_vfs["schema"], "vibe-os-fat-vfs-boundary-v1")
        self.assertTrue(fat_vfs["host_checked"])
        self.assertEqual(
            fat_vfs["kernel_syscall_surface"]["supported_path_contract"],
            "root 8.3 plus read-only one-level subdirectory",
        )
        self.assertEqual(
            fat_vfs["kernel_syscall_surface"]["root_normalization"]["normalized_path"],
            "/README.TXT",
        )
        self.assertTrue(
            fat_vfs["kernel_syscall_surface"]["root_normalization"]["all_samples_match"]
        )
        self.assertEqual(
            fat_vfs["kernel_syscall_surface"]["one_level_subdirectory_normalization"]["normalized_path"],
            "/ASSETS/README.TXT",
        )
        self.assertFalse(fat_vfs["kernel_syscall_surface"]["nested_traversal_supported"])
        self.assertFalse(fat_vfs["kernel_syscall_surface"]["writable_subdirectories_supported"])
        self.assertFalse(fat_vfs["kernel_syscall_surface"]["long_filenames_supported"])
        self.assertEqual(
            {
                entry["operation"]
                for entry in fat_vfs["read_only_one_level_subdirectory"]["mutation_refusals"]
            },
            {"write", "create", "truncate", "unlink"},
        )
        self.assertEqual(
            fat_vfs["read_only_one_level_subdirectory"]["path"],
            "/ASSETS/README.TXT",
        )
        self.assertEqual(
            {
                entry["path"]
                for entry in fat_vfs["host_image_inventory"]["nested_packaged_entries"]
            },
            {"/ASSETS/MAPS/E1M1.MAP", "/ASSETS/TEXTURES/PAL0.BIN"},
        )
        self.assertTrue(
            all(
                entry["kernel_syscall_claim"] == "unsupported-nested-traversal"
                for entry in fat_vfs["host_image_inventory"]["nested_packaged_entries"]
            )
        )
        self.assertEqual(
            manifest["claim_boundary"],
            "generated-image-layout-only; not arbitrary-disk-install-proof",
        )

    def test_manifest_includes_cli_packaged_extra_asset_tree_and_accounting(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            asset = tmp_path / "level1.map"
            payload = b"title=manifest proof\nspawn=east\n"
            asset.write_bytes(payload)
            image = tmp_path / "disk.img"

            subprocess.run(
                [
                    sys.executable,
                    str(check_storage_install_boundary.MAKE_WAD_IMAGE),
                    "--root-elf",
                    f"ABIPROBE.ELF={BUILD / 'abi_probe.elf'}",
                    "--asset",
                    f"/game/data/level1.map={asset}",
                    str(image),
                    str(BUILD / "stage1.bin"),
                    str(BUILD / "stage2.bin"),
                    str(BUILD / "kernel.elf"),
                    str(BUILD / "user_probe.elf"),
                    str(BUILD / "doom.elf"),
                ],
                cwd=ROOT,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=True,
            )

            manifest = check_storage_install_boundary.inspect_image(image)

        entries = {entry["path"]: entry for entry in manifest["filesystem_entries"]}
        self.assertTrue(entries["/GAME"]["directory"])
        self.assertTrue(entries["/GAME/DATA"]["directory"])
        self.assertFalse(entries["/GAME/DATA/LEVEL1.MAP"]["directory"])
        self.assertEqual(entries["/GAME/DATA/LEVEL1.MAP"]["size"], len(payload))
        self.assertEqual(entries["/GAME/DATA/LEVEL1.MAP"]["clusters"], 1)
        self.assertEqual(
            entries["/GAME/DATA/LEVEL1.MAP"]["sha256"],
            hashlib.sha256(payload).hexdigest(),
        )
        self.assertEqual(
            manifest["fat16"]["free_clusters"] + manifest["fat16"]["used_clusters"],
            manifest["fat16"]["data_clusters"],
        )
        self.assertGreaterEqual(
            manifest["fat16"]["filesystem_file_clusters"],
            entries["/GAME/DATA/LEVEL1.MAP"]["clusters"],
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

    def test_blank_install_proof_starts_from_zeroed_media_and_installs_boot_layout(self):
        proof = check_storage_install_boundary.prove_blank_disk_install(ROOT)

        self.assertEqual(proof["schema"], "vibe-os-blank-disk-installer-manifest-v1")
        self.assertTrue(proof["source"]["all_zero_before_install"])
        self.assertIn("zero-filled blank disk", proof["source"]["nonblank_target_refusal"])
        self.assertTrue(proof["write_audit"]["writes_only_declared_ranges"])
        self.assertEqual(proof["write_audit"]["outside_declared_ranges"], [])
        self.assertEqual(
            proof["claim_boundary"],
            "blank-image-host-install-only; not arbitrary-disk-install-proof",
        )
        construction = proof["bootable_image_construction"]
        self.assertEqual(construction["schema"], "vibe-os-bootable-image-construction-v1")
        self.assertFalse(construction["qemu_executed_by_checker"])
        self.assertEqual(
            {entry["role"] for entry in construction["source_artifact_roles"]},
            {
                "stage1",
                "stage2",
                "kernel",
                "user-probe-elf",
                "doom-elf",
                "extra-root-elf",
            },
        )
        self.assertIn("damaged-media repair", construction["unsupported_targets"])

        structural = proof["structural_boot_proof"]
        self.assertFalse(structural["qemu_executed"])
        self.assertTrue(structural["stage1_mbr_matches_patched_artifact"])
        self.assertTrue(structural["stage2_matches_artifact"])
        self.assertTrue(structural["kernel_matches_artifact"])
        self.assertEqual(structural["stage2_lba"], 1)
        self.assertEqual(structural["kernel_lba"], 17)
        self.assertEqual(structural["fat16_lba"], 2048)

        manifest = proof["installed_image_manifest"]
        self.assertEqual(manifest["schema"], "vibe-os-install-image-manifest-v1")
        root_names = {entry["name"] for entry in manifest["root_entries"]}
        self.assertIn("DOOM1.WAD", root_names)
        self.assertIn("USERPROB.ELF", root_names)
        self.assertIn("DOOM.ELF", root_names)
        self.assertIn("ABIPROBE.ELF", root_names)

    def test_blank_install_proof_cli_outputs_json(self):
        result = subprocess.run(
            [
                sys.executable,
                str(TOOL),
                "--blank-install-proof",
                "--json",
            ],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
        )
        payload = json.loads(result.stdout)
        proof = payload["blank_install_proof"]
        self.assertEqual(proof["schema"], "vibe-os-blank-disk-installer-manifest-v1")
        self.assertFalse(proof["structural_boot_proof"]["qemu_executed"])

    def test_blank_image_materialization_writes_new_file_and_refuses_overwrite(self):
        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / "vibe-os.img"
            manifest = check_storage_install_boundary.materialize_blank_install_image(output, ROOT)
            make_wad_image = check_storage_install_boundary.load_make_wad_image()

            self.assertEqual(
                manifest["schema"],
                "vibe-os-blank-image-file-materialization-v1",
            )
            self.assertTrue(output.is_file())
            self.assertEqual(output.stat().st_size, manifest["bytes_written"])
            self.assertEqual(
                manifest["bytes_written"],
                make_wad_image.IMAGE_SECTORS * make_wad_image.SECTOR_SIZE,
            )
            self.assertEqual(
                hashlib.sha256(output.read_bytes()).hexdigest(),
                manifest["sha256"],
            )
            self.assertTrue(manifest["write_safety"]["output_must_not_exist"])
            self.assertTrue(manifest["write_safety"]["existing_path_refused"])
            self.assertFalse(manifest["write_safety"]["block_device_write_supported"])
            self.assertFalse(manifest["write_safety"]["arbitrary_device_install_supported"])
            self.assertEqual(
                manifest["claim_boundary"],
                "new-regular-image-file-only; not arbitrary-device-installer",
            )
            root_names = {
                entry["name"]
                for entry in manifest["installed_image_manifest"]["root_entries"]
            }
            self.assertIn("DOOM.ELF", root_names)
            self.assertIn("ABIPROBE.ELF", root_names)

            with self.assertRaisesRegex(
                check_storage_install_boundary.StorageBoundaryError,
                "refusing to overwrite existing output path",
            ):
                check_storage_install_boundary.materialize_blank_install_image(output, ROOT)

    def test_blank_image_materialization_cli_outputs_json(self):
        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / "vibe-os.img"
            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOL),
                    "--write-blank-image",
                    str(output),
                    "--json",
                ],
                cwd=ROOT,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=True,
            )
            payload = json.loads(result.stdout)

        manifest = payload["blank_image_file"]
        self.assertEqual(
            manifest["schema"],
            "vibe-os-blank-image-file-materialization-v1",
        )
        self.assertEqual(manifest["bytes_written"], 67108864)
        self.assertIn("not arbitrary-device-installer", manifest["claim_boundary"])

    def test_blank_image_materialization_cli_refuses_existing_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / "existing.img"
            output.write_bytes(b"do not overwrite me")
            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOL),
                    "--write-blank-image",
                    str(output),
                ],
                cwd=ROOT,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("refusing to overwrite existing output path", result.stderr)

    def test_recovery_candidate_reports_known_good_image_as_inspect_only(self):
        report = check_storage_install_boundary.inspect_recovery_candidate(BUILD / "disk.img")

        self.assertEqual(report["schema"], "vibe-os-damaged-image-refusal-report-v1")
        self.assertEqual(report["decision"], "inspect-only")
        self.assertFalse(report["repair_attempted"])
        self.assertEqual(
            report["claim_boundary"],
            "known-layout-inspection-only; not arbitrary-disk-recovery-proof",
        )

    def test_damaged_recovery_fixtures_refuse_without_repairing(self):
        suite = check_storage_install_boundary.damaged_recovery_fixture_reports(BUILD / "disk.img")

        self.assertEqual(suite["schema"], "vibe-os-damaged-image-refusal-suite-v1")
        self.assertTrue(suite["all_refused"])
        self.assertFalse(suite["repair_attempted"])
        self.assertEqual(
            {report["decision"] for report in suite["fixtures"]},
            {"refuse"},
        )
        self.assertEqual(
            {report["candidate"] for report in suite["fixtures"]},
            {
                "fixture:missing-mbr-signature",
                "fixture:extra-mbr-partition-entry",
                "fixture:fat-copy-divergence",
                "fixture:missing-protected-wad-entry",
                "fixture:crosslinked-root-entry",
                "fixture:stage2-artifact-mismatch",
                "fixture:kernel-artifact-mismatch",
            },
        )
        for report in suite["fixtures"]:
            with self.subTest(report=report["candidate"]):
                self.assertFalse(report["repair_attempted"])
                self.assertFalse(report["repair_supported"])
                self.assertIn("not arbitrary-disk-recovery-proof", report["claim_boundary"])

    def test_recovery_fixtures_cli_outputs_json(self):
        result = subprocess.run(
            [
                sys.executable,
                str(TOOL),
                "--recovery-fixtures",
                str(BUILD / "disk.img"),
                "--json",
            ],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
        )
        payload = json.loads(result.stdout)
        suite = payload["recovery_fixtures"]
        self.assertTrue(suite["all_refused"])
        self.assertEqual(len(suite["fixtures"]), 7)

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

    def test_manifest_rejects_raw_artifact_mismatches(self):
        make_wad_image = check_storage_install_boundary.load_make_wad_image()
        for label, offset, message in (
            ("stage1", 0, "MBR/stage1 installed bytes"),
            (
                "stage2",
                check_storage_install_boundary.sector_offset(make_wad_image.STAGE2_LBA),
                "stage2 installed bytes",
            ),
            (
                "kernel",
                check_storage_install_boundary.sector_offset(make_wad_image.KERNEL_LBA),
                "kernel installed bytes",
            ),
        ):
            with self.subTest(label=label):
                with tempfile.TemporaryDirectory() as tmp:
                    bad = Path(tmp) / "bad.img"
                    image = bytearray((BUILD / "disk.img").read_bytes())
                    image[offset] ^= 0x01
                    bad.write_bytes(image)
                    with self.assertRaisesRegex(
                        check_storage_install_boundary.StorageBoundaryError,
                        message,
                    ):
                        check_storage_install_boundary.inspect_image(bad)


if __name__ == "__main__":
    unittest.main()
