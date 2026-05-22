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
        "e820": "OK",
        "e820cnt": "00000003",
        "e820free": "00001F00",
        "e820sz": "00000018",
        "e820map": "00007100/00007148/00000001",
        "e820use": "00000001/00001F00",
        "e820res": "00000020/00000000/00000000",
        "pmmwin": "00100000/02000000",
        "pmmmap": "00099000/00001F00",
        "pmmguard": "00000100/00000600",
        "pmmuse": "000018F0/00000610/00001F00",
        "pmmtype": "000018F0/00000001/0000060F/00000001",
        "pmmchk": "OK",
        "pmmalloc": "00123000/00001900/00001900",
        "pmmdeny": "00000001/00000001/00000001/00000001/00000000",
        "uguard": "0000000F",
        "vmmguard": "0000000F/00000000",
        "pmmdma": "00120000/00121000/00000001",
        "pmmio": "00000000/00000000",
        "biosboot": "OK",
        "biosflags": "00007FB7",
        "biosentry": "00010000/00000001",
        "biosspan": "00000010/00000140/00000002",
        "vmm": "OK",
        "kreloc": "HIGH",
        "krelocstep": "KPMAIN_HIGH",
        "kerneip": "C0010200",
        "kernesp": "C006FFFC",
        "kerncr3": "00090000",
        "kernvirt": "C0010000",
        "kernphys": "00010000",
        "klowid": "00000001/00010000/00010000/00010003",
        "kreldir": "OK",
        "kreldirx": "00128000/00127003/00000000/00010000/00060000/FFFFFFFF",
        "kreldirp": "00010003/00060003/00000000",
        "krelive": "OK",
        "krelivex": "C00121B3/C006FFD0/00128000/00090000/C0012000/00012000/C006F000/0006F000/C002A5A4/0002A5A4",
        "krelivep": "00012000/0006F000/0002A5A4/FFFFFFFF/4B524C56",
        "khmain": "OK",
        "khmspan": "C0011300/C0011800/C006FFD0/C006FFCC/00090000/C0070000/C0000000/00000002",
        "khmxlat": "00011300/00011800/0006FFD0/0006FFCC",
        "khmpte": "00127003/00011003/00011003/0006F003/0006F003",
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
        "khixlat": "00012000",
        "khisxlat": "0006F000",
        "khislot": "C006FFD4",
        "khislotpa": "0006FFD4",
        "khisword": "48485354",
        "khiret": "00012618",
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
        "kpexec": "OK",
        "kpeip": "C0012405",
        "kpesp": "C006FFD8",
        "kpecr3": "00090000",
        "kpeva": "C0012000",
        "kpepa": "00012000",
        "kpestk": "C006F000",
        "kpestkpa": "0006F000",
        "kpexlat": "00012000",
        "kpesxlat": "0006F000",
        "kpeslot": "C006FFD4",
        "kpeslotpa": "0006FFD4",
        "kpesword": "4B504558",
        "kperet": "00012618",
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
        "abiflags": "000003FF",
        "doom": "OK",
        "execsys": "00000002/00000002/00000000/00000002/00000002/00000000",
        "execmap": "00000002/00000002/00000001/00000001/00000001/00000004/00000002/00000005",
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
        "pstat": "00000004/00000003/00000001/00000005/00000004/00000002/00000020",
        "yield": "00000002/00000000/00000002/00000005/FFFFFFFF",
        "kblock": "00000002/00000002/00000002/00000000/00000005/00000002/00000006/00000005/00000002",
        "ksleep": "00000001/00000001/00000001/00000000/00000000/00000005/00000021/00000001/00000005",
        "wait": "00000005/00000002/00000002/00000001/00000001/00000006/0000002A/00000001/00000001",
        "waitseed": "00000003",
        "fork": "00000001/00000000/00000005/00000006/00000006/00000000/00000020/00000003/00000020/00000001",
        "vmreap": "00000004/00000060/00000002/00000040/00000020",
        "doomrun": "RUN",
        "gameplay": "OK",
        "doomfault": "00000000",
        "doomfaultip": "00000000",
        "doomfaultv": "00000000",
        "doomfaulterr": "00000000",
        "fault": "00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000",
        "pf": "00000000/00000000/00000000/00000000/00000000",
        "faultsrc": "NONE",
        "faultmode": "NONE",
        "faultcontain": "00000001/00000000/00000000/00000000/00000000",
        "regs": "00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000",
        "segs": "00000000/00000000/00000000/00000000/00000000/00000000",
        "proc": "00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000/00000000",
        "panic": "NONE",
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
        "psegs": "00000023:00000023:00000023:00000023",
        "peflags": "00000202:00000202:00000202:00000000:00000001",
        "pspin": "50524546",
        "ticks": "00000100",
        "dtick": "00000059",
        "clocksrc": "PIT",
        "clockirq": "00000100",
        "clocktick": "00000100",
        "clockhz": "00000064",
        "clockms": "00000A00",
        "clockdoom": "00000059",
        "clocksch": "00000100",
        "clockpirq": "00000001",
    }
    fields.update(overrides)
    return "Aurora OS v0.2 " + " ".join(f"{key}={value}" for key, value in fields.items())


def relocated_status_line(**overrides):
    fields = {
        "kreloc": "OK",
        "krelocstep": "FULL",
        "kerneip": "C0010200",
        "kernesp": "C006FFFC",
        "kerncr3": "00101000",
        "kernvirt": "C0010000",
        "kernphys": "00010000",
        "klowid": "00000002/00010000/FFFFFFFF/00000000",
        "khmspan": "C0011300/C0011800/C006FFD0/C006FFCC/00101000/C0070000/C0000000/00000002",
        "kmapva": "C0010000",
        "kmappa": "00010000",
        "khicr3": "00101000",
        "khiret": "C0012618",
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

    def test_fault_observability_classifies_contained_and_kernel_faults(self):
        check_vm_status_proof.validate_status(
            status_line(
                doomrun="FAULT",
                doomfault="018F0000",
                doomfaultip="0102F190",
                doomfaultv="0000000E",
                doomfaulterr="00000004",
                fault="0000000E/00000004/0102F190/0000001B/0100FFE0/00000023/018F0000/00000007/00000002/00000002/00000003",
                pf="018F0000/00000004/00000001/00000001/00000001",
                faultsrc="DOOM",
                faultmode="USER",
                faultcontain="00000001/00000000/00000001/00000000/00000001",
                regs="00000001/00000002/00000003/00000004/00000005/00000006/00000007/00000202",
                segs="00000023/00000023/00000023/00000023/0000001B/00000023",
                proc="00001000/01000000/02000000/01900000/01900000/01F00000/02000000/01000000/00082000",
            )
        )
        check_vm_status_proof.validate_status(
            status_line(
                fault="0000000E/00000004/00E81234/0000001B/00E9FFE0/00000023/00E7F000/00000005/00000001/00000002/0000001A",
                pf="00E7F000/00000004/00000001/00000001/00000001",
                faultsrc="USER",
                faultmode="USER",
                faultcontain="00000001/00000001/00000000/00000000/00000001",
                regs="00000001/00000002/00000003/00000004/00000005/00000006/00000007/00000202",
                segs="00000023/00000023/00000023/00000023/0000001B/00000023",
                proc="00002000/00E80000/00F00000/00EA0000/00EA0000/00F00000/00EA0000/00E80000/00089000",
            )
        )
        check_vm_status_proof.validate_status(
            status_line(
                fault="0000000E/00000004/00E81234/0000001B/00E9FFE0/00000023/00E7F000/00000005/00000001/00000002/0000001A",
                pf="00E7F000/00000004/00000001/00000001/00000001",
                faultsrc="EXPECT",
                faultmode="USER",
                faultcontain="00000002/00000000/00000000/00000000/00000001",
                regs="00000001/00000002/00000003/00000004/00000005/00000006/00000007/00000202",
                segs="00000023/00000023/00000023/00000023/0000001B/00000023",
                proc="00002000/00E80000/00F00000/00EA0000/00EA0000/00F00000/00EA0000/00E80000/00089000",
            )
        )
        check_vm_status_proof.validate_status(
            status_line(
                fault="0000000D/00000000/C0012345/00000008/C006FFE0/00000010/00000000/00000000/00000000/00000000/00000024",
                faultsrc="KERNEL",
                faultmode="KERNEL",
                faultcontain="00000001/00000000/00000000/00000001/00000000",
                regs="00000001/00000002/00000003/00000004/00000005/00000006/00000007/00000202",
                segs="00000010/00000010/00000010/00000010/00000008/00000010",
                panic="KEXC",
            )
        )

    def test_rejects_fault_observability_mismatches(self):
        cases = (
            ({"faultsrc": "BAD"}, "unknown source"),
            ({"faultmode": "BAD"}, "unknown mode"),
            ({"faultsrc": "NONE", "faultmode": "USER"}, "must be NONE"),
            ({"faultsrc": "NONE", "faultcontain": "00000001/00000000/00000000/00000000/00000001"}, "last-contained"),
            ({"faultsrc": "NONE", "pf": "00001000/00000004/00000001/00000001/00000001"}, "pf= must be all zero"),
            (
                {
                    "doomrun": "FAULT",
                    "doomfault": "018F0000",
                    "doomfaultip": "0102F190",
                    "doomfaultv": "0000000E",
                    "doomfaulterr": "00000004",
                    "fault": "0000000E/00000004/0102F190/0000001B/0100FFE0/00000023/018F0000/00000007/00000002/00000002/00000003",
                    "pf": "018F0000/00000004/00000001/00000001/00000001",
                    "faultsrc": "DOOM",
                    "faultmode": "USER",
                    "faultcontain": "00000001/00000000/00000000/00000000/00000001",
                    "regs": "00000001/00000002/00000003/00000004/00000005/00000006/00000007/00000202",
                    "segs": "00000023/00000023/00000023/00000023/0000001B/00000023",
                    "proc": "00001000/01000000/02000000/01900000/01900000/01F00000/02000000/01000000/00082000",
                },
                "count Doom user faults",
            ),
            (
                {
                    "doomrun": "FAULT",
                    "doomfault": "018F0000",
                    "doomfaultip": "0102F190",
                    "doomfaultv": "0000000E",
                    "doomfaulterr": "00000004",
                    "fault": "0000000E/00000004/0102F190/0000001B/0100FFE0/00000023/018F0000/00000007/00000002/00000002/00000003",
                    "pf": "018F0000/00000004/00000002/00000001/00000001",
                    "faultsrc": "DOOM",
                    "faultmode": "USER",
                    "faultcontain": "00000001/00000000/00000001/00000000/00000001",
                    "regs": "00000001/00000002/00000003/00000004/00000005/00000006/00000007/00000202",
                    "segs": "00000023/00000023/00000023/00000023/0000001B/00000023",
                    "proc": "00001000/01000000/02000000/01900000/01900000/01F00000/02000000/01000000/00082000",
                },
                "pf= must mirror page-fault",
            ),
            (
                {
                    "fault": "0000000D/00000000/C0012345/00000008/C006FFE0/00000010/00000000/00000000/00000000/00000000/00000024",
                    "faultsrc": "KERNEL",
                    "faultmode": "KERNEL",
                    "faultcontain": "00000001/00000000/00000000/00000001/00000000",
                    "regs": "00000001/00000002/00000003/00000004/00000005/00000006/00000007/00000202",
                    "segs": "00000010/00000010/00000010/00000010/00000008/00000010",
                    "panic": "NONE",
                },
                "panic= must be KEXC",
            ),
        )
        for overrides, message in cases:
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_vm_status_proof.validate_status(status_line(**overrides))

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

    def test_rejects_fake_pmm_boot_proof(self):
        for overrides, message in (
            ({"e820": "LEGACY"}, "e820"),
            ({"e820cnt": "00000000"}, "e820cnt"),
            ({"e820sz": "00000010"}, "E820 entry size"),
            ({"e820map": "00007100/00007148/00000000"}, "validated the firmware map"),
            ({"e820map": "00007000/00007148/00000001"}, "Stage 2 E820 buffer"),
            ({"e820map": "00007100/00007130/00000001"}, "end must match"),
            ({"e820cnt": "00000021", "e820map": "00007100/00007418/00000001"}, "inside the bounded"),
            ({"e820use": "00000000/00001F00"}, "usable entry"),
            ({"e820use": "00000001/00000000"}, "usable PMM pages"),
            ({"e820free": "00001EFF"}, "match the usable page count"),
            ({"pmmwin": "00000000/02000000"}, "start"),
            ({"pmmwin": "00100000/03000000"}, "inside"),
            ({"pmmmap": "00098000/00001F00"}, "frame bitmap"),
            ({"pmmmap": "00099000/00001000"}, "bitmap ceiling"),
            ({"pmmguard": "00000000/00000600"}, "low-memory guard"),
            ({"pmmguard": "00000100/00000000"}, "reserved"),
            ({"pmmuse": "000018EF/00000610/00001F00"}, "free \\+ used"),
            ({"pmmuse": "00001F01/00000001/00001F02"}, "managed window"),
            ({"pmmtype": "000018F0/00000001/0000060F/00000000"}, "rescanned successfully"),
            ({"pmmtype": "000018EF/00000001/0000060F/00000001"}, "free count"),
            ({"pmmtype": "000018F0/00000001/0000060E/00000001"}, "used plus reserved"),
            ({"pmmtype": "000018F0/00000610/00000000/00000001"}, "reserved frame-map"),
            ({"pmmchk": "FAIL"}, "pmmchk"),
            ({"pmmalloc": "00023000/00001900/00001900"}, "PMM-managed"),
            ({"pmmalloc": "00123000/00001900/000018FF"}, "returned its allocated page"),
            ({"pmmdeny": "00000001/00000000/00000001/00000001/00000000"}, "reserved pages are not allocatable"),
            ({"uguard": "0000000E"}, "explicit code, heap, stack, and Doom guard pages"),
            ({"vmmguard": "0000000E/00000000"}, "probe every explicit user guard page"),
            ({"vmmguard": "0000000F/00000001"}, "not present in user page tables"),
            ({"pmmdma": "00120000/00120000/00000001"}, "DMA-safe"),
            ({"pmmdma": "00120000/00122000/00000001"}, "DMA window span"),
            ({"pmmio": "00000000/00000001"}, "MMIO base"),
            (
                {
                    "pmmio": "E0000000/00000002",
                    "pmmdeny": "00000001/00000001/00000001/00000001/00000000",
                },
                "framebuffer/MMIO pages are reserved",
            ),
        ):
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_vm_status_proof.validate_status(status_line(**overrides))

    def test_rejects_fake_bios_handoff_proof(self):
        for overrides, message in (
            ({"biosboot": "FAIL"}, "biosboot"),
            ({"biosflags": "00007F37"}, "A20"),
            ({"biosflags": "00007F93"}, "BIOS disk"),
            ({"biosflags": "00007F97"}, "exactly one BIOS video"),
            ({"biosflags": "00006FB7"}, "bounded E820"),
            ({"biosflags": "00003FB7"}, "ELF PHDR"),
            ({"biosflags": "00007FB5"}, "EDD-present"),
            ({"biosflags": "00007FB9"}, "CHS geometry"),
            ({"biosflags": "00007FF7"}, "exactly one BIOS video"),
            ({"biosentry": "00011000/00000001"}, "linked kernel entry"),
            ({"biosentry": "00010000/00000000"}, "loaded ELF segment"),
            ({"biosspan": "0000000F/00000140/00000002"}, "Stage 2 span"),
            ({"biosspan": "00000010/00000141/00000002"}, "kernel staging span"),
            ({"biosspan": "00000010/00000140/00000001"}, "loader status OK"),
        ):
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_vm_status_proof.validate_status(status_line(**overrides))

    def test_rejects_overclaimed_or_incoherent_kernel_relocation_scaffold(self):
        for overrides, message in (
            ({"kreloc": "WAIT"}, "must be LOW, HIGH, or OK"),
            ({"krelocstep": "LOW_ONLY"}, "krelocstep"),
            ({"kerneip": "00010200"}, "kerneip"),
            ({"kernesp": "0006FFFC"}, "kernesp"),
            ({"kerncr3": "00082000"}, "kerncr3"),
            ({"kernvirt": "00011000"}, "persistent higher-half kernel entry"),
            ({"kernphys": "00110000"}, "low physical kernel text frame"),
            ({"klowid": "00000002/00010000/FFFFFFFF/00000000"}, "retained low identity dependency"),
            ({"klowid": "00000001/00011000/00011000/00000003"}, "low linked kernel entry"),
            ({"klowid": "00000001/00010000/00011000/00000003"}, "back to itself"),
            ({"klowid": "00000001/00010000/00010000/00000002"}, "present bit"),
            ({"klowid": "00000001/00010000/00010000/00011003"}, "PTE frame"),
            ({"kerneip": "C0001000"}, "kerneip"),
            ({"khmain": "FAIL"}, "khmain"),
            ({"khmspan": "00011300/C0011800/C006FFD0/C006FFCC/00090000/C0070000/C0000000/00000002"}, "entry EIP"),
            ({"khmspan": "C0011300/C0011300/C006FFD0/C006FFCC/00090000/C0070000/C0000000/00000002"}, "two distinct"),
            ({"khmspan": "C0011300/C0011800/0006FFD0/C006FFCC/00090000/C0070000/C0000000/00000002"}, "entry ESP"),
            ({"khmspan": "C0011300/C0011800/C006FFD0/C006FFCC/00082000/C0070000/C0000000/00000002"}, "active kernel relocation CR3"),
            ({"khmspan": "C0011300/C0011800/C006FFD0/C006FFCC/00090000/00070000/C0000000/00000002"}, "TSS esp0"),
            ({"khmspan": "C0011300/C0011800/C006FFD0/C006FFCC/00090000/C0070000/00000000/00000002"}, "IDT gates"),
            ({"khmspan": "C0011300/C0011800/C006FFD0/C006FFCC/00090000/C0070000/C0000000/00000001"}, "at least two"),
            ({"khmxlat": "00011301/00011800/0006FFD0/0006FFCC"}, "entry EIP"),
            ({"khmxlat": "00011300/00011800/0006FFD0/0006FFCD"}, "late ESP"),
            ({"khmpte": "00128003/00011003/00011003/0006F003/0006F003"}, "persistent high alias page table"),
            ({"khmpte": "00127002/00011003/00011003/0006F003/0006F003"}, "PDE must be present"),
            ({"khmpte": "00127003/00012003/00011003/0006F003/0006F003"}, "entry text PTE frame"),
            ({"khmpte": "00127003/00011003/00011003/0006F001/0006F003"}, "entry stack PTE"),
            ({"kreldir": "FAIL"}, "kreldir"),
            ({"kreldirx": "00090000/00127003/00000000/00010000/00060000/FFFFFFFF"}, "dedicated PMM-managed"),
            ({"kreldirx": "00128000/00127002/00000000/00010000/00060000/FFFFFFFF"}, "high PDE"),
            ({"kreldirx": "00128000/00126003/00000000/00010000/00060000/FFFFFFFF"}, "persistent high alias page table"),
            ({"kreldirx": "00128000/00127003/00091003/00010000/00060000/FFFFFFFF"}, "low PDE"),
            ({"kreldirx": "00128000/00127003/00000000/00011000/00060000/FFFFFFFF"}, "entry translation"),
            ({"kreldirx": "00128000/00127003/00000000/00010000/0006F000/FFFFFFFF"}, "stack translation"),
            ({"kreldirx": "00128000/00127003/00000000/00010000/00060000/00010000"}, "low identity translation"),
            ({"kreldirp": "00010002/00060003/00000000"}, "entry PTE"),
            ({"kreldirp": "00011003/00060003/00000000"}, "entry PTE frame"),
            ({"kreldirp": "00010003/00060002/00000000"}, "stack PTE"),
            ({"kreldirp": "00010003/0006F003/00000000"}, "stack PTE frame"),
            ({"kreldirp": "00010003/00060003/00010003"}, "low PTE"),
            ({"krelive": "FAIL"}, "krelive"),
            ({"krelivex": "C00121B3/C006FFD0/00090000/00090000/C0012000/00012000/C006F000/0006F000/C002A5A4/0002A5A4"}, "live CR3"),
            ({"krelivex": "C00121B3/C006FFD0/00128000/00128000/C0012000/00012000/C006F000/0006F000/C002A5A4/0002A5A4"}, "return CR3"),
            ({"krelivex": "C00121B3/C006FFD0/00128000/00090000/C0013000/00012000/C006F000/0006F000/C002A5A4/0002A5A4"}, "code page"),
            ({"krelivex": "C00121B3/C006FFD0/00128000/00090000/C0012000/00012000/C006E000/0006F000/C002A5A4/0002A5A4"}, "stack page"),
            ({"krelivex": "C00121B3/C006FFD0/00128000/00090000/C0012000/00012000/C006F000/0006F000/C002B5A4/0002A5A4"}, "data slot"),
            ({"krelivex": "C00131B3/C006FFD0/00128000/00090000/C0012000/00012000/C006F000/0006F000/C002A5A4/0002A5A4"}, "EIP"),
            ({"krelivex": "C00121B3/C006EFF0/00128000/00090000/C0012000/00012000/C006F000/0006F000/C002A5A4/0002A5A4"}, "ESP"),
            ({"krelivep": "00013000/0006F000/0002A5A4/FFFFFFFF/4B524C56"}, "code translation"),
            ({"krelivep": "00012000/0006E000/0002A5A4/FFFFFFFF/4B524C56"}, "stack translation"),
            ({"krelivep": "00012000/0006F000/0002B5A4/FFFFFFFF/4B524C56"}, "high data translation"),
            ({"krelivep": "00012000/0006F000/0002A5A4/00010000/4B524C56"}, "low identity translation"),
            ({"krelivep": "00012000/0006F000/0002A5A4/FFFFFFFF/00000000"}, "magic"),
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
            ({"kerncr3": "00090000"}, "low bootstrap page directory"),
            ({"kerncr3": "00082000"}, "dedicated PMM-managed kernel page directory"),
            ({"kerncr3": "00101001"}, "page-aligned"),
            ({"kernvirt": "C0011000"}, "higher-half kernel entry"),
            ({"kernphys": "C0010000"}, "physical frame"),
            ({"kernphys": "C0010000", "kmappa": "C0010000"}, "physical frame"),
            ({"klowid": "00000001/00010000/00010000/00010003"}, "trapped/absent"),
            ({"klowid": "00000002/00010000/00010000/00000000"}, "no low identity translation"),
            ({"klowid": "00000002/00010000/FFFFFFFF/00000001"}, "present bit"),
            ({"klowid": "00000002/00011000/FFFFFFFF/00000000"}, "low linked kernel entry"),
            ({"khicr3": "00090000"}, "match kerncr3"),
            ({"krelocstep": "HIEXEC_TMP"}, "krelocstep"),
            ({"khiret": "00012618"}, "khiret"),
            ({"khmspan": "C0011300/C0011800/C006FFD0/C006FFCC/00090000/C0070000/C0000000/00000002"}, "active kernel relocation CR3"),
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
            ({"khixlat": "00013000"}, "translate khiva"),
            ({"khisxlat": "0006E000"}, "translate khistk"),
            ({"khislot": "C006EFFC"}, "high-stack slot"),
            ({"khislotpa": "0006FFD0"}, "low physical backing"),
            ({"khisword": "00000000"}, "high-stack write"),
            ({"khiret": "C0012618"}, "khiret"),
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
            (
                {"kppt": "00027000", "khmpte": "00027003/00011003/00011003/0006F003/0006F003"},
                "PMM-managed",
            ),
            (
                {"kppt": "00010000", "khmpte": "00010003/00011003/00011003/0006F003/0006F003"},
                "PMM-managed",
            ),
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

    def test_rejects_fake_persistent_kernel_high_exec_proof(self):
        for overrides, message in (
            ({"kpexec": "FAIL"}, "kpexec"),
            ({"kpeip": "00012405"}, "kpeip"),
            ({"kpeip": "C0031000", "kpeva": "C0031000", "kpepa": "00031000"}, "kpeip"),
            ({"kpesp": "0006FFD8"}, "kpesp"),
            ({"kpecr3": "00101000"}, "persistent kernel alias CR3"),
            ({"kpeva": "C0013000"}, "page containing the persistent high-exec EIP"),
            ({"kpepa": "00013000"}, "higher-half alias of kpepa"),
            ({"kpepa": "00009000"}, "low physical kernel text page"),
            ({"kpestk": "C006E000"}, "page containing the persistent high-exec ESP"),
            ({"kpestkpa": "0006E000"}, "higher-half alias of kpestkpa"),
            ({"kpestkpa": "00070000", "kpestk": "C0070000", "kpesp": "C0070FD8"}, "kpesp"),
            ({"kpexlat": "00013000"}, "translate kpeva"),
            ({"kpesxlat": "0006E000"}, "translate kpestk"),
            ({"kpeslot": "C006EFFC"}, "high-stack slot"),
            ({"kpeslotpa": "0006FFD0"}, "low physical backing"),
            ({"kpesword": "00000000"}, "persistent high-stack write"),
            ({"kperet": "C0012618"}, "kperet"),
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
        with self.assertRaisesRegex(AssertionError, "execmap= must contain 8 hex fields"):
            check_vm_status_proof.validate_status(
                status_line(execmap="00000001/NOTHEX00/00000000"),
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
            ({"execmap": "00000001/00000002/00000001/00000001/00000001/00000004/00000002/00000005"}, "table-backed exec"),
            ({"execmap": "00000002/00000000/00000001/00000001/00000001/00000004/00000002/00000005"}, "generic root .ELF path"),
            ({"execmap": "00000002/00000002/00000000/00000001/00000001/00000004/00000002/00000005"}, "generic root .ELF successfully launched"),
            ({"execmap": "00000002/00000002/00000001/00000002/00000001/00000004/00000002/00000005"}, "final Doom exec used the table resolver"),
            ({"execmap": "00000002/00000002/00000001/00000001/00000002/00000004/00000002/00000005"}, "final Doom exec used the table resolver"),
            ({"execmap": "00000002/00000002/00000001/00000001/00000001/00000001/00000002/00000005"}, "Doom was launched by a generic user process"),
            ({"execmap": "00000002/00000002/00000001/00000001/00000001/00000004/00000004/00000005"}, "Doom was launched by a generic user process"),
            ({"execmap": "00000002/00000002/00000001/00000001/00000001/00000004/00000002/00000006"}, "successful generic root .ELF launch"),
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
            ({"pstat": "00000002/00000001/00000001/00000005/00000004/00000002/00000020"}, "current and pid lookups"),
            ({"pstat": "00000004/00000003/00000000/00000005/00000004/00000002/00000020"}, "invalid pid lookups"),
            ({"pstat": "00000004/00000003/00000001/00000004/00000004/00000002/00000020"}, "ABI probe PID"),
            ({"pstat": "00000004/00000003/00000001/00000005/00000003/00000002/00000020"}, "USERPROB launcher PID"),
            ({"pstat": "00000004/00000003/00000001/00000005/00000004/00000001/00000020"}, "queried process was running"),
            ({"pstat": "00000004/00000003/00000001/00000005/00000004/00000002/00000000"}, "nonzero scheduler tick"),
            ({"yield": "00000000/00000000/00000000/00000005/FFFFFFFF"}, "SYS_YIELD was exercised"),
            ({"yield": "00000002/00000001/00000000/00000005/00000006"}, "switches plus noops"),
            ({"yield": "00000002/00000000/00000002/00000004/FFFFFFFF"}, "ABI probe PID"),
            ({"yield": "00000002/00000000/00000002/00000005/00000006"}, "target PID sentinel"),
            ({"yield": "00000002/00000001/00000001/00000005/FFFFFFFF"}, "real target PID"),
            ({"kblock": "00000001/00000002/00000002/00000000/00000005/00000002/00000006/00000005/00000002"}, "multiple kernel block reasons"),
            ({"kblock": "00000002/00000001/00000002/00000000/00000005/00000002/00000006/00000005/00000002"}, "runnable-to-blocked transitions"),
            ({"kblock": "00000002/00000002/00000001/00000000/00000005/00000002/00000006/00000005/00000002"}, "blocked-to-runnable wakeups"),
            ({"kblock": "00000002/00000002/00000002/00000001/00000005/00000002/00000006/00000005/00000002"}, "failed kernel block attempts"),
            ({"kblock": "00000002/00000002/00000002/00000000/00000004/00000002/00000006/00000005/00000002"}, "ABI probe PID"),
            ({"kblock": "00000002/00000002/00000002/00000000/00000005/00000001/00000006/00000005/00000002"}, "waitpid uses the generic block primitive"),
            ({"kblock": "00000002/00000002/00000002/00000000/00000005/00000002/00000000/00000005/00000002"}, "waited child PID"),
            ({"kblock": "00000002/00000002/00000002/00000000/00000005/00000002/FFFFFFFF/00000005/00000002"}, "waited child PID"),
            ({"kblock": "00000002/00000002/00000002/00000000/00000005/00000002/00000006/00000004/00000002"}, "ABI probe PID"),
            ({"kblock": "00000002/00000002/00000002/00000000/00000005/00000002/00000006/00000005/00000001"}, "waitpid woke through the generic wake path"),
            ({"ksleep": "00000000/00000001/00000001/00000000/00000000/00000005/00000021/00000001/00000005"}, "SYS_SLEEP_TICKS was exercised"),
            ({"ksleep": "00000001/00000000/00000001/00000000/00000000/00000005/00000021/00000001/00000005"}, "kernel marked a process non-runnable"),
            ({"ksleep": "00000001/00000001/00000000/00000000/00000000/00000005/00000021/00000001/00000005"}, "PIT wake path"),
            ({"ksleep": "00000001/00000001/00000001/00000000/00000001/00000005/00000021/00000001/00000005"}, "failed kernel sleep attempts"),
            ({"ksleep": "00000001/00000001/00000001/00000000/00000000/00000004/00000021/00000001/00000005"}, "ABI probe PID"),
            ({"ksleep": "00000001/00000001/00000001/00000000/00000000/00000005/00000000/00000001/00000005"}, "wake deadline"),
            ({"ksleep": "00000001/00000001/00000001/00000000/00000000/00000005/00000021/00000000/00000005"}, "wake deadline"),
            ({"ksleep": "00000001/00000001/00000001/00000000/00000000/00000005/00000021/00000001/00000004"}, "ABI probe PID"),
            ({"wait": "00000005/00000002/00000002/00000001/00000000/00000006/0000002A/00000001/00000001"}, "child was seeded"),
            ({"wait": "00000005/00000000/00000002/00000001/00000001/00000006/0000002A/00000001/00000001"}, "waitpid reaped"),
            ({"wait": "00000005/00000002/00000000/00000001/00000001/00000006/0000002A/00000001/00000001"}, "failure paths"),
            ({"wait": "00000005/00000002/00000002/00000001/00000001/FFFFFFFF/0000002A/00000001/00000001"}, "real reaped child PID"),
            ({"wait": "00000005/00000002/00000002/00000001/00000001/00000006/00000000/00000001/00000001"}, "exit status"),
            ({"wait": "00000005/00000002/00000002/00000001/00000001/00000006/0000002A/00000000/00000001"}, "blocking waitpid slept and woke"),
            ({"wait": "00000005/00000002/00000002/00000001/00000001/00000006/0000002A/00000001/00000000"}, "blocking waitpid slept and woke"),
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
            ({"psegs": "00000010:00000023:00000023:00000023"}, "restored Ring 3 user data"),
            ({"psegs": "00000023:00000023:00000023:00000000"}, "restored Ring 3 user data"),
            ({"peflags": "00003202:00000202:00000202:00000000:00000001"}, "source EFLAGS"),
            ({"peflags": "00000202:00003202:00000202:00000000:00000001"}, "target EFLAGS"),
            ({"peflags": "00000202:00000202:00003202:00000000:00000001"}, "frame EFLAGS"),
            ({"peflags": "00000202:00000202:00000202:00000000:00000000"}, "self-test exercised EFLAGS"),
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
                    clockirq="000002F6",
                    clocktick="000002F6",
                    clockms="00001D9C",
                    clockdoom="00000109",
                    clocksch="000002F6",
                    clockpirq="00000000",
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
        self.assertEqual(fields["krelocstep"], "KPMAIN_HIGH")
        self.assertEqual(fields["khixlat"], fields["khipa"])
        self.assertEqual(fields["khisxlat"], fields["khistkpa"])
        self.assertEqual(fields["khisword"], "48485354")
        self.assertEqual(fields["kpmap"], "OK")
        self.assertEqual(fields["kpcr3"], "00090000")
        self.assertEqual(fields["kpdirs"], "0000003F")
        self.assertEqual(fields["kpexec"], "OK")
        self.assertEqual(fields["kpecr3"], "00090000")
        self.assertEqual(fields["kpexlat"], fields["kpepa"])
        self.assertEqual(fields["kpesxlat"], fields["kpestkpa"])
        self.assertEqual(fields["kpesword"], "4B504558")
        self.assertEqual(fields["kreloc"], "HIGH")
        self.assertEqual(fields["kernvirt"], "C0010000")
        self.assertEqual(fields["kernphys"], "00010000")
        self.assertEqual(fields["klowid"], "00000001/00010000/00010000/00010003")
        self.assertEqual(fields["kreldir"], "OK")
        self.assertEqual(fields["kreldirx"], "00128000/00127003/00000000/00010000/00060000/FFFFFFFF")
        self.assertEqual(fields["kreldirp"], "00010003/00060003/00000000")
        self.assertEqual(fields["krelive"], "OK")
        self.assertEqual(fields["krelivep"], "00012000/0006F000/0002A5A4/FFFFFFFF/4B524C56")
        self.assertEqual(fields["khmain"], "OK")
        self.assertEqual(fields["khmxlat"], "00011300/00011800/0006FFD0/0006FFCC")
        self.assertEqual(fields["khmpte"], "00127003/00011003/00011003/0006F003/0006F003")
        self.assertIn("C0070000", fields["khmspan"])
        self.assertIn("C0000000", fields["khmspan"])
        for doc in (boot_doc, process_doc):
            self.assertIn("KERNEL_RELOCATION_GAP[current]=high-alias-only", doc)
            self.assertIn("KERNEL_RELOCATION_GAP[current]=temporary-high-exec-trampoline", doc)
            self.assertIn("KERNEL_RELOCATION_GAP[current]=persistent-high-alias-window", doc)
            self.assertIn("KERNEL_RELOCATION_GAP[current]=persistent-high-mainline", doc)
            self.assertIn("KERNEL_RELOCATION_GAP[current]=candidate-relocation-page-directory", doc)
            self.assertIn("KERNEL_RELOCATION_GAP[current]=bounded-relocation-cr3-switch", doc)
            self.assertIn("KERNEL_RELOCATION_GAP[missing]=long-lived-relocation-page-directory-mainline", doc)
            self.assertIn("KERNEL_RELOCATION_GAP[missing]=low-identity-teardown", doc)
            self.assertIn("`vmmhi=OK` is not a kernel relocation claim", doc)
            self.assertIn("`khiexec=OK` is not a kernel relocation claim", doc)
            self.assertIn("`kpmap=OK` is not a kernel relocation claim", doc)
            self.assertIn("`kpexec=OK` is not a full relocation claim", doc)
            self.assertIn("`khmain=OK`", doc)
            self.assertIn("`khmspan=`", doc)
            self.assertIn("`khmxlat=`", doc)
            self.assertIn("`khmpte=`", doc)
            self.assertIn("`klowid=`", doc)
            self.assertIn("`kreldir=OK`", doc)
            self.assertIn("`kreldirx=`", doc)
            self.assertIn("`kreldirp=`", doc)
            self.assertIn("`krelive=OK`", doc)
            self.assertIn("`krelivex=`", doc)
            self.assertIn("`krelivep=`", doc)
            self.assertIn("`krelocstep=KPMAIN_HIGH`", doc)
            self.assertIn("`kreloc=OK`", doc)
            self.assertIn("`kreloc=HIGH`", doc)

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
            "`VIBE_EXEC_ENV_MAX` environment strings",
            "descriptors limited to fd slots not opened with",
            "`vmreap=`",
        ):
            self.assertIn(source, process_exec)
        for source in (
            "target-specific stack bounds",
            "shared argv/envp stack builder",
            "process-owned fd\nretagging for inheritable descriptors",
            "future root-level game or tool ELFs",
            "`vmreap=`",
        ):
            self.assertIn(source, process_vm)
        for source in (
            "VIBE_EXEC_PATH_MAX = 16",
            "VIBE_EXEC_ARG_MAX = 8",
            "VIBE_EXEC_ARG_STR_MAX = 64",
            "VIBE_EXEC_ENV_MAX = 8",
            "VIBE_EXEC_ENV_STR_MAX = 64",
            "bounded argv/envp vectors",
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
