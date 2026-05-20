# Boot, Loader, And VM Contract

This is the current low-level contract, written plainly so the project can be
judged on what it actually does.

## Boot Chain

The boot path uses no GRUB, Multiboot, UEFI loader, or host OS runtime.
`boot/stage1.asm` is a 512-byte MBR sector. BIOS loads it at `0x7c00` in real
mode, and Stage 1 uses EDD `INT 0x13 AH=0x42` to read Stage 2 from raw disk
sectors `LBA 1-16` into `0x00008000`.

`boot/stage2.asm` is still real-mode code when it reads the kernel. It uses the
same EDD packet path to load the prelinked kernel ELF image from `LBA 17-144`
into `0x00020000`. The FAT16 partition starts at `LBA 2048`, so the raw boot
area and filesystem do not overlap.

Before entering the kernel, Stage 2 records the BIOS memory/video data it needs
in the low-memory boot-info block, attempts VBE linear-framebuffer setup with a
Mode 13h fallback, enables A20 through port `0x92`, loads its own flat GDT, sets
`CR0.PE`, and uses a far jump to enter 32-bit protected mode. The protected-mode
entry sets flat data selectors and a temporary stack, then calls the Stage 2 ELF
loader.

## UEFI Scaffold Boundary

`boot/uefi/README.md` is a contract-only UEFI scaffold. It defines the future
`UEFI_BOOT[...]` rows for a PE/COFF entry, ESP/FAT kernel load, GOP framebuffer
handoff, UEFI memory map capture, `ExitBootServices`, ELF32-compatible kernel
handoff, and separate opt-in build integration. Every row remains
`status=unimplemented`, and SUPPORT[UEFI] remains unclaimed in
`docs/hardware-support.md`.

The scaffold is not part of the current Makefile image path. Today the booted
artifact is still the BIOS raw-sector chain above; there is no ESP image, UEFI
application, firmware memory-map handoff, or UEFI boot proof.

## ELF Handoff

The kernel is not treated as a raw sector blob. Stage 2 checks the ELF magic,
class, endianness, executable type, i386 machine, and 32-byte program-header
size. It walks `PT_LOAD` program headers, rejects `p_memsz < p_filesz`, copies
file bytes to the segment physical address, zeros the BSS tail, and jumps to the
ELF entry point. The linked kernel entry is currently `0x00010000`.

The loader is intentionally small. It does not resolve relocations at boot; the
repo linker resolves them ahead of time. Build and host tests enforce the raw
windows: Stage 2 must fit in 8 KiB and the kernel ELF must fit in 64 KiB.

## Paging Reality

The kernel enables 32-bit paging after its own GDT, IDT, PIC, PIT, and boot data
are initialized. The base kernel page directory keeps the first 32 MiB
identity-mapped with supervisor writable PTEs. This is deliberate early-OS
plumbing; the kernel is not higher-half or position-independent yet.

The VMM does now have a source-level higher-half contract for the next step:
`KERNEL_HIGHER_HALF_BASE` is `0xc0000000`, and a host-checked self-test maps
`VMM_HIGH_TEST_VADDR` at that base to a PMM-allocated physical frame. That test
uses a dynamically allocated page table, writes through the high virtual alias,
verifies the non-identity physical frame changed, unmaps the alias, and frees the
test frame. This proves the mapper can build high, non-identity kernel mappings
after PMM is online, but it does not relocate the running kernel yet.

User processes get separate page directories. Those directories start as clones
of the supervisor kernel map, then replace only the user windows with private
page tables carrying the user bit:

- the probe process owns PDE 3 for its `0x00e80000` window
- Doom owns PDEs 4 through 7 for `0x01000000` through `0x02000000`
- kernel low memory remains supervisor-only in both user page directories
- heap pages are granted as `SYS_SBRK` advances the process break

The ELF prepare paths preserve write permission from `PT_LOAD` flags. Text pages
can be user-readable without `PTE_WRITE`, while data, stack, and heap pages are
user-writable. Execute intent is tracked in VM-region metadata, but current
32-bit paging has no NX enforcement.

## Fixed Low-Memory Reservations

Several fixed low-memory pages are reserved by design today:

- `0x00007000`: boot-info block from Stage 2 to the kernel
- `0x00080000` and `0x00082000`: process page directories
- `0x00081000`, `0x00084000`-`0x00087000`: user PDE tables
- `0x00090000`: kernel page directory
- `0x00091000`: low-memory identity page tables
- `0x0009c000`: optional VBE LFB page table
- `0x0009d000`: smoke/status block

That is technically honest for the current milestone, but the boot-critical
kernel/process tables are still fixed low-memory infrastructure. The VMM now
accounts static, active, dynamic, and guard page-table state and can allocate
additional page tables for mappings outside the original 32 MiB identity span.
The remaining legitimacy work is moving the running kernel to the higher-half
contract, non-identity user frame backing, page-table reclamation, and stronger
execute-permission enforcement.
