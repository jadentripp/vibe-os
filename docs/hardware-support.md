# Hardware Support Matrix

This matrix is the hardware-claim boundary for vibe-os. It says what this repo
currently claims, and just as importantly what it does not claim.

Current hardware proof is bounded to QEMU's legacy PC machine model: BIOS boot,
IDE disk attachment, PS/2 input, PIT timer interrupts, VBE/VGA display paths, and
an optional SB16-compatible audio device. A passing host test or build-only check
does not prove additional hardware support.

- `CURRENT_TARGET[QEMU_LEGACY_PC] status=claimed machine=qemu-legacy-pc includes=bios,ide-ata-pio,ps2-keyboard,ps2-mouse,pit,vbe-vga,sb16 excludes=uefi,physical-hardware,general-pci,ahci-sata,usb-input-storage,apic-ioapic,hpet,smp,arbitrary-disk-install evidence=support-rows`

That row is the short version of the contract: QEMU BIOS/IDE/PS2/VBE/SB16 is
the supported target; UEFI, physical hardware, general PCI, AHCI/SATA, USB
input/storage, APIC/IOAPIC, HPET, SMP, and installation to arbitrary disks are
outside the claim until their own proof rows change.

QEMU-only device-model boundary:

- `QEMU_DEVICE_MODEL[BIOS_BOOT] status=claimed machine=qemu-legacy-pc device=legacy-bios proof=cloud-smoke evidence=status.txt`
- `QEMU_DEVICE_MODEL[IDE_ATA_PIO] status=claimed machine=qemu-legacy-pc device=piix-ide proof=cloud-smoke evidence=status.txt`
- `QEMU_DEVICE_MODEL[PS2_KEYBOARD] status=claimed machine=qemu-legacy-pc device=i8042-keyboard proof=scripted-cloud-input evidence=status-after-key-phases`
- `QEMU_DEVICE_MODEL[PS2_MOUSE] status=claimed machine=qemu-legacy-pc device=i8042-mouse proof=scripted-cloud-input evidence=status-after-mouse`
- `QEMU_DEVICE_MODEL[PIT] status=claimed machine=qemu-legacy-pc device=i8254-pit proof=cloud-smoke evidence=ticks-dtick`
- `QEMU_DEVICE_MODEL[VBE_VGA] status=claimed machine=qemu-legacy-pc device=bochs-vbe-vga proof=host-and-cloud evidence=framebuffer-status`
- `QEMU_DEVICE_MODEL[SB16] status=claimed machine=qemu-legacy-pc device=isa-sb16 proof=status-continuity evidence=audio-status`
- `QEMU_DEVICE_MODEL[PCI_BUS0_STATUS] status=status-only machine=qemu-legacy-pc device=pci-config-ports proof=cloud-smoke-status evidence=pci-status-fields`

These rows are the machine-readable reason the current claim is QEMU-only. They
name emulated device models and status fields, not interchangeable PC hardware.
The `PCI_BUS0_STATUS` row is still diagnostics-only and does not make PCI
enumeration, AHCI/SATA, USB, APIC, or HPET supported.

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
| PCI enumeration | Unclaimed | None | Future table proof and driver-facing contract required before mention as supported | General PCI bus/device/function enumeration is not implemented; the bounded QEMU bus-0 status probe is not driver discovery, and AHCI or USB controllers are not used through PCI |
| AHCI/SATA | Unclaimed | None | Future AHCI/SATA storage proof required before mention as supported | AHCI/SATA native storage is not implemented |
| USB input/storage | Unclaimed | None | Future USB HID and mass-storage proof required before mention as supported | USB input and storage are not implemented |
| SMP | Unclaimed | None | Future multiprocessor runtime proof required before mention as supported | Multiprocessor startup and scheduling are not implemented |
| APIC/IOAPIC | Unclaimed | None | Future APIC interrupt-routing proof required before mention as supported | Local APIC, IOAPIC, and APIC timer support are not implemented |
| HPET | Unclaimed | None | Future HPET timer proof required before mention as supported | HPET timer support is not implemented |
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
- `SUPPORT[PCI_ENUMERATION] status=unclaimed scope=none proof=future-pci-enumeration-table-proof evidence=none`
- `SUPPORT[AHCI] status=unclaimed scope=none proof=future-ahci-sata-storage-proof evidence=none`
- `SUPPORT[USB] status=unclaimed scope=none proof=future-usb-input-storage-proof evidence=none`
- `SUPPORT[SMP] status=unclaimed scope=none proof=future-multiprocessor-runtime-proof evidence=none`
- `SUPPORT[APIC] status=unclaimed scope=none proof=future-apic-interrupt-proof evidence=none`
- `SUPPORT[HPET] status=unclaimed scope=none proof=future-hpet-timer-proof evidence=none`
- `SUPPORT[PHYSICAL_HARDWARE] status=unclaimed scope=none proof=dedicated-hardware-proof evidence=none`

Boot-device proof boundary:

- `BOOT_DEVICE_BOUNDARY[BIOS_IDE_RAW_LBA] status=claimed firmware=bios device=qemu-ide layout=mbr-stage2-raw-lba proof=cloud-smoke evidence=status.txt`
- `BOOT_DEVICE_BOUNDARY[UEFI_ESP_KERNEL_FILE] status=future firmware=uefi device=esp-fat layout=pe32-loader-kernel-file proof=ovmf-cloud-boot evidence=none`
- `BOOT_DEVICE_BOUNDARY[AHCI_SATA_DISK] status=future firmware=bios-or-uefi device=ahci-sata layout=driver-sector-read proof=ahci-cloud-wad-read evidence=none`
- `BOOT_DEVICE_BOUNDARY[USB_MASS_STORAGE] status=future firmware=bios-or-uefi device=usb-storage layout=controller-enumeration-file-read proof=usb-cloud-input-storage evidence=none`
- `BOOT_DEVICE_BOUNDARY[PHYSICAL_MACHINE] status=future firmware=machine-specific device=disposable-pc layout=documented-media proof=hardware-inventory-boot evidence=none`

The boot-device boundary is intentionally separate from the filesystem and
storage-driver rows. Today the boot device is the repo-built raw-LBA disk image
attached to QEMU IDE. A future ESP, AHCI/SATA disk, USB mass-storage device, or
physical machine boot must move its matching row from `status=future` only after
the proof artifact exists.

Status-only hardware discovery scaffolds:

- `PCI_STATUS[QEMU_BUS0_CONFIG] status=status-only scope=qemu-pci-bus0 proof=cloud-smoke-status evidence=pci-status-fields`
- `PCI_TABLE[QEMU_BUS0_CLASS_TABLE] status=status-only scope=qemu-pci-bus0 layout=bdf-id-class-header capacity=256 evidence=pci-table-status-fields`
- `PCI_TABLE_CONTRACT[QEMU_BUS0_SCAN] status=status-only bus=0 devices=32 functions=8 evidence=pci-status-fields`
- `PCI_TABLE_CONTRACT[ENTRY_LAYOUT] status=status-only dwords=4 fields=bdf,id,class,header evidence=pci-table-status-fields`
- `PCI_TABLE_CONTRACT[NO_DRIVER_BINDING] status=guardrail consumers=status-only drivers=none evidence=negative-claims`

The PCI table contract is intentionally narrower than a future PCI enumeration claim.
`QEMU_BUS0_SCAN` pins the host-checkable bounds to bus 0, device slots 0-31,
and functions 0-7. `ENTRY_LAYOUT` pins the table ABI that later drivers would
need to consume before a support claim can change. `NO_DRIVER_BINDING` keeps the
current table as diagnostics only: AHCI, USB, APIC, and other future drivers
must not be described as discovered or usable through this table until they have
their own proof rows and driver code.

Claimed hardware status proof counters:

- `STATUS_PROOF[IDE_ATA_PIO] status=required scope=qemu-ide fields=ata,ataop,atawait,atalba,atastat,ataerr,atafail,atatmo evidence=status.txt`
- `STATUS_PROOF[PS2_KEYBOARD] status=required scope=qemu-ps2 fields=inputqueue,inputpoll,inputlast,keyirq,keyqueue,keypoll,keyseen,keylast evidence=status-after-key-phases`
- `STATUS_PROOF[PS2_MOUSE] status=required scope=qemu-ps2 fields=mouse,mouseirq,mousepkt,mousepoll,mousebtn,mousedelta evidence=status-after-mouse`
- `STATUS_PROOF[VBE_VGA] status=required scope=qemu-vbe-vga fields=gfx,fb,fbpolicy,fbgeom,fbdirty,doompresent,doompal,doomframe,doomnonzero,doomcolors evidence=framebuffer-status`
- `STATUS_PROOF[SB16] status=required scope=qemu-sb16 fields=audio,sb16,dma,play,audioirq,ack8,refill,sfxdma,musicpull,pcmbuf evidence=audio-status`

These rows name the minimum aggregate status fields a disposable QEMU proof must
carry before the corresponding claimed hardware row can be cited. They do not
require raw screenshots, VM logs, WAD data, pixel dumps, or raw audio in git.

The VM/process legitimacy gate is adjacent to, but separate from, the hardware
matrix. Generated-WAD OS smoke runs `tools/check_vm_status_proof.py
--require-exec` to prove paging, Ring 3 exec, bounded process records, fd
handoff, and wait/reap. Live PIT preemption between two user processes is
machine-required only in the real-WAD smoke and soak workflows with
`--require-preempt`, because those statuses keep gameplay alive long enough for
the Doom/preempt-probe pair to switch under timer IRQs. A short generated-WAD OS
smoke may exit Doom with `doomrun=EXIT` and `gameplay=WAIT` before one scheduler
quantum; that is not a hardware regression or a valid preemption proof by
itself.

## Future Proof Boundaries

The `PROOF_REQUIREMENT[...]` rows define what would count before an unclaimed
hardware class could become supported. These rows are intentionally stricter
than "the source contains a stub" or "QEMU still boots".

| Future class | Minimum proof before support claim |
| --- | --- |
| UEFI | Build a PE32 EFI application into an ESP image, load the kernel from ESP/FAT, hand off GOP framebuffer and UEFI memory map data, call `ExitBootServices`, and boot the current kernel through OVMF in disposable cloud CI. |
| PCI enumeration | Build a reusable PCI device table from config space, record every present bus/device/function with vendor/device/class/subclass/prog-if data, handle multifunction devices, expose a read-only driver-facing table API, and prove the table in at least one disposable QEMU PCI run without promoting status-only probes into drivers. |
| AHCI/SATA | Discover an AHCI controller through PCI, map the BAR, reset the HBA, identify a SATA disk, read sectors through AHCI with the IDE path disabled for that proof, and load the WAD through that path. |
| USB input/storage | Enumerate a USB host controller, enumerate at least one HID keyboard path and one mass-storage path, prove Doom input through USB HID, and prove WAD/file reads through USB storage with PS/2 or IDE disabled for the relevant proof. |
| APIC | Enable Local APIC and IOAPIC, route at least timer and keyboard/storage interrupts through APIC while the legacy PIC is masked for that proof, and expose cloud status counters showing the APIC path handled the interrupts. |
| SMP | Parse CPU topology, start at least one application processor, install per-CPU stacks/TSS/interrupt state, run a bounded scheduler or worker proof on more than one CPU, and report per-CPU progress from a disposable `-smp` cloud run. |
| HPET | Discover HPET through firmware tables, map the HPET MMIO block, drive a timer/comparator proof independent of PIT ticks, and show Doom time or scheduler time advancing from HPET status counters. |
| Physical hardware | Boot a disposable machine or lab PC, capture serial/status evidence plus exact hardware inventory, prove Doom reaches the same runtime gates on that exact machine, and document the exact model as supported without generalizing to broad PC compatibility. |

- `PROOF_REQUIREMENT[UEFI] status=future artifact=ovmf-cloud-boot requires=pe32-esp-gop-mmap-exitbs-boot evidence=none`
- `PROOF_REQUIREMENT[PCI_ENUMERATION] status=future artifact=pci-cloud-class-table requires=all-bdfs-class-subclass-progif-table evidence=none`
- `PROOF_REQUIREMENT[AHCI] status=future artifact=ahci-cloud-wad-read requires=pci-ahci-bar-identify-sata-read evidence=none`
- `PROOF_REQUIREMENT[USB] status=future artifact=usb-cloud-input-storage requires=host-controller-hid-mass-storage evidence=none`
- `PROOF_REQUIREMENT[SMP] status=future artifact=smp-cloud-run requires=ap-startup-percpu-progress evidence=none`
- `PROOF_REQUIREMENT[APIC] status=future artifact=apic-cloud-irq requires=lapic-ioapic-pic-masked evidence=none`
- `PROOF_REQUIREMENT[HPET] status=future artifact=hpet-cloud-timer requires=acpi-hpet-mmio-comparator evidence=none`
- `PROOF_REQUIREMENT[PHYSICAL_HARDWARE] status=future artifact=disposable-hardware-run requires=machine-inventory-status-reboot-capture evidence=none`

## Machine-Checked Negative Claims

These rows make unsupported hardware claims explicit. While they are active,
docs and tests may discuss the class only as unclaimed/future/unsupported.

- `NEGATIVE_CLAIM[UEFI] status=active scope=boot claim=no-uefi-boot evidence=boot-uefi-contract`
- `NEGATIVE_CLAIM[PCI_ENUMERATION] status=active scope=kernel claim=no-general-pci-enumeration evidence=status-only-qemu-bus0`
- `NEGATIVE_CLAIM[AHCI] status=active scope=storage claim=no-ahci-sata-driver evidence=ide-only-storage`
- `NEGATIVE_CLAIM[USB] status=active scope=input-storage claim=no-usb-input-or-storage-stack evidence=ps2-ide-only`
- `NEGATIVE_CLAIM[SMP] status=active scope=cpu claim=no-multiprocessor-runtime evidence=single-cpu-kernel`
- `NEGATIVE_CLAIM[APIC] status=active scope=interrupts claim=no-apic-ioapic-routing evidence=pic-pit-only`
- `NEGATIVE_CLAIM[HPET] status=active scope=timer claim=no-hpet-timer evidence=pit-only`
- `NEGATIVE_CLAIM[PHYSICAL_HARDWARE] status=active scope=hardware claim=no-physical-machine-proof evidence=qemu-only`

## Next Hardware-Class Unlock

- `NEXT_UNLOCK[PCI_ENUMERATION] priority=first scope=qemu-pci proof=cloud-class-table evidence=none`
- `NEXT_IMPLEMENTATION_CONTRACT[PCI_DRIVER_TABLE_API] status=scaffold scope=qemu-pci requires=read-only-bdf-class-table proof=host-check-plus-cloud-status unlocks=ahci-sata,usb,apic evidence=none`

PCI enumeration is the next implementable hardware-class unlock. It is the
lowest-risk bridge from today's status-only config-space table toward future
AHCI, USB, APIC, and real-device work. The current implementation already
produces a reusable in-kernel bus-0 PCI table and records class/subclass/prog-if
data for every present function, but `SUPPORT[PCI_ENUMERATION]` stays
unclaimed until a disposable cloud proof validates that table as the primary
enumeration artifact and a driver-facing API consumes it. AHCI and USB must
stay unclaimed until a real driver consumes that table.

The next implementation contract is deliberately small: make the existing
`bdf-id-class-header` table readable through a stable, checked API before adding
any AHCI, USB, or APIC driver. That lets future drivers share one proven
enumeration boundary instead of each inventing its own config-space scan.

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
