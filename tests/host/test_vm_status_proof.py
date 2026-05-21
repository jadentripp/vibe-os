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
        "kreloc": "LOW",
        "kerneip": "00010200",
        "kernesp": "0006FFFC",
        "kerncr3": "00090000",
        "kernvirt": "00010000",
        "kernphys": "00010000",
        "kmap": "OK",
        "kmapva": "C0010000",
        "kmappa": "00010000",
        "kmappt": "00125000",
        "kmapfree": "00125000",
        "kmaplo": "10B866FA",
        "kmaphi": "10B866FA",
        "khiexec": "OK",
        "khieip": "C0012405",
        "khiesp": "C006FFD8",
        "khicr3": "00090000",
        "khiva": "C0012000",
        "khipa": "00012000",
        "khistk": "C006F000",
        "khistkpa": "0006F000",
        "khipt": "00126000",
        "khifree": "00126000",
        "kpmap": "OK",
        "kpva": "C0010000",
        "kppa": "00010000",
        "kppages": "00000020",
        "kppt": "00127000",
        "kpcr3": "00090000",
        "kpdirs": "0000003F",
        "kpxlat": "00010000",
        "kplast": "0002F000",
        "kplo": "10B866FA",
        "kphi": "10B866FA",
        "kpsva": "C0060000",
        "kpspa": "00060000",
        "kpspages": "00000010",
        "kpsxlat": "00060000",
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
        "abiflags": "0000003F",
        "doom": "OK",
        "execsys": "00000002/00000002/00000000/00000002/00000002/00000000",
        "execerr": "00000000",
        "execres": "00000000",
        "target": "00000007",
        "ppid": "00000005",
        "upid": "00000004",
        "uentry": "00E80000",
        "uflags": "0007FFFF",
        "entry": "01000000",
        "stack": "01FFFFE0",
        "argc": "00000001",
        "argv": "01FFFFE4",
        "envp": "01FFFFEC",
        "argv0": "01FFFFF0",
        "envp0": "00000000",
        "argvsrc": "00000002",
        "procpool": "00000006/00000002/00000004/00000002/00000000",
        "pidseq": "00000008/00000007/00000003",
        "fdexec": "00000002/00000002/00000001/00000001",
        "fdup": "00000001/00000002/00000002/00000003/00000001",
        "wait": "00000005/00000002/00000002/00000001/00000001/00000006/0000002A",
        "waitseed": "00000003",
        "fork": "00000001/00000000/00000005/00000006/00000006/00000000/00000020/00000003/00000020/00000001",
        "vmreap": "00000004/00000060/00000002/00000040/00000020",
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
        "pfrom": "00000007",
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


def relocated_status_line(**overrides):
    fields = {
        "kreloc": "OK",
        "kerneip": "C0010200",
        "kernesp": "C006FFFC",
        "kerncr3": "00101000",
        "kernvirt": "C0010000",
        "kernphys": "00010000",
        "kmapva": "C0010000",
        "kmappa": "00010000",
        "khicr3": "00101000",
        "kpcr3": "00101000",
    }
    fields.update(overrides)
    return status_line(**fields)


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
                pto="00000007",
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

    def test_rejects_overclaimed_or_incoherent_kernel_relocation_scaffold(self):
        for overrides, message in (
            ({"kreloc": "WAIT"}, "must be LOW or OK"),
            ({"kerneip": "00008000"}, "kerneip"),
            ({"kernesp": "00070000"}, "kernesp"),
            ({"kerncr3": "00082000"}, "kerncr3"),
            ({"kernvirt": "00011000"}, "low linked kernel entry"),
            ({"kernphys": "00110000"}, "match kernvirt"),
            ({"kerneip": "C0001000"}, "kerneip"),
        ):
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_vm_status_proof.validate_status(status_line(**overrides))

    def test_accepts_explicit_future_relocated_kernel_contract_shape(self):
        check_vm_status_proof.validate_status(relocated_status_line())

    def test_rejects_fake_relocated_kernel_contract(self):
        for overrides, message in (
            ({"kerneip": "00010200"}, "kerneip"),
            ({"kernesp": "0006FFFC"}, "kernesp"),
            ({"kerncr3": "00090000"}, "PMM-managed"),
            ({"kerncr3": "00101001"}, "page-aligned"),
            ({"kernvirt": "C0011000"}, "higher-half kernel entry"),
            ({"kernphys": "C0010000"}, "physical frame"),
            ({"kernphys": "C0010000", "kmappa": "C0010000"}, "physical frame"),
            ({"khicr3": "00090000"}, "match kerncr3"),
        ):
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_vm_status_proof.validate_status(
                        relocated_status_line(**overrides)
                    )

    def test_rejects_missing_or_fake_kernel_high_alias_scaffold(self):
        for overrides, message in (
            ({"kmap": "FAIL"}, "kmap"),
            ({"kmapva": "C0000000"}, "higher-half alias of the kernel entry"),
            ({"kmapva": "00010000"}, "higher-half alias of the kernel entry"),
            ({"kmappa": "00110000"}, "kernel entry physical page"),
            ({"kmappa": "C0010000"}, "physical frame"),
            ({"kmappt": "00025000"}, "PMM-managed"),
            ({"kmappt": "00010000"}, "PMM-managed"),
            ({"kmapfree": "00126000"}, "match kmappt"),
            ({"kmaplo": "00000000", "kmaphi": "00000000"}, "nonzero bytes"),
            ({"kmaphi": "B16B00B5"}, "match kmaplo"),
        ):
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_vm_status_proof.validate_status(status_line(**overrides))

    def test_rejects_fake_kernel_high_exec_trampoline_proof(self):
        for overrides, message in (
            ({"khiexec": "FAIL"}, "khiexec"),
            ({"khieip": "00012405"}, "khieip"),
            ({"khieip": "C0031000", "khiva": "C0031000", "khipa": "00031000"}, "khieip"),
            ({"khiesp": "0006FFD8"}, "khiesp"),
            ({"khicr3": "00101000"}, "low bootstrap page directory"),
            ({"khiva": "C0013000"}, "page containing the high trampoline EIP"),
            ({"khipa": "00013000"}, "higher-half alias of khipa"),
            ({"khipa": "00009000"}, "low physical kernel text page"),
            ({"khistk": "C006E000"}, "page containing the high trampoline ESP"),
            ({"khistkpa": "0006E000"}, "higher-half alias of khistkpa"),
            ({"khistkpa": "00070000", "khistk": "C0070000", "khiesp": "C0070FD8"}, "khiesp"),
            ({"khipt": "00026000"}, "PMM-managed"),
            ({"khipt": "00012000"}, "PMM-managed"),
            ({"khifree": "00127000"}, "match khipt"),
        ):
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_vm_status_proof.validate_status(status_line(**overrides))

    def test_rejects_fake_persistent_kernel_high_alias_proof(self):
        for overrides, message in (
            ({"kpmap": "FAIL"}, "kpmap"),
            ({"kpva": "C0011000"}, "persistent higher-half kernel text base"),
            ({"kpva": "00010000"}, "persistent higher-half kernel text base"),
            ({"kppa": "00011000"}, "kernel text physical base"),
            ({"kppa": "C0010000"}, "physical frame"),
            ({"kppages": "00000017"}, "kernel ELF window"),
            ({"kppt": "00027000"}, "PMM-managed"),
            ({"kppt": "00010000"}, "PMM-managed"),
            ({"kpcr3": "00082000"}, "active kernel relocation CR3"),
            ({"kpdirs": "0000001F"}, "every fixed process page directory"),
            ({"kpdirs": "FFFFFFFF"}, "every fixed process page directory"),
            ({"kpxlat": "00011000"}, "translate kpva"),
            ({"kplast": "00026000"}, "last persistent kernel alias page"),
            ({"kplo": "00000000", "kphi": "00000000"}, "nonzero bytes"),
            ({"kphi": "B16B00B5"}, "match kplo"),
            ({"kpsva": "C0061000"}, "higher-half alias of kpspa"),
            ({"kpspa": "00061000"}, "low kernel stack base"),
            ({"kpspages": "0000000F"}, "whole low kernel stack window"),
            ({"kpsxlat": "00061000"}, "translate kpsva"),
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
            ({"pidseq": "00000007/00000007/00000003"}, "advanced past the target"),
            ({"pidseq": "00000008/00000003/00000003"}, "exec target PID"),
            ({"pidseq": "00000008/00000007/00000000"}, "generation advanced"),
            ({"fdexec": "00000000/00000002/00000000/00000000"}, "fd ownership handoff"),
            ({"fdexec": "00000001/00000000/00000000/00000000"}, "fd inherited"),
            ({"fdexec": "00000001/00000001/00000000/00000000"}, "close-on-exec duplicated fd"),
            ({"fdup": "00000000/00000001/00000001/00000003/00000001"}, "dup, dup2, and dup3"),
            ({"fdup": "00000001/00000000/00000001/00000003/00000001"}, "dup, dup2, and dup3"),
            ({"fdup": "00000001/00000001/00000000/00000003/00000001"}, "dup, dup2, and dup3"),
            ({"fdup": "00000001/00000001/00000001/00000002/00000001"}, "shared open-file descriptions"),
            ({"fdup": "00000001/00000001/00000001/00000003/00000000"}, "O_CLOEXEC descriptor"),
            ({"wait": "00000005/00000002/00000002/00000001/00000000/00000006/0000002A"}, "child was seeded"),
            ({"wait": "00000005/00000000/00000002/00000001/00000001/00000006/0000002A"}, "waitpid reaped"),
            ({"wait": "00000005/00000002/00000000/00000001/00000001/00000006/0000002A"}, "failure paths"),
            ({"wait": "00000005/00000002/00000002/00000001/00000001/FFFFFFFF/0000002A"}, "real reaped child PID"),
            ({"wait": "00000005/00000002/00000002/00000001/00000001/00000006/00000000"}, "exit status"),
            ({"waitseed": "FFFFFFFF"}, "seeded preempt-probe child PID"),
            ({"fork": "00000000/00000000/00000005/00000006/00000006/00000000/00000020/00000003/00000020/00000001"}, "SYS_FORK succeeded"),
            ({"fork": "00000001/00000001/00000005/00000006/00000006/00000000/00000020/00000003/00000020/00000001"}, "did not hit an error path"),
            ({"fork": "00000001/00000000/00000004/00000006/00000006/00000000/00000020/00000003/00000020/00000001"}, "parent PID"),
            ({"fork": "00000001/00000000/00000005/00000005/00000006/00000000/00000020/00000003/00000020/00000001"}, "distinct child PID"),
            ({"fork": "00000001/00000000/00000005/00000006/00000005/00000000/00000020/00000003/00000020/00000001"}, "parent returned the child PID"),
            ({"fork": "00000001/00000000/00000005/00000006/00000006/00000001/00000020/00000003/00000020/00000001"}, "child returned zero"),
            ({"fork": "00000001/00000000/00000005/00000006/00000006/00000000/00000000/00000003/00000020/00000001"}, "address-space page copying"),
            ({"fork": "00000001/00000000/00000005/00000006/00000006/00000000/00000020/00000000/00000020/00000001"}, "fd descriptor cloning"),
            ({"fork": "00000001/00000000/00000005/00000006/00000006/00000000/00000020/00000003/00000000/00000001"}, "PMM-backed pages were reclaimed"),
            ({"fork": "00000001/00000000/00000005/00000006/00000006/00000000/00000020/00000003/00000020/00000000"}, "wait-reapable zombie"),
            ({"vmreap": "00000000/00000060/00000002/00000040/00000020"}, "VM teardown ran"),
            ({"vmreap": "00000004/00000000/00000002/00000040/00000020"}, "user pages were cleared"),
            ({"vmreap": "00000004/00000060/00000000/00000040/00000020"}, "waitpid reaping invoked VM teardown"),
            ({"vmreap": "00000004/00000060/00000002/00000000/00000020"}, "waitpid reclaimed child user pages"),
            ({"vmreap": "00000004/00000060/00000002/00000040/00000000"}, "waitpid reclaimed child user pages"),
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
            ({"pto": "00000007"}, "switch between processes"),
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
        boot_doc = (ROOT / "docs" / "architecture.txt").read_text()
        process_doc = (ROOT / "docs" / "architecture.txt").read_text()

        self.assertEqual(fields["vmmhi"], "OK")
        self.assertEqual(fields["khiexec"], "OK")
        self.assertEqual(fields["khicr3"], "00090000")
        self.assertEqual(fields["kpmap"], "OK")
        self.assertEqual(fields["kpcr3"], "00090000")
        self.assertEqual(fields["kpdirs"], "0000003F")
        self.assertEqual(fields["kreloc"], "LOW")
        self.assertEqual(fields["kernvirt"], "00010000")
        self.assertEqual(fields["kernphys"], "00010000")
        for doc in (boot_doc, process_doc):
            self.assertIn("KERNEL_RELOCATION_GAP[current]=high-alias-only", doc)
            self.assertIn("KERNEL_RELOCATION_GAP[current]=persistent-high-alias-window", doc)
            self.assertIn("KERNEL_RELOCATION_GAP[missing]=running-kernel-non-identity", doc)
            self.assertIn("`vmmhi=OK` is not a kernel relocation claim", doc)
            self.assertIn("`khiexec=OK` is not a kernel relocation claim", doc)
            self.assertIn("`kpmap=OK` is not a kernel relocation claim", doc)
            self.assertIn("`kreloc=OK`", doc)
            self.assertIn("`kreloc=LOW`", doc)

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
        process_exec = (ROOT / "docs" / "architecture.txt").read_text()
        process_vm = (ROOT / "docs" / "architecture.txt").read_text()
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
