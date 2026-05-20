#!/usr/bin/env python3
import struct
import sys


SECTOR_SIZE = 512
IMAGE_SECTORS = 65536
STAGE2_LBA = 1
STAGE2_SECTORS = 16
KERNEL_LBA = STAGE2_LBA + STAGE2_SECTORS
KERNEL_SECTORS = 96
PARTITION_START = 2048
PARTITION_SECTORS = IMAGE_SECTORS - PARTITION_START
RESERVED_SECTORS = 1
FAT_COUNT = 2
ROOT_ENTRIES = 512
ROOT_DIR_SECTORS = (ROOT_ENTRIES * 32 + SECTOR_SIZE - 1) // SECTOR_SIZE
SECTORS_PER_CLUSTER = 1
SECTORS_PER_FAT = 256
DOOM_WAD_SIZE = 1024 * 1024
DOOM_WAD_CLUSTER = 2
USER_PROBE_NAME = b"USERPROBELF"


def sector_offset(lba):
    return lba * SECTOR_SIZE


def write_le16(buf, offset, value):
    struct.pack_into("<H", buf, offset, value)


def write_le32(buf, offset, value):
    struct.pack_into("<I", buf, offset, value)


def write_padded_file(image, lba, sectors, path, label):
    with open(path, "rb") as f:
        data = f.read()

    capacity = sectors * SECTOR_SIZE
    if len(data) > capacity:
        raise ValueError(f"{label} is {len(data)} bytes, exceeds {capacity} bytes")

    start = sector_offset(lba)
    image[start:start + len(data)] = data


def write_root_entry(root, index, name, first_cluster, size):
    offset = index * 32
    root[offset:offset + 11] = name
    root[offset + 11] = 0x20
    write_le16(root, offset + 26, first_cluster)
    write_le32(root, offset + 28, size)


def write_cluster_chain(image, fat_entries, data_start, start_cluster, data):
    clusters_needed = (len(data) + SECTOR_SIZE - 1) // SECTOR_SIZE
    if clusters_needed == 0:
        clusters_needed = 1

    for i in range(clusters_needed):
        cluster = start_cluster + i
        fat_entries[cluster] = 0xFFFF if i == clusters_needed - 1 else cluster + 1

    lba = data_start + (start_cluster - 2) * SECTORS_PER_CLUSTER
    start = sector_offset(lba)
    image[start:start + len(data)] = data
    return clusters_needed


def wad_name(name):
    raw = name.encode("ascii")
    if len(raw) > 8:
        raise ValueError(f"WAD lump name too long: {name}")
    return raw.ljust(8, b"\0")


def build_wad():
    wad = bytearray(DOOM_WAD_SIZE)
    lumps = [
        ("PLAYPAL", bytes((i % 64 for i in range(14 * 256 * 3)))),
        ("COLORMAP", bytes((i % 256 for i in range(34 * 256)))),
        ("E1M1", b""),
        ("THINGS", b"\0" * 10),
    ]

    entries = []
    cursor = 12
    for name, data in lumps:
        filepos = cursor if data else 0
        wad[filepos:filepos + len(data)] = data
        entries.append((filepos, len(data), wad_name(name)))
        cursor += len(data)

    directory_offset = cursor
    for index, (filepos, size, name) in enumerate(entries):
        entry_offset = directory_offset + index * 16
        write_le32(wad, entry_offset, filepos)
        write_le32(wad, entry_offset + 4, size)
        wad[entry_offset + 8:entry_offset + 16] = name

    write_le32(wad, 4, len(entries))
    write_le32(wad, 8, directory_offset)

    pattern = b"Aurora hard-path IDE FAT16 WAD fixture\n"
    fill_start = directory_offset + len(entries) * 16
    for offset in range(fill_start, DOOM_WAD_SIZE, len(pattern)):
        wad[offset:offset + len(pattern)] = pattern[: max(0, min(len(pattern), DOOM_WAD_SIZE - offset))]

    wad[0:4] = b"IWAD"
    return wad


def main():
    if len(sys.argv) not in (2, 5, 6):
        raise SystemExit("usage: make_wad_image.py OUTPUT [STAGE1 STAGE2 KERNEL [USER_ELF]]")

    image = bytearray(IMAGE_SECTORS * SECTOR_SIZE)
    boot_paths = sys.argv[2:5] if len(sys.argv) >= 5 else None
    user_elf_path = sys.argv[5] if len(sys.argv) == 6 else None

    mbr = memoryview(image)[0:SECTOR_SIZE]
    if boot_paths:
        with open(boot_paths[0], "rb") as f:
            stage1 = f.read()
        if len(stage1) != SECTOR_SIZE:
            raise ValueError(f"stage1 must be exactly {SECTOR_SIZE} bytes")
        mbr[:] = stage1
        write_padded_file(image, STAGE2_LBA, STAGE2_SECTORS, boot_paths[1], "stage2")
        write_padded_file(image, KERNEL_LBA, KERNEL_SECTORS, boot_paths[2], "kernel")
    else:
        mbr[0:3] = b"\xeb\x3c\x90"

    mbr[440:444] = b"AOSD"
    entry = 446
    mbr[entry + 0] = 0x00
    mbr[entry + 1:entry + 4] = b"\x01\x01\x00"
    mbr[entry + 4] = 0x06
    mbr[entry + 5:entry + 8] = b"\xfe\xff\xff"
    write_le32(mbr, entry + 8, PARTITION_START)
    write_le32(mbr, entry + 12, PARTITION_SECTORS)
    write_le16(mbr, 510, 0xAA55)

    boot_lba = PARTITION_START
    boot = memoryview(image)[sector_offset(boot_lba):sector_offset(boot_lba + 1)]
    boot[0:3] = b"\xeb\x3c\x90"
    boot[3:11] = b"AURORA  "
    write_le16(boot, 11, SECTOR_SIZE)
    boot[13] = SECTORS_PER_CLUSTER
    write_le16(boot, 14, RESERVED_SECTORS)
    boot[16] = FAT_COUNT
    write_le16(boot, 17, ROOT_ENTRIES)
    write_le16(boot, 19, PARTITION_SECTORS if PARTITION_SECTORS < 65536 else 0)
    boot[21] = 0xF8
    write_le16(boot, 22, SECTORS_PER_FAT)
    write_le16(boot, 24, 63)
    write_le16(boot, 26, 16)
    write_le32(boot, 28, PARTITION_START)
    write_le32(boot, 32, PARTITION_SECTORS if PARTITION_SECTORS >= 65536 else 0)
    boot[36] = 0x80
    boot[38] = 0x29
    write_le32(boot, 39, 0xD00D0001)
    boot[43:54] = b"AURORA WAD "
    boot[54:62] = b"FAT16   "
    write_le16(boot, 510, 0xAA55)

    fat_start = PARTITION_START + RESERVED_SECTORS
    root_start = fat_start + FAT_COUNT * SECTORS_PER_FAT
    data_start = root_start + ROOT_DIR_SECTORS
    fat_entries = [0] * (SECTORS_PER_FAT * SECTOR_SIZE // 2)
    fat_entries[0] = 0xFFF8
    fat_entries[1] = 0xFFFF

    root = memoryview(image)[sector_offset(root_start):sector_offset(root_start + ROOT_DIR_SECTORS)]

    wad = build_wad()
    wad_clusters = write_cluster_chain(image, fat_entries, data_start, DOOM_WAD_CLUSTER, wad)
    write_root_entry(root, 0, b"DOOM1   WAD", DOOM_WAD_CLUSTER, len(wad))

    if user_elf_path:
        with open(user_elf_path, "rb") as f:
            user_elf = f.read()
        user_cluster = DOOM_WAD_CLUSTER + wad_clusters
        write_cluster_chain(image, fat_entries, data_start, user_cluster, user_elf)
        write_root_entry(root, 1, USER_PROBE_NAME, user_cluster, len(user_elf))

    fat_bytes = bytearray(SECTORS_PER_FAT * SECTOR_SIZE)
    for i, value in enumerate(fat_entries):
        struct.pack_into("<H", fat_bytes, i * 2, value)

    for fat_index in range(FAT_COUNT):
        start = sector_offset(fat_start + fat_index * SECTORS_PER_FAT)
        image[start:start + len(fat_bytes)] = fat_bytes

    with open(sys.argv[1], "wb") as f:
        f.write(image)


if __name__ == "__main__":
    main()
