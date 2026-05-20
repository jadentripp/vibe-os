# Hardware Support Matrix

This matrix is the hardware-claim boundary for vibe-os. It says what this repo
currently claims, and just as importantly what it does not claim.

Current hardware proof is bounded to QEMU's legacy PC machine model: BIOS boot,
IDE disk attachment, PS/2 input, PIT timer interrupts, VBE/VGA display paths, and
an optional SB16-compatible audio device. A passing host test or build-only check
does not prove additional hardware support.

There is also a bounded PCI config-space status probe for QEMU's legacy PC
machine model. It reads bus 0, devices 0-31, functions 0-7 through ports
`0xcf8`/`0xcfc`, then emits `pci=`, `pciprobe=`, `pcicount=`, `pcifirst=`,
`pciid=`, and `pciclass=` in the smoke status block. This is a discovery/status
contract only; it does not bind drivers, walk secondary buses, or make AHCI,
USB, or broad PCI enumeration supported.

## Matrix

The `SUPPORT[...]` rows are machine-readable. Keep the `status`, `scope`,
`proof`, and `evidence` fields current whenever a device-class claim changes.

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

## Rules For New Claims

- A new device class must add or update one `SUPPORT[...]` row before README,
  docs, runbooks, tests, or release notes describe it as supported.
- The proof must be host-checkable from source or from disposable-runner artifacts
  that do not include WADs, disk images, screenshots, pixel dumps, raw audio, or
  VM logs committed to git.
- Physical hardware support requires explicit hardware proof notes. QEMU evidence
  alone can only claim the matching QEMU device model.
- PCI status fields are not a PCI support claim. They prove only that the kernel
  ran the bounded QEMU bus-0 config-space scan and recorded a first present
  function, if any, in status-only diagnostics. A future PCI claim needs a new
  `SUPPORT[...]` row boundary or an update to `SUPPORT[PCI_ENUMERATION]`.
- Compatibility language should name the device class and proof boundary. Use
  "QEMU BIOS/IDE/PS2/VBE/SB16 target" for the current scope, not "PC hardware
  support" or "real hardware support".
