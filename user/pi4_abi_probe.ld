OUTPUT_FORMAT("elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
ENTRY(_start)

PHDRS
{
  text PT_LOAD FLAGS(5);
  rodata PT_LOAD FLAGS(4);
  data PT_LOAD FLAGS(6);
}

SECTIONS
{
  . = 0x0000000000e80000;
  __pi4_user_image_base = .;

  .text : ALIGN(16)
  {
    KEEP(*(.text.pi4_abi_probe.entry))
    *(.text .text.*)
  } :text

  .rodata : ALIGN(8)
  {
    *(.rodata .rodata.*)
  } :rodata

  .data : ALIGN(8)
  {
    *(.data .data.*)
  } :data

  .bss (NOLOAD) : ALIGN(16)
  {
    __pi4_user_bss_start = .;
    *(.bss .bss.* COMMON)
    __pi4_user_bss_end = .;
  } :data

  __pi4_user_image_end = .;

  /DISCARD/ :
  {
    *(.comment)
    *(.note.GNU-stack)
    *(.eh_frame)
  }
}
