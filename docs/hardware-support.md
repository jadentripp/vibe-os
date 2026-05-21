# Hardware Support Matrix

This matrix is the hardware-claim boundary for vibe-os. It says what this repo
currently claims, and just as importantly what it does not claim.

Current hardware proof is bounded to QEMU's legacy PC machine model: BIOS boot,
IDE disk attachment, PS/2 input, PIT timer interrupts, VBE/VGA display paths, and
an optional SB16-compatible audio device. A passing host test or build-only check
does not prove additional hardware support.

Subsystem contract boundary:

- Input, audio, and FAT16 are reusable OS-facing syscall/header contracts for
  user programs, not one-off Doom hooks. Doom remains the main integration
  proof, but public headers now expose typed input events, mixer/PCM device
  records, and root-level FAT16 directory records with host tests that compile
  the guest ABI directly.
- The reusable contracts do not widen the hardware claim. Today they are proven
  only through QEMU PS/2 input, QEMU SB16 audio, and the generated FAT16 disk
  image. USB HID, AC97/HDA/USB audio, arbitrary FAT media, long filenames,
  physical sound cards, and real PC hardware remain unclaimed until their own
  rows and proof artifacts exist.

There is also a bounded PCI config-space table builder for QEMU's legacy PC
machine model. It reads bus 0, devices 0-31, functions 0-7 through ports
`0xcf8`/`0xcfc`, stores each present function in a fixed in-kernel
`bdf-id-class-header` table, then emits `pci=`, `pciprobe=`, `pcicount=`,
`pcifirst=`, `pciid=`, `pciclass=`, `pcitable=`, `pcitabcap=`, `pcitabuse=`,
`pcilast=`, `pciclassh=`, `pcimulti=`, `pciclsms=`, and `pciclsbr=` in the
smoke status block. This is a discovery/status contract only; it does not bind
drivers, walk secondary buses, or make AHCI, USB, or broad PCI enumeration
supported.

## Matrix

The `SUPPORT[...]` rows are machine-readable. Keep the `status`, `scope`,
`proof`, and `evidence` fields current whenever a device-class claim changes.
Claimed rows prove only the named QEMU device-model path. Status-only rows are
diagnostics, not driver support, and must not be used as compatibility claims.

| Device class | Claim status | Current scope | Proof boundary | Not claimed |
| --- | --- | --- | --- | --- |
| BIOS boot | Claimed | QEMU legacy BIOS booting the repo MBR and Stage 2 raw-sector loader | Cloud smoke / real-WAD smoke status artifacts | UEFI boot services or GPT/ESP boot |
| IDE/ATA PIO | Claimed | QEMU IDE disk with ATA PIO sector reads and writes | Cloud smoke status plus host image checks | AHCI, NVMe, USB storage, DMA IDE |
| FAT16 | Claimed | Generated FAT16 partition in the repo disk image | Host image tests plus cloud WAD/default/save status gates | General FAT filesystem or arbitrary media install/recovery |
| PS/2 keyboard | Claimed | QEMU PS/2 controller IRQ1 Set 1 scancode path | Cloud status counters and scripted key phases | USB HID keyboard |
| PS/2 mouse | Claimed | QEMU PS/2 auxiliary device IRQ12 3-byte packets | Cloud status counters and scripted mouse phase | USB HID mouse, wheel packets, pointer policy |
| PIT | Claimed | Legacy PIT timer tick and Doom 35 Hz conversion | Cloud smoke status counters | HPET, APIC timer, TSC scheduling |
| VBE/VGA | Claimed | QEMU VBE XRGB8888 LFB when available, VGA Mode 13h fallback | Cloud non-pixel status plus host framebuffer contract | Broad VBE mode matrix, GOP/UEFI framebuffer, physical GPU coverage |
| SB16 | Claimed | QEMU ISA SB16-compatible guest device at `0x220` with status-visible IRQ/DMA/mixer counters | Status-only SB16 continuity checker; audible aggregate proof only when `audio-proof.json` passes | AC97/HDA/USB audio, physical sound cards, human-audible proof by default |
| UEFI | Unclaimed | None | Future boot-path proof required before mention as supported | UEFI boot is not implemented; `boot/uefi/README.md` is a contract-only scaffold |
| PCI enumeration | Unclaimed | None | Future proof required before mention as supported | General PCI bus/device/function enumeration is not implemented; the bounded QEMU bus-0 status probe is not driver discovery, and AHCI or USB controllers are not used through PCI |
| AHCI | Unclaimed | None | Future proof required before mention as supported | AHCI/SATA native storage is not implemented |
| USB | Unclaimed | None | Future proof required before mention as supported | USB input and storage are not implemented |
| SMP | Unclaimed | None | Future proof required before mention as supported | Multiprocessor startup and scheduling are not implemented |
| APIC | Unclaimed | None | Future proof required before mention as supported | Local APIC, IOAPIC, and APIC timer support are not implemented |
| HPET | Unclaimed | None | Future proof required before mention as supported | HPET timer support is not implemented |
| Physical hardware | Unclaimed | None | Dedicated hardware or disposable-machine proof required before mention as supported | No real PC or broad hardware compatibility claim |

- `SUPPORT[BIOS_BOOT] status=claimed scope=qemu-bios proof=cloud-smoke evidence=status.txt`
- `SUPPORT[IDE_ATA_PIO] status=claimed scope=qemu-ide proof=cloud-smoke evidence=status.txt`
- `SUPPORT[FAT16] status=claimed scope=generated-disk-image proof=host-and-cloud evidence=disk-img-status`
- `SUPPORT[PS2_KEYBOARD] status=claimed scope=qemu-ps2 proof=scripted-cloud-input evidence=status-after-key-phases`
- `SUPPORT[PS2_MOUSE] status=claimed scope=qemu-ps2 proof=scripted-cloud-input evidence=status-after-mouse`
- `SUPPORT[PIT] status=claimed scope=qemu-pit proof=cloud-smoke evidence=ticks-dtick`
- `SUPPORT[VBE_VGA] status=claimed scope=qemu-vbe-vga proof=host-and-cloud evidence=framebuffer-status`
- `SUPPORT[SB16] status=claimed scope=qemu-sb16 proof=status-continuity evidence=audio-status`
- `SUPPORT[UEFI] status=unclaimed scope=none proof=future-boot-path-proof evidence=none`
- `SUPPORT[PCI_ENUMERATION] status=unclaimed scope=none proof=future-device-class-proof evidence=none`
- `SUPPORT[AHCI] status=unclaimed scope=none proof=future-device-class-proof evidence=none`
- `SUPPORT[USB] status=unclaimed scope=none proof=future-device-class-proof evidence=none`
- `SUPPORT[SMP] status=unclaimed scope=none proof=future-device-class-proof evidence=none`
- `SUPPORT[APIC] status=unclaimed scope=none proof=future-device-class-proof evidence=none`
- `SUPPORT[HPET] status=unclaimed scope=none proof=future-device-class-proof evidence=none`
- `SUPPORT[PHYSICAL_HARDWARE] status=unclaimed scope=none proof=dedicated-hardware-proof evidence=none`

Status-only hardware discovery scaffolds:

- `PCI_STATUS[QEMU_BUS0_CONFIG] status=status-only scope=qemu-pci-bus0 proof=cloud-smoke-status evidence=pci-status-fields`
- `PCI_TABLE[QEMU_BUS0_CLASS_TABLE] status=status-only scope=qemu-pci-bus0 layout=bdf-id-class-header capacity=256 evidence=pci-table-status-fields`

Claimed hardware status proof counters:

- `STATUS_PROOF[IDE_ATA_PIO] status=required scope=qemu-ide fields=ata,ataop,atawait,atalba,atastat,ataerr,atafail,atatmo evidence=status.txt`
- `STATUS_PROOF[PS2_KEYBOARD] status=required scope=qemu-ps2 fields=inputqueue,inputpoll,inputlast,keyirq,keyqueue,keypoll,keyseen,keylast evidence=status-after-key-phases`
- `STATUS_PROOF[PS2_MOUSE] status=required scope=qemu-ps2 fields=mouse,mouseirq,mousepkt,mousepoll,mousebtn,mousedelta evidence=status-after-mouse`
- `STATUS_PROOF[VBE_VGA] status=required scope=qemu-vbe-vga fields=gfx,fb,fbpolicy,fbgeom,fbdirty,doompresent,doompal,doomframe,doomnonzero,doomcolors evidence=framebuffer-status`
- `STATUS_PROOF[SB16] status=required scope=qemu-sb16 fields=audio,sb16,dma,play,audioirq,ack8,refill,sfxdma,musicpull,pcmbuf evidence=audio-status`

These rows name the minimum aggregate status fields a disposable QEMU proof must
carry before the corresponding claimed hardware row can be cited. They do not
require raw screenshots, VM logs, WAD data, pixel dumps, or raw audio in git.

## Future Proof Boundaries

The `PROOF_REQUIREMENT[...]` rows define what would count before an unclaimed
hardware class could become supported. These rows are intentionally stricter
than "the source contains a stub" or "QEMU still boots".

| Future class | Minimum proof before support claim |
| --- | --- |
| UEFI | Build a PE32 EFI application into an ESP image, load the kernel from ESP/FAT, hand off GOP framebuffer and UEFI memory map data, call `ExitBootServices`, and boot the current kernel through OVMF in disposable cloud CI. |
| PCI enumeration | Build a reusable PCI device table from config space, record every present bus/device/function with vendor/device/class/subclass/prog-if data, handle multifunction devices, and prove the table in at least one disposable QEMU PCI run without promoting status-only probes into drivers. |
| AHCI | Discover an AHCI controller through PCI, map the BAR, reset the HBA, identify a SATA disk, read sectors through AHCI with the IDE path disabled for that proof, and load the WAD through that path. |
| USB | Enumerate a USB host controller, enumerate at least one HID keyboard path and one mass-storage path, prove Doom input through USB HID, and prove WAD/file reads through USB storage with PS/2 or IDE disabled for the relevant proof. |
| APIC | Enable Local APIC and IOAPIC, route at least timer and keyboard/storage interrupts through APIC while the legacy PIC is masked for that proof, and expose cloud status counters showing the APIC path handled the interrupts. |
| SMP | Parse CPU topology, start at least one application processor, install per-CPU stacks/TSS/interrupt state, run a bounded scheduler or worker proof on more than one CPU, and report per-CPU progress from a disposable `-smp` cloud run. |
| HPET | Discover HPET through firmware tables, map the HPET MMIO block, drive a timer/comparator proof independent of PIT ticks, and show Doom time or scheduler time advancing from HPET status counters. |
| Physical hardware | Boot a disposable machine or lab PC, capture serial/status evidence plus exact hardware inventory, prove Doom reaches the same runtime gates on that exact machine, and document the exact model as supported without generalizing to broad PC compatibility. |

- `PROOF_REQUIREMENT[UEFI] status=future artifact=ovmf-cloud-boot requires=pe32-esp-gop-mmap-exitbs evidence=none`
- `PROOF_REQUIREMENT[PCI_ENUMERATION] status=future artifact=pci-cloud-class-table requires=all-bdfs-class-table evidence=none`
- `PROOF_REQUIREMENT[AHCI] status=future artifact=ahci-cloud-wad-read requires=pci-ahci-bar-identify-read evidence=none`
- `PROOF_REQUIREMENT[USB] status=future artifact=usb-cloud-input-storage requires=host-controller-hid-storage evidence=none`
- `PROOF_REQUIREMENT[SMP] status=future artifact=smp-cloud-run requires=ap-startup-percpu-progress evidence=none`
- `PROOF_REQUIREMENT[APIC] status=future artifact=apic-cloud-irq requires=lapic-ioapic-pic-masked evidence=none`
- `PROOF_REQUIREMENT[HPET] status=future artifact=hpet-cloud-timer requires=acpi-hpet-mmio-comparator evidence=none`
- `PROOF_REQUIREMENT[PHYSICAL_HARDWARE] status=future artifact=disposable-hardware-run requires=machine-inventory-status-capture evidence=none`

## Machine-Checked Negative Claims

These rows make unsupported hardware claims explicit. While they are active,
docs and tests may discuss the class only as unclaimed/future/unsupported.

- `NEGATIVE_CLAIM[UEFI] status=active scope=boot claim=no-uefi-boot evidence=boot-uefi-contract`
- `NEGATIVE_CLAIM[PCI_ENUMERATION] status=active scope=kernel claim=no-general-pci-enumeration evidence=status-only-qemu-bus0`
- `NEGATIVE_CLAIM[AHCI] status=active scope=storage claim=no-ahci-driver evidence=ide-only-storage`
- `NEGATIVE_CLAIM[USB] status=active scope=input-storage claim=no-usb-stack evidence=ps2-ide-only`
- `NEGATIVE_CLAIM[SMP] status=active scope=cpu claim=no-multiprocessor-runtime evidence=single-cpu-kernel`
- `NEGATIVE_CLAIM[APIC] status=active scope=interrupts claim=no-apic-routing evidence=pic-pit-only`
- `NEGATIVE_CLAIM[HPET] status=active scope=timer claim=no-hpet-timer evidence=pit-only`
- `NEGATIVE_CLAIM[PHYSICAL_HARDWARE] status=active scope=hardware claim=no-physical-machine-proof evidence=qemu-only`

## Next Hardware-Class Unlock

- `NEXT_UNLOCK[PCI_ENUMERATION] priority=first scope=qemu-pci proof=cloud-class-table evidence=none`

PCI enumeration is the next implementable hardware-class unlock. It is the
lowest-risk bridge from today's status-only config-space table toward future
AHCI, USB, APIC, and real-device work. The current implementation already
produces a reusable in-kernel bus-0 PCI table and records class/subclass/prog-if
data for every present function, but `SUPPORT[PCI_ENUMERATION]` stays
unclaimed until a disposable cloud proof validates that table as the primary
enumeration artifact and a driver-facing API consumes it. AHCI and USB must
stay unclaimed until a real driver consumes that table.

## Rules For New Claims

- A new device class must add or update one `SUPPORT[...]` row before README,
  docs, runbooks, tests, or release notes describe it as supported.
- Changing a future class from unclaimed to claimed must also retire or update
  the matching `NEGATIVE_CLAIM[...]` row and replace `evidence=none` in the
  matching `PROOF_REQUIREMENT[...]` row with the artifact that proves it.
- The proof must be host-checkable from source or from disposable-runner artifacts
  that do not include WADs, disk images, screenshots, pixel dumps, raw audio, or
  VM logs committed to git.
- Physical hardware support requires explicit hardware proof notes. QEMU evidence
  alone can only claim the matching QEMU device model.
- PCI status and table fields are not a PCI support claim. They prove only that
  the kernel ran the bounded QEMU bus-0 config-space scan, populated the fixed
  `bdf-id-class-header` table, and recorded table summaries in status-only
  diagnostics. A future PCI claim needs a new `SUPPORT[...]` row boundary or an
  update to `SUPPORT[PCI_ENUMERATION]`.
- Compatibility language should name the device class and proof boundary. Use
  "QEMU BIOS/IDE/PS2/VBE/SB16 target" for the current scope, not "PC hardware
  support" or "real hardware support".
