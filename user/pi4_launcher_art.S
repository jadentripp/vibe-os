#include "pi4_runtime.inc"

// Assembly-owned launcher artwork state for the Pi 4 app picker.
//
// The launcher contains full-size built-in Doom/Quake icon renderers. This
// keeps the OS path out of C while leaving room for later asset-decoded icon
// buffers from WAD/PAK resources.

.arch armv8-a

.equ PI4_LAUNCHER_ICON_SIZE, 256
.equ PI4_LAUNCHER_ICON_PIXELS, PI4_LAUNCHER_ICON_SIZE * PI4_LAUNCHER_ICON_SIZE

.section .text.pi4_launcher_art, "ax", %progbits
.balign 16
.global pi4_launcher_load_art
.type pi4_launcher_load_art, %function
pi4_launcher_load_art:
    adrp x0, pi4_launcher_art_flags
    add x0, x0, :lo12:pi4_launcher_art_flags
    str xzr, [x0]
    ret
.size pi4_launcher_load_art, . - pi4_launcher_load_art

.section .bss.pi4_launcher_art, "aw", %nobits
.balign 8
.global pi4_launcher_art_flags
pi4_launcher_art_flags:
    .skip 8

.balign 8
.global pi4_launcher_app_discovery_flags
pi4_launcher_app_discovery_flags:
    .skip 8

.balign 64
.global pi4_launcher_doom_icon_pixels
pi4_launcher_doom_icon_pixels:
    .skip PI4_LAUNCHER_ICON_PIXELS

.balign 64
.global pi4_launcher_quake_icon_pixels
pi4_launcher_quake_icon_pixels:
    .skip PI4_LAUNCHER_ICON_PIXELS

.section .note.GNU-stack, "", %progbits
