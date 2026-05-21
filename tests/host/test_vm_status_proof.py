import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))
try:
    import check_vm_status_proof
finally:
    sys.path.pop(0)


def status_line(**overrides):
    fields = {
        "pg": "ON",
        "pmm": "OK",
        "vmm": "OK",
        "vmmhi": "OK",
        "vmmhva": "C0000000",
        "vmmhpa": "00123000",
        "vmmhpt": "00124000",
        "vmmhfree": "00124000",
        "exec": "OK",
        "path": "DOOM.ELF",
        "uexec": "OK",
        "upath": "USERPROB.ELF",
        "abiexec": "OK",
        "abipath": "ABIPROBE.ELF",
        "abipid": "00000005",
        "abippid": "00000004",
        "abientry": "00E80000",
        "abiargc": "00000001",
        "abiargvsrc": "00000002",
        "abiprobe": "OK",
        "abiflags": "00000007",
        "doom": "OK",
        "execsys": "00000002/00000002/00000000/00000002/00000002/00000000",
        "execerr": "00000000",
        "execres": "00000000",
        "target": "00000006",
        "ppid": "00000005",
        "upid": "00000004",
        "uentry": "00E80000",
        "uflags": "0003FFFF",
        "entry": "01000000",
        "stack": "01FFFFE0",
        "argc": "00000001",
        "argv": "01FFFFE4",
        "envp": "01FFFFEC",
        "argv0": "01FFFFF0",
        "envp0": "00000000",
        "argvsrc": "00000002",
        "procpool": "00000006/00000002/00000003/00000001/00000000",
        "pidseq": "00000007/00000006/00000003",
        "fdexec": "00000002/00000002/00000001/00000001",
        "fdup": "00000001/00000002/00000002/00000003/00000001",
        "wait": "00000003/00000001/00000002/00000000/00000001/00000003/0000002A",
        "vmreap": "00000003/00000040/00000001/00000020/00000020",
        "doomrun": "RUN",
        "gameplay": "OK",
        "pself": "OK",
        "preempt": "00000001",
        "pirq": "00000001",
        "pattempt": "00000001",
        "pskip": "00000000",
        "puser": "00000004",
        "pround": "00000001",
        "pctx": "00000004",
        "pmask": "00000003",
        "pfrom": "00000006",
        "pto": "00000003",
        "pkind": "00000002:00000003",
        "peip": "01002000:00E80000",
        "pcr3": "00082000:00083000",
        "pkstk": "00073000:00072000",
        "pframe": "00000001/00E80000/0000001B/00E9FFE0/00000023",
        "pspin": "50524546",
        "ticks": "00000100",
        "dtick": "00000023",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(f"{key}={value}" for key, value in fields.items())


class VmStatusProofTests(unittest.TestCase):
    def test_valid_status_proves_vm_exec_and_timer_preemption(self):
        check_vm_status_proof.validate_status(
            status_line(),
            require_exec=True,
            require_preempt=True,
        )
        check_vm_status_proof.validate_status(
            status_line(pspin="4258E795"),
            require_exec=True,
            require_preempt=True,
        )
        check_vm_status_proof.validate_status(
            status_line(
                pfrom="00000003",
                pto="00000006",
                pkind="00000003:00000002",
                peip="00E80000:01002000",
                pcr3="00083000:00082000",
                pkstk="00072000:00073000",
                pframe="00000001/01002000/0000001B/01FFFFE0/00000023",
            ),
            require_exec=True,
            require_preempt=True,
        )

    def test_rejects_identity_or_unreclaimed_high_mapping(self):
        for overrides, message in (
            ({"vmmhva": "00000000"}, "vmmhva"),
            ({"vmmhpa": "00023000"}, "PMM-managed"),
            ({"vmmhpa": "00124000"}, "different frames"),
            ({"vmmhfree": "00125000"}, "match vmmhpt"),
        ):
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_vm_status_proof.validate_status(status_line(**overrides))

    def test_shared_status_parser_rejects_duplicate_vm_fields(self):
        with self.assertRaisesRegex(AssertionError, "duplicate pg= field"):
            check_vm_status_proof.validate_status(status_line() + " pg=OFF")

    def test_shared_status_parser_rejects_malformed_hex_tuple(self):
        with self.assertRaisesRegex(AssertionError, "execsys= must contain 6 hex fields"):
            check_vm_status_proof.validate_status(
                status_line(execsys="00000001/NOTHEX00/00000000"),
                require_exec=True,
            )

    def test_rejects_kernel_default_or_same_process_exec_evidence(self):
        for overrides, message in (
            ({"argvsrc": "00000001"}, "user argv-vector"),
            ({"uexec": "FAIL"}, "uexec"),
            ({"upath": "BOOT.ELF"}, "upath"),
            ({"abiexec": "FAIL"}, "abiexec"),
            ({"abipath": "OTHER.ELF"}, "abipath"),
            ({"abiprobe": "FAIL"}, "abiprobe"),
            ({"abipid": "00000000"}, "abipid"),
            ({"abippid": "00000001"}, "abippid= must match upid"),
            ({"abientry": "01000000"}, "abientry"),
            ({"abiargc": "00000002"}, "one-argument ABI probe"),
            ({"abiargvsrc": "00000001"}, "ABIPROBE used the user argv-vector"),
            ({"abiflags": "00000000"}, "ABI probe success flags"),
            ({"upid": "00000000"}, "upid"),
            ({"uentry": "01000000"}, "uentry"),
            ({"uflags": "0001FFFF"}, "user probe dup shared-offset"),
            ({"ppid": "00000004"}, "ppid= must match abipid"),
            ({"target": "00000005"}, "new process"),
            ({"entry": "00E80000"}, "entry"),
            ({"stack": "00E9FFE0"}, "stack"),
            ({"envp0": "00000001"}, "envp0"),
            ({"procpool": "00000005/00000002/00000001/00000000/00000000"}, "bounded process records"),
            ({"procpool": "00000006/00000001/00000001/00000000/00000000"}, "generic exec slots"),
            ({"procpool": "00000006/00000002/00000000/00000000/00000000"}, "reused a target process slot"),
            ({"procpool": "00000006/00000002/00000003/00000000/00000000"}, "generic exec slot was allocated"),
            ({"procpool": "00000006/00000002/00000001/00000001/00000001"}, "did not overflow"),
            ({"pidseq": "00000006/00000006/00000003"}, "advanced past the target"),
            ({"pidseq": "00000007/00000003/00000003"}, "exec target PID"),
            ({"pidseq": "00000007/00000006/00000000"}, "generation advanced"),
            ({"fdexec": "00000000/00000002/00000000/00000000"}, "fd ownership handoff"),
            ({"fdexec": "00000001/00000000/00000000/00000000"}, "fd inherited"),
            ({"fdexec": "00000001/00000001/00000000/00000000"}, "close-on-exec duplicated fd"),
            ({"fdup": "00000000/00000001/00000001/00000003/00000001"}, "dup, dup2, and dup3"),
            ({"fdup": "00000001/00000000/00000001/00000003/00000001"}, "dup, dup2, and dup3"),
            ({"fdup": "00000001/00000001/00000000/00000003/00000001"}, "dup, dup2, and dup3"),
            ({"fdup": "00000001/00000001/00000001/00000002/00000001"}, "shared open-file descriptions"),
            ({"fdup": "00000001/00000001/00000001/00000003/00000000"}, "O_CLOEXEC descriptor"),
            ({"wait": "00000003/00000001/00000002/00000000/00000000/00000003/0000002A"}, "child was seeded"),
            ({"wait": "00000003/00000000/00000002/00000000/00000001/00000003/0000002A"}, "waitpid reaped"),
            ({"wait": "00000003/00000001/00000000/00000000/00000001/00000003/0000002A"}, "failure paths"),
            ({"wait": "00000003/00000001/00000002/00000000/00000001/FFFFFFFF/0000002A"}, "real reaped child PID"),
            ({"wait": "00000003/00000001/00000002/00000000/00000001/00000003/00000000"}, "exit status"),
            ({"vmreap": "00000000/00000040/00000001/00000020/00000020"}, "VM teardown ran"),
            ({"vmreap": "00000003/00000000/00000001/00000020/00000020"}, "user pages were cleared"),
            ({"vmreap": "00000003/00000040/00000000/00000020/00000020"}, "waitpid reaping invoked VM teardown"),
            ({"vmreap": "00000003/00000040/00000001/00000000/00000020"}, "waitpid reclaimed child user pages"),
            ({"vmreap": "00000003/00000040/00000001/00000020/00000000"}, "waitpid reclaimed child user pages"),
        ):
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_vm_status_proof.validate_status(
                        status_line(**overrides),
                        require_exec=True,
                    )

    def test_rejects_missing_or_out_of_range_exec_stack_evidence(self):
        for overrides, message in (
            ({"argc": "00000000"}, "one-argument"),
            ({"argc": "00000002"}, "one-argument"),
            ({"argv": "00000000"}, "argv="),
            ({"envp": "00000000"}, "envp="),
            ({"argv0": "00000000"}, "argv0="),
            ({"argv": "00E7FFF0"}, "argv="),
            ({"envp": "02000000"}, "envp="),
            ({"argv0": "02000000"}, "argv0="),
        ):
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_vm_status_proof.validate_status(
                        status_line(**overrides),
                        require_exec=True,
                    )

    def test_rejects_counter_only_preemption(self):
        for overrides, message in (
            ({"pself": "FAIL"}, "pself"),
            ({"pirq": "00000002"}, "pirq"),
            ({"puser": "00000000"}, "puser"),
            ({"puser": "00000000", "pframe": "00000001/00E80000/0000001B/00E9FFE0/00000023"}, "puser"),
            ({"pmask": "00000001"}, "both directions"),
            ({"pfrom": "00000002"}, "exec target PID"),
            ({"pto": "00000006"}, "switch between processes"),
            ({"pkind": "00000002:00000002"}, "Doom and the preempt probe"),
            ({"peip": "01002000:01003000"}, "recorded source and target process kinds"),
            ({"pcr3": "00082000:00082000"}, "recorded source and target process address spaces"),
            ({"pkstk": "00073000:00073000"}, "recorded source and target process kernel stacks"),
            ({"pspin": "50524545"}, "preempt probe executed"),
            ({"pframe": "00000000/00E80000/0000001B/00E9FFE0/00000023"}, "rewrite count"),
            ({"pframe": "00000001/01002000/0000001B/00E9FFE0/00000023"}, "selected target"),
            ({"pframe": "00000001/00E80000/00000008/00E9FFE0/00000023"}, "Ring 3 user code"),
            ({"pframe": "00000001/00E80000/0000001B/00000000/00000023"}, "nonzero Ring 3 stack"),
            ({"pframe": "00000001/00E80000/0000001B/00E9FFE0/00000010"}, "Ring 3 user data"),
        ):
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_vm_status_proof.validate_status(
                        status_line(**overrides),
                        require_preempt=True,
                    )

    def test_short_generated_wad_status_gets_actionable_preemption_hint(self):
        with self.assertRaisesRegex(
            AssertionError,
            (
                "generated-WAD OS smoke exited Doom before a Doom/preempt-probe "
                "timer quantum"
            ),
        ) as raised:
            check_vm_status_proof.validate_status(
                status_line(
                    doomrun="EXIT",
                    gameplay="WAIT",
                    preempt="00000000",
                    pirq="00000000",
                    pattempt="00000000",
                    pskip="00000097",
                    puser="00000003",
                    pround="00000097",
                    pmask="00000000",
                    pfrom="FFFFFFFF",
                    pto="FFFFFFFF",
                    pkind="00000000:00000000",
                    peip="00000000:00000000",
                    pcr3="00000000:00000000",
                    pkstk="00000000:00000000",
                    pframe="00000000/00000000/00000000/00000000/00000000",
                    pspin="50524545",
                    ticks="000002F6",
                    dtick="00000109",
                ),
                require_preempt=True,
            )

        message = str(raised.exception)
        self.assertIn("doomrun=EXIT", message)
        self.assertIn("gameplay=WAIT", message)
        self.assertIn("puser=00000003", message)
        self.assertIn("pskip=00000097", message)
        self.assertIn("prove preemption with a real-WAD gameplay status", message)

    def test_cli_validates_status_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "status.txt"
            path.write_text(status_line())
            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOLS / "check_vm_status_proof.py"),
                    "--require-exec",
                    "--require-preempt",
                    str(path),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("VM status proof OK", result.stdout)

    def test_repo_contract_is_machine_checked(self):
        check_vm_status_proof.validate_repo_contract(ROOT)

    def test_status_proof_does_not_overclaim_running_kernel_relocation(self):
        fields = check_vm_status_proof.parse_status(status_line())
        boot_doc = (ROOT / "docs" / "boot-loader-vm.md").read_text()
        process_doc = (ROOT / "docs" / "process-vm.md").read_text()

        self.assertEqual(fields["vmmhi"], "OK")
        self.assertNotIn("kreloc", fields)
        for doc in (boot_doc, process_doc):
            self.assertIn("KERNEL_RELOCATION_GAP[current]=high-alias-only", doc)
            self.assertIn("KERNEL_RELOCATION_GAP[missing]=running-kernel-non-identity", doc)
            self.assertIn("`vmmhi=OK` is not a kernel relocation claim", doc)
            self.assertIn("`kreloc=OK`", doc)

    def test_repo_contract_keeps_preemption_on_long_lived_real_wad_lanes(self):
        os_workflow = (ROOT / ".github" / "workflows" / "os-smoke.yml").read_text()
        real_wad_smoke = (ROOT / ".github" / "workflows" / "real-wad-smoke.yml").read_text()
        real_wad_soak = (ROOT / ".github" / "workflows" / "real-wad-soak.yml").read_text()

        self.assertIn("Assert generated-WAD VM/process exec gates", os_workflow)
        self.assertIn("--require-exec", os_workflow)
        self.assertNotIn("--require-preempt", os_workflow)
        self.assertIn("Assert VM/process legitimacy gates", real_wad_smoke)
        for workflow in (real_wad_smoke, real_wad_soak):
            self.assertIn("--require-exec", workflow)
            self.assertIn("--require-preempt", workflow)

    def test_repo_contract_keeps_generic_exec_surface_documented(self):
        process_exec = (ROOT / "docs" / "process-exec.md").read_text()
        process_vm = (ROOT / "docs" / "process-vm.md").read_text()
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()

        for source in (
            "root-level `.ELF` programs",
            "root-only FAT16 8.3 `.ELF` path",
            "`VIBE_EXEC_ARG_MAX` argv strings",
            "an empty `envp` vector",
            "descriptors limited to fd slots not opened with",
            "`vmreap=`",
        ):
            self.assertIn(source, process_exec)
        for source in (
            "target-specific stack bounds",
            "shared argv stack builder",
            "process-owned fd\nretagging for inheritable descriptors",
            "future root-level game or tool ELFs",
            "`vmreap=`",
        ):
            self.assertIn(source, process_vm)
        for source in (
            "VIBE_EXEC_PATH_MAX = 16",
            "VIBE_EXEC_ARG_MAX = 8",
            "VIBE_EXEC_ARG_STR_MAX = 64",
            "execve accepts NULL or empty envp only",
        ):
            self.assertIn(source, header)

    def test_cli_reports_repo_contract_success(self):
        result = subprocess.run(
            [sys.executable, str(TOOLS / "check_vm_status_proof.py"), "--repo-contract"],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("VM status proof contract OK", result.stdout)


if __name__ == "__main__":
    unittest.main()
