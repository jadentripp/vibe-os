BITS 32

%define VIBE_SYS_GAMEPLAY_STATUS 15
%define VIBE_DOOM_SAVEACTION_STATUS 0x10000000
%define VIBE_DOOM_SAVEACTION_STREAM 0x00000080
%define VIBE_DOOM_SAVEACTION_GAMEACTION_SHIFT 8
%define VIBE_DOOM_SAVEACTION_SLOT_SHIFT 16

%define VIBE_SAVE_STAGE_ARCHIVE_PLAYERS_BEFORE 0x01
%define VIBE_SAVE_STAGE_ARCHIVE_PLAYERS_AFTER 0x02
%define VIBE_SAVE_STAGE_ARCHIVE_WORLD_BEFORE 0x03
%define VIBE_SAVE_STAGE_ARCHIVE_WORLD_AFTER 0x04
%define VIBE_SAVE_STAGE_ARCHIVE_THINKERS_BEFORE 0x05
%define VIBE_SAVE_STAGE_ARCHIVE_THINKERS_AFTER 0x06
%define VIBE_SAVE_STAGE_ARCHIVE_SPECIALS_BEFORE 0x07
%define VIBE_SAVE_STAGE_ARCHIVE_SPECIALS_AFTER 0x08
%define VIBE_SAVE_STAGE_UNARCHIVE_PLAYERS_BEFORE 0x11
%define VIBE_SAVE_STAGE_UNARCHIVE_PLAYERS_AFTER 0x12
%define VIBE_SAVE_STAGE_UNARCHIVE_WORLD_BEFORE 0x13
%define VIBE_SAVE_STAGE_UNARCHIVE_WORLD_AFTER 0x14
%define VIBE_SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE 0x15
%define VIBE_SAVE_STAGE_UNARCHIVE_THINKERS_AFTER 0x16
%define VIBE_SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE 0x17
%define VIBE_SAVE_STAGE_UNARCHIVE_SPECIALS_AFTER 0x18

section .text

global vibe_doom_save_stream_note_error
global P_ArchivePlayers
global P_UnArchivePlayers
global P_ArchiveWorld
global P_UnArchiveWorld
global P_ArchiveThinkers
global P_UnArchiveThinkers
global P_ArchiveSpecials
global P_UnArchiveSpecials

extern save_p
extern savebuffer
extern savegameslot
extern vibe_syscall3
extern doom_original_P_ArchivePlayers
extern doom_original_P_UnArchivePlayers
extern doom_original_P_ArchiveWorld
extern doom_original_P_UnArchiveWorld
extern doom_original_P_ArchiveThinkers
extern doom_original_P_UnArchiveThinkers
extern doom_original_P_ArchiveSpecials
extern doom_original_P_UnArchiveSpecials

report_save_stream_pointer:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    mov esi, [ebp + 8]
    mov edi, [ebp + 12]
    mov ebx, 0xFFFFFFFF
    mov edx, 0x000000FF

    test edi, edi
    jz .have_pointer_detail

    movzx edx, byte [edi]
    mov eax, [savebuffer]
    test eax, eax
    jz .have_pointer_detail
    mov ebx, edi
    sub ebx, eax

.have_pointer_detail:
    mov eax, edx
    shl eax, 24

    mov ecx, ebx
    and ecx, 3
    shl ecx, 16
    or eax, ecx

    mov ecx, [save_p]
    and ecx, 0xFF
    shl ecx, 8
    or eax, ecx

    mov ecx, [savebuffer]
    and ecx, 0xFF
    or eax, ecx
    mov edi, eax

    mov eax, esi
    and eax, 0xFF
    shl eax, VIBE_DOOM_SAVEACTION_GAMEACTION_SHIFT
    or eax, VIBE_DOOM_SAVEACTION_STATUS | VIBE_DOOM_SAVEACTION_STREAM

    mov ecx, [savegameslot]
    and ecx, 0xFF
    shl ecx, VIBE_DOOM_SAVEACTION_SLOT_SHIFT
    or eax, ecx

    push edi
    push ebx
    push eax
    push dword VIBE_SYS_GAMEPLAY_STATUS
    call vibe_syscall3
    add esp, 16

    pop edi
    pop esi
    pop ebx
    leave
    ret

report_save_stream_stage:
    push dword [save_p]
    push dword [esp + 8]
    call report_save_stream_pointer
    add esp, 8
    ret

enter_save_stream_stage:
    mov eax, [esp + 4]
    mov [active_save_stream_stage], eax
    push eax
    call report_save_stream_stage
    add esp, 4
    ret

leave_save_stream_stage:
    push dword [esp + 4]
    call report_save_stream_stage
    add esp, 4
    mov dword [active_save_stream_stage], 0
    ret

vibe_doom_save_stream_note_error:
    push ebp
    mov ebp, esp
    push ebx

    mov eax, [active_save_stream_stage]
    test eax, eax
    jz .done
    mov ebx, [save_p]
    test ebx, ebx
    jz .done

    cmp eax, VIBE_SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE
    je .maybe_previous_byte
    cmp eax, VIBE_SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE
    jne .report

.maybe_previous_byte:
    mov edx, [savebuffer]
    test edx, edx
    jz .report
    cmp ebx, edx
    jbe .report
    dec ebx

.report:
    push ebx
    push eax
    call report_save_stream_pointer
    add esp, 8

.done:
    pop ebx
    leave
    ret

%macro WRAP_SAVE_STAGE 3
%1:
    push ebp
    mov ebp, esp

    push dword %2
    call enter_save_stream_stage
    add esp, 4

    call %3

    push dword %2 + 1
    call leave_save_stream_stage
    add esp, 4

    leave
    ret
%endmacro

WRAP_SAVE_STAGE P_ArchivePlayers, VIBE_SAVE_STAGE_ARCHIVE_PLAYERS_BEFORE, doom_original_P_ArchivePlayers
WRAP_SAVE_STAGE P_UnArchivePlayers, VIBE_SAVE_STAGE_UNARCHIVE_PLAYERS_BEFORE, doom_original_P_UnArchivePlayers
WRAP_SAVE_STAGE P_ArchiveWorld, VIBE_SAVE_STAGE_ARCHIVE_WORLD_BEFORE, doom_original_P_ArchiveWorld
WRAP_SAVE_STAGE P_UnArchiveWorld, VIBE_SAVE_STAGE_UNARCHIVE_WORLD_BEFORE, doom_original_P_UnArchiveWorld
WRAP_SAVE_STAGE P_ArchiveThinkers, VIBE_SAVE_STAGE_ARCHIVE_THINKERS_BEFORE, doom_original_P_ArchiveThinkers
WRAP_SAVE_STAGE P_UnArchiveThinkers, VIBE_SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE, doom_original_P_UnArchiveThinkers
WRAP_SAVE_STAGE P_ArchiveSpecials, VIBE_SAVE_STAGE_ARCHIVE_SPECIALS_BEFORE, doom_original_P_ArchiveSpecials
WRAP_SAVE_STAGE P_UnArchiveSpecials, VIBE_SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE, doom_original_P_UnArchiveSpecials

section .bss

active_save_stream_stage resd 1
