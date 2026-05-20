#!/usr/bin/env python3
import argparse
import struct
from pathlib import Path


SECTOR_SIZE = 512
IMAGE_SECTORS = 65536
STAGE2_LBA = 1
STAGE2_SECTORS = 16
KERNEL_LBA = 17
KERNEL_SECTORS = 192
PARTITION_START = 2048
PARTITION_SECTORS = IMAGE_SECTORS - PARTITION_START
RESERVED_SECTORS = 1
FAT_COUNT = 2
ROOT_ENTRIES = 512
ROOT_DIR_SECTORS = (ROOT_ENTRIES * 32 + SECTOR_SIZE - 1) // SECTOR_SIZE
SECTORS_PER_CLUSTER = 1
SECTORS_PER_FAT = 256
FAT16_EOC = 0xFFF8
FAT16_EOC_VALUE = 0xFFFF
FAT_ATTR_READ_ONLY = 0x01
FAT_ATTR_VOLUME_ID = 0x08
FAT_ATTR_DIRECTORY = 0x10
FAT_ATTR_ARCHIVE = 0x20
FAT_ATTR_LONG_NAME = 0x0F
FIXTURE_WAD_SIZE = 1024 * 1024
MAX_KERNEL_WAD_BYTES = 0x00500000
DOOM_WAD_CLUSTER = 2
USER_PROBE_NAME = b"USERPROBELF"
DOOM_ELF_NAME = b"DOOM    ELF"
WRITABLE_DEFAULT_NAME = b"DEFAULT CFG"
PERSISTENCE_CHECKPOINT_NAME = b"PERSIST CHK"
WRITABLE_DEFAULT_BYTES = 16 * 1024
WRITABLE_SAVE_BYTES = 256 * 1024
WRITABLE_SAVE_NAMES = tuple(f"DOOMSAV{i}DSG".encode("ascii") for i in range(6))
WRITABLE_DYNAMIC_FILES = (
    (WRITABLE_DEFAULT_NAME, WRITABLE_DEFAULT_BYTES),
    *((name, WRITABLE_SAVE_BYTES) for name in WRITABLE_SAVE_NAMES),
)
MIN_OS_CREATED_FILE_CLUSTERS = 4096
PROTECTED_ROOT_NAMES = (b"DOOM1   WAD", USER_PROBE_NAME, DOOM_ELF_NAME)
DYNAMIC_FAT_PROOF_NAME = b"FATPROOFTMP"
SYNTHETIC_PATCH_NAME = "SYNTHPCH"
SHAREWARE_SWITCH_TEXTURES = (
    "SW1BRCOM", "SW2BRCOM",
    "SW1BRN1", "SW2BRN1",
    "SW1BRN2", "SW2BRN2",
    "SW1BRNGN", "SW2BRNGN",
    "SW1BROWN", "SW2BROWN",
    "SW1COMM", "SW2COMM",
    "SW1COMP", "SW2COMP",
    "SW1DIRT", "SW2DIRT",
    "SW1EXIT", "SW2EXIT",
    "SW1GRAY", "SW2GRAY",
    "SW1GRAY1", "SW2GRAY1",
    "SW1METAL", "SW2METAL",
    "SW1PIPE", "SW2PIPE",
    "SW1SLAD", "SW2SLAD",
    "SW1STARG", "SW2STARG",
    "SW1STON1", "SW2STON1",
    "SW1STON2", "SW2STON2",
    "SW1STONE", "SW2STONE",
    "SW1STRTN", "SW2STRTN",
)


def sector_offset(lba):
    return lba * SECTOR_SIZE


def write_le16(buf, offset, value):
    struct.pack_into("<H", buf, offset, value)


def write_le32(buf, offset, value):
    struct.pack_into("<I", buf, offset, value)


def read_le32(buf, offset):
    return struct.unpack_from("<I", buf, offset)[0]


def read_le16(buf, offset):
    return struct.unpack_from("<H", buf, offset)[0]


def cluster_size():
    return SECTORS_PER_CLUSTER * SECTOR_SIZE


def clusters_for_size(size):
    return max(1, (size + cluster_size() - 1) // cluster_size())


def data_cluster_count():
    metadata_sectors = RESERVED_SECTORS + FAT_COUNT * SECTORS_PER_FAT + ROOT_DIR_SECTORS
    data_sectors = PARTITION_SECTORS - metadata_sectors
    return data_sectors // SECTORS_PER_CLUSTER


def last_data_cluster():
    return data_cluster_count() + 1


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
    root[offset:offset + 32] = b"\0" * 32
    root[offset:offset + 11] = name
    root[offset + 11] = FAT_ATTR_ARCHIVE
    write_le16(root, offset + 26, first_cluster)
    write_le32(root, offset + 28, size)


def allocate_cluster_chain(fat_entries, clusters_needed):
    if clusters_needed <= 0:
        return ()

    chain = []
    for cluster in range(2, last_data_cluster() + 1):
        if cluster < len(fat_entries) and fat_entries[cluster] == 0:
            chain.append(cluster)
            if len(chain) == clusters_needed:
                break
    if len(chain) != clusters_needed:
        raise ValueError("file does not fit in the FAT16 data area")

    for index, cluster in enumerate(chain):
        fat_entries[cluster] = FAT16_EOC_VALUE if index == len(chain) - 1 else chain[index + 1]
    return tuple(chain)


def free_cluster_chain(fat_entries, first_cluster):
    freed = []
    cluster = first_cluster
    seen = set()
    while 2 <= cluster < FAT16_EOC:
        if cluster > last_data_cluster() or cluster >= len(fat_entries):
            raise ValueError("FAT16 chain points outside the data area")
        if cluster in seen:
            raise ValueError("FAT16 chain contains a loop")
        seen.add(cluster)
        next_cluster = fat_entries[cluster]
        if next_cluster == 0:
            raise ValueError("FAT16 chain points at a free cluster")
        fat_entries[cluster] = 0
        freed.append(cluster)
        cluster = next_cluster
        if len(freed) > data_cluster_count():
            raise ValueError("FAT16 chain did not terminate")
    return tuple(freed)


def write_cluster_chain(image, fat_entries, data_start, data):
    chain = allocate_cluster_chain(fat_entries, clusters_for_size(len(data)))
    remaining = memoryview(data)
    for cluster in chain:
        lba = data_start + (cluster - 2) * SECTORS_PER_CLUSTER
        start = sector_offset(lba)
        chunk = remaining[:cluster_size()]
        image[start:start + len(chunk)] = chunk
        remaining = remaining[len(chunk):]
    return chain[0], len(chain)


def zero_cluster_chain(image, data_start, chain):
    for cluster in chain:
        lba = data_start + (cluster - 2) * SECTORS_PER_CLUSTER
        start = sector_offset(lba)
        image[start:start + cluster_size()] = bytes(cluster_size())


def assert_free_cluster_budget(fat_entries):
    free_clusters = 0
    for cluster in range(2, last_data_cluster() + 1):
        if fat_entries[cluster] == 0:
            free_clusters += 1
    if free_clusters < MIN_OS_CREATED_FILE_CLUSTERS:
        raise ValueError(
            "FAT16 image leaves only "
            f"{free_clusters} free clusters, below the OS-created file budget "
            f"of {MIN_OS_CREATED_FILE_CLUSTERS}"
        )


class Fat16Image:
    """Small FAT16 mutator used by tests and by future tooling."""

    def __init__(self, image):
        self.image = image
        self.partition_lba = read_le32(image, 446 + 8)
        boot = self.partition_lba * SECTOR_SIZE
        self.reserved = read_le16(image, boot + 14)
        self.fat_count = image[boot + 16]
        self.root_entries = read_le16(image, boot + 17)
        self.sectors_per_fat = read_le16(image, boot + 22)
        self.root_lba = self.partition_lba + self.reserved + self.fat_count * self.sectors_per_fat
        self.root_size = self.root_entries * 32
        self.data_lba = self.root_lba + ((self.root_size + SECTOR_SIZE - 1) // SECTOR_SIZE)

    @staticmethod
    def validate_root_83_name(name, *, allow_protected=False):
        if not isinstance(name, (bytes, bytearray)) or len(name) != 11:
            raise ValueError("FAT16 root name must be an 11-byte 8.3 name")
        if not allow_protected and bytes(name) in PROTECTED_ROOT_NAMES:
            raise ValueError("protected WAD/ELF root entries are read-only")
        base = bytes(name[:8])
        ext = bytes(name[8:])
        if base[0:1] == b" " or b" " in base.rstrip(b" "):
            raise ValueError("FAT16 8.3 base name must be left-aligned and non-empty")
        if b" " in ext.rstrip(b" "):
            raise ValueError("FAT16 8.3 extension must be left-aligned")
        allowed = b"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_- "
        if any(ch not in allowed for ch in name):
            raise ValueError("FAT16 root name contains unsupported characters")
        return bytes(name)

    @staticmethod
    def _entry_label(name):
        base = bytes(name[:8]).decode("ascii", "replace").rstrip()
        ext = bytes(name[8:]).decode("ascii", "replace").rstrip()
        return f"{base}.{ext}" if ext else base

    @staticmethod
    def _path_label(path):
        return "/" + "/".join(Fat16Image._entry_label(name) for name in path)

    def fat_entry(self, cluster):
        if cluster < 0 or cluster * 2 + 1 >= self.sectors_per_fat * SECTOR_SIZE:
            raise ValueError("FAT16 cluster index is outside the FAT")
        fat_lba = self.partition_lba + self.reserved
        return read_le16(self.image, fat_lba * SECTOR_SIZE + cluster * 2)

    def validate_fat_copies_match(self):
        first_fat = (self.partition_lba + self.reserved) * SECTOR_SIZE
        fat_bytes = self.sectors_per_fat * SECTOR_SIZE
        reference = self.image[first_fat:first_fat + fat_bytes]
        for fat_index in range(1, self.fat_count):
            copy_start = first_fat + fat_index * fat_bytes
            copy = self.image[copy_start:copy_start + fat_bytes]
            if copy != reference:
                raise ValueError(f"FAT copy {fat_index} differs from FAT copy 0")

    def free_data_clusters(self):
        return sum(1 for cluster in range(2, last_data_cluster() + 1) if self.fat_entry(cluster) == 0)

    def set_fat_entry(self, cluster, value):
        for fat_index in range(self.fat_count):
            fat_lba = self.partition_lba + self.reserved + fat_index * self.sectors_per_fat
            write_le16(self.image, fat_lba * SECTOR_SIZE + cluster * 2, value)

    def root_entry_offset(self, name):
        name = self.validate_root_83_name(name, allow_protected=True)
        root_start = self.root_lba * SECTOR_SIZE
        for offset in range(0, self.root_size, 32):
            entry = root_start + offset
            first = self.image[entry]
            if first == 0:
                return None
            if first != 0xE5 and self.image[entry:entry + 11] == name:
                return entry
        return None

    def _directory_entry_offsets(self, first_cluster=None):
        if first_cluster is None:
            root_start = self.root_lba * SECTOR_SIZE
            for offset in range(0, self.root_size, 32):
                yield root_start + offset
            return

        for cluster in self.cluster_chain(first_cluster):
            start = self.cluster_offset(cluster)
            for offset in range(0, cluster_size(), 32):
                yield start + offset

    def _directory_entry_offset(self, first_cluster, name):
        name = self.validate_root_83_name(name, allow_protected=True)
        for entry in self._directory_entry_offsets(first_cluster):
            first = self.image[entry]
            if first == 0:
                return None
            if first != 0xE5 and self.image[entry:entry + 11] == name:
                return entry
        return None

    def _directory_free_entry_offset(self, first_cluster):
        for entry in self._directory_entry_offsets(first_cluster):
            if self.image[entry] in (0, 0xE5):
                return entry
        raise ValueError("FAT16 directory is full")

    def _write_directory_entry(self, entry, name, attr, first_cluster, size):
        self.image[entry:entry + 32] = b"\0" * 32
        self.image[entry:entry + 11] = name
        self.image[entry + 11] = attr
        write_le16(self.image, entry + 26, first_cluster)
        write_le32(self.image, entry + 28, size)

    def live_root_entries(self):
        entries = []
        for entry in self._directory_entry_offsets(None):
            first = self.image[entry]
            if first == 0:
                break
            if first == 0xE5:
                continue
            attr = self.image[entry + 11]
            if attr & 0x18:
                continue
            entries.append(
                {
                    "entry": entry,
                    "name": bytes(self.image[entry:entry + 11]),
                    "attr": attr,
                    "cluster": read_le16(self.image, entry + 26),
                    "size": read_le32(self.image, entry + 28),
                    "is_directory": bool(attr & FAT_ATTR_DIRECTORY),
                    "protected": bytes(self.image[entry:entry + 11]) in PROTECTED_ROOT_NAMES,
                }
            )
        return entries

    def list_root_directory(self):
        return self.list_directory(())

    def validate_allocated_clusters_reachable(self):
        owners = {}
        visited_dirs = set()

        def own_chain(first_cluster, label, *, size=0, is_directory=False):
            if first_cluster < 2:
                raise ValueError(f"FAT16 entry {label} has no data cluster")
            chain = self.cluster_chain(first_cluster)
            required = 1 if is_directory else clusters_for_size(size)
            if len(chain) < required:
                raise ValueError(f"FAT16 chain for {label} ended before the entry size")
            for cluster in chain:
                owner = owners.get(cluster)
                if owner is not None:
                    raise ValueError(
                        f"FAT16 cluster {cluster} is shared by {owner} and {label}"
                    )
                owners[cluster] = label
            return chain

        def validate_directory(first_cluster, path, parent_cluster=None):
            directory_id = 0 if first_cluster is None else first_cluster
            if directory_id in visited_dirs:
                raise ValueError(f"FAT16 directory {self._path_label(path) or '/'} loops through itself")
            visited_dirs.add(directory_id)

            names = set()
            for entry in self._directory_entry_offsets(first_cluster):
                first = self.image[entry]
                if first == 0:
                    break
                if first == 0xE5:
                    continue
                attr = self.image[entry + 11]
                if attr == FAT_ATTR_LONG_NAME or attr & FAT_ATTR_VOLUME_ID:
                    continue

                name = bytes(self.image[entry:entry + 11])
                label_path = path + (name,)
                label = self._path_label(label_path)
                if name in names:
                    raise ValueError(f"duplicate live FAT16 directory entry {label}")
                names.add(name)

                size = read_le32(self.image, entry + 28)
                child_cluster = read_le16(self.image, entry + 26)
                if attr & FAT_ATTR_DIRECTORY:
                    if name == b".          ":
                        if child_cluster != first_cluster:
                            raise ValueError(f"FAT16 . entry in {self._path_label(path)} points elsewhere")
                        continue
                    if name == b"..         ":
                        expected = parent_cluster or 0
                        if child_cluster != expected:
                            raise ValueError(f"FAT16 .. entry in {self._path_label(path)} points elsewhere")
                        continue
                    own_chain(child_cluster, label, is_directory=True)
                    validate_directory(child_cluster, label_path, first_cluster)
                    continue

                if size == 0:
                    if child_cluster != 0:
                        raise ValueError(f"zero-size FAT16 file {label} has a cluster chain")
                    continue
                own_chain(child_cluster, label, size=size)

        validate_directory(None, ())

        for cluster in range(2, last_data_cluster() + 1):
            if self.fat_entry(cluster) != 0 and cluster not in owners:
                raise ValueError(
                    f"allocated FAT16 cluster {cluster} is not reachable from any live root entry"
                )

    def create_or_reuse_root_entry(self, name):
        name = self.validate_root_83_name(name)
        root_start = self.root_lba * SECTOR_SIZE
        existing = self.root_entry_offset(name)
        if existing is not None:
            return existing
        for offset in range(0, self.root_size, 32):
            entry = root_start + offset
            if self.image[entry] in (0, 0xE5):
                self.image[entry:entry + 32] = b"\0" * 32
                self.image[entry:entry + 11] = name
                self.image[entry + 11] = FAT_ATTR_ARCHIVE
                return entry
        raise ValueError("FAT16 root directory is full")

    def allocate_clusters(self, count):
        chain = []
        for cluster in range(2, last_data_cluster() + 1):
            if self.fat_entry(cluster) == 0:
                chain.append(cluster)
                if len(chain) == count:
                    break
        if len(chain) != count:
            raise ValueError("file does not fit in the FAT16 data area")
        for index, cluster in enumerate(chain):
            self.set_fat_entry(cluster, FAT16_EOC_VALUE if index == len(chain) - 1 else chain[index + 1])
        zero_cluster_chain(self.image, self.data_lba, chain)
        return tuple(chain)

    def cluster_offset(self, cluster):
        if cluster < 2 or cluster > last_data_cluster():
            raise ValueError("FAT16 cluster index is outside the data area")
        return sector_offset(self.data_lba + (cluster - 2) * SECTORS_PER_CLUSTER)

    def cluster_chain(self, first_cluster):
        if first_cluster == 0:
            return ()
        if first_cluster < 2:
            raise ValueError("FAT16 chain starts before the data area")
        chain = []
        seen = set()
        cluster = first_cluster
        while 2 <= cluster < FAT16_EOC:
            if cluster > last_data_cluster():
                raise ValueError("FAT16 chain points outside the data area")
            if cluster in seen:
                raise ValueError("FAT16 chain contains a loop")
            seen.add(cluster)
            chain.append(cluster)
            next_cluster = self.fat_entry(cluster)
            if next_cluster == 0:
                raise ValueError("FAT16 chain points at a free cluster")
            cluster = next_cluster
            if len(chain) > data_cluster_count():
                raise ValueError("FAT16 chain did not terminate")
        return tuple(chain)

    def free_chain(self, first_cluster):
        freed = self.cluster_chain(first_cluster)
        for cluster in freed:
            self.set_fat_entry(cluster, 0)
        return freed

    def root_file_metadata(self, name):
        entry = self.root_entry_offset(name)
        if entry is None:
            return None
        return {
            "entry": entry,
            "name": bytes(self.image[entry:entry + 11]),
            "attr": self.image[entry + 11],
            "cluster": read_le16(self.image, entry + 26),
            "size": read_le32(self.image, entry + 28),
            "is_directory": bool(self.image[entry + 11] & FAT_ATTR_DIRECTORY),
            "protected": bytes(self.image[entry:entry + 11]) in PROTECTED_ROOT_NAMES,
        }

    def entry_metadata_at_path(self, path):
        path = tuple(self.validate_root_83_name(name, allow_protected=True) for name in path)
        if not path:
            return {
                "entry": None,
                "name": b"",
                "attr": FAT_ATTR_DIRECTORY,
                "cluster": 0,
                "size": self.root_size,
                "is_directory": True,
                "protected": True,
            }

        first_cluster = None
        entry = None
        for index, name in enumerate(path):
            entry = self._directory_entry_offset(first_cluster, name)
            if entry is None:
                return None
            attr = self.image[entry + 11]
            if index != len(path) - 1:
                if not (attr & FAT_ATTR_DIRECTORY):
                    return None
                first_cluster = read_le16(self.image, entry + 26)

        return {
            "entry": entry,
            "name": bytes(self.image[entry:entry + 11]),
            "attr": self.image[entry + 11],
            "cluster": read_le16(self.image, entry + 26),
            "size": read_le32(self.image, entry + 28),
            "is_directory": bool(self.image[entry + 11] & FAT_ATTR_DIRECTORY),
            "protected": bytes(self.image[entry:entry + 11]) in PROTECTED_ROOT_NAMES,
        }

    def list_directory(self, path=()):
        meta = self.entry_metadata_at_path(path)
        if meta is None or not meta["is_directory"]:
            raise FileNotFoundError(path)
        first_cluster = None if not path else meta["cluster"]
        entries = []
        for entry in self._directory_entry_offsets(first_cluster):
            first = self.image[entry]
            if first == 0:
                break
            if first == 0xE5:
                continue
            attr = self.image[entry + 11]
            if attr == FAT_ATTR_LONG_NAME or attr & FAT_ATTR_VOLUME_ID:
                continue
            entries.append(
                {
                    "entry": entry,
                    "name": bytes(self.image[entry:entry + 11]),
                    "attr": attr,
                    "cluster": read_le16(self.image, entry + 26),
                    "size": read_le32(self.image, entry + 28),
                    "is_directory": bool(attr & FAT_ATTR_DIRECTORY),
                    "protected": bytes(self.image[entry:entry + 11]) in PROTECTED_ROOT_NAMES,
                }
            )
        return tuple(entries)

    def read_root_file(self, name):
        meta = self.root_file_metadata(name)
        if meta is None:
            raise FileNotFoundError(name)
        if meta["is_directory"]:
            raise IsADirectoryError(name)
        return self._read_file_from_meta(meta)

    def _read_file_from_meta(self, meta):
        remaining = meta["size"]
        cluster = meta["cluster"]
        if remaining == 0:
            if cluster != 0:
                raise ValueError("zero-size FAT16 root file has a cluster chain")
            return b""
        chain = self.cluster_chain(cluster)
        if len(chain) < clusters_for_size(remaining):
            raise ValueError("FAT16 chain ended before the root file size")
        data = bytearray()
        for cluster in chain:
            chunk_size = min(remaining, cluster_size())
            start = self.cluster_offset(cluster)
            data.extend(self.image[start:start + chunk_size])
            remaining -= chunk_size
            if remaining == 0:
                break
        return bytes(data)

    def read_file_at_path(self, path):
        meta = self.entry_metadata_at_path(path)
        if meta is None:
            raise FileNotFoundError(path)
        if meta["is_directory"]:
            raise IsADirectoryError(path)
        return self._read_file_from_meta(meta)

    def write_root_file(self, name, data):
        entry = self.create_or_reuse_root_entry(name)
        if self.image[entry + 11] & FAT_ATTR_DIRECTORY:
            raise IsADirectoryError(name)
        first_cluster = read_le16(self.image, entry + 26)
        if first_cluster:
            self.free_chain(first_cluster)
        chain = self.allocate_clusters(clusters_for_size(len(data))) if data else ()
        for index, cluster in enumerate(chain):
            lba = self.data_lba + (cluster - 2) * SECTORS_PER_CLUSTER
            start = sector_offset(lba)
            chunk = data[index * cluster_size():(index + 1) * cluster_size()]
            self.image[start:start + len(chunk)] = chunk
        write_le16(self.image, entry + 26, chain[0] if chain else 0)
        write_le32(self.image, entry + 28, len(data))
        return chain

    def write_root_file_at(self, name, offset, data):
        name = self.validate_root_83_name(name)
        if offset < 0:
            raise ValueError("FAT16 write offset must be non-negative")
        current = self.read_root_file(name) if self.root_entry_offset(name) is not None else b""
        end = offset + len(data)
        if end < offset:
            raise ValueError("FAT16 write offset overflow")

        updated = bytearray(current)
        if len(updated) < offset:
            updated.extend(b"\0" * (offset - len(updated)))
        if len(updated) < end:
            updated.extend(b"\0" * (end - len(updated)))
        updated[offset:end] = data
        return self.write_root_file(name, bytes(updated))

    def resize_root_file(self, name, size):
        name = self.validate_root_83_name(name)
        if size < 0:
            raise ValueError("FAT16 root file size must be non-negative")
        entry = self.root_entry_offset(name)
        if entry is None:
            return self.write_root_file(name, b"\0" * size)

        meta = self.root_file_metadata(name)
        if meta["size"] < size:
            current = self.read_root_file(name)
            return self.write_root_file(name, current + b"\0" * (size - len(current)))
        if meta["size"] == size:
            return self.cluster_chain(meta["cluster"])
        if size == 0:
            return self.truncate_root_file(name)

        chain = self.cluster_chain(meta["cluster"])
        keep_count = clusters_for_size(size)
        kept = chain[:keep_count]
        freed = chain[keep_count:]
        self.set_fat_entry(kept[-1], FAT16_EOC_VALUE)
        for cluster in freed:
            self.set_fat_entry(cluster, 0)

        last_cluster_used = size % cluster_size()
        if last_cluster_used:
            last_start = self.cluster_offset(kept[-1])
            clear_start = last_start + last_cluster_used
            self.image[clear_start:last_start + cluster_size()] = bytes(cluster_size() - last_cluster_used)
        write_le32(self.image, entry + 28, size)
        return kept

    def truncate_root_file(self, name):
        entry = self.create_or_reuse_root_entry(name)
        if self.image[entry + 11] & FAT_ATTR_DIRECTORY:
            raise IsADirectoryError(name)
        first_cluster = read_le16(self.image, entry + 26)
        freed = self.free_chain(first_cluster) if first_cluster else ()
        write_le16(self.image, entry + 26, 0)
        write_le32(self.image, entry + 28, 0)
        return freed

    def delete_root_file(self, name):
        name = self.validate_root_83_name(name)
        entry = self.root_entry_offset(name)
        if entry is None:
            raise FileNotFoundError(name)
        if self.image[entry + 11] & FAT_ATTR_DIRECTORY:
            raise IsADirectoryError(name)
        first_cluster = read_le16(self.image, entry + 26)
        freed = self.free_chain(first_cluster) if first_cluster else ()
        self.image[entry] = 0xE5
        write_le16(self.image, entry + 26, 0)
        write_le32(self.image, entry + 28, 0)
        return freed

    def create_subdirectory(self, name):
        name = self.validate_root_83_name(name)
        entry = self.root_entry_offset(name)
        if entry is not None:
            if not (self.image[entry + 11] & FAT_ATTR_DIRECTORY):
                raise FileExistsError(name)
            return read_le16(self.image, entry + 26)

        entry = self.create_or_reuse_root_entry(name)
        chain = self.allocate_clusters(1)
        cluster = chain[0]
        self._write_directory_entry(entry, name, FAT_ATTR_DIRECTORY, cluster, 0)

        directory_start = self.cluster_offset(cluster)
        self._write_directory_entry(directory_start, b".          ", FAT_ATTR_DIRECTORY, cluster, 0)
        self._write_directory_entry(directory_start + 32, b"..         ", FAT_ATTR_DIRECTORY, 0, 0)
        return cluster

    def write_directory_file(self, directory_name, file_name, data):
        directory_name = self.validate_root_83_name(directory_name)
        file_name = self.validate_root_83_name(file_name)
        directory_meta = self.root_file_metadata(directory_name)
        if directory_meta is None or not directory_meta["is_directory"]:
            raise FileNotFoundError(directory_name)

        entry = self._directory_entry_offset(directory_meta["cluster"], file_name)
        if entry is None:
            entry = self._directory_free_entry_offset(directory_meta["cluster"])
            self._write_directory_entry(entry, file_name, FAT_ATTR_ARCHIVE, 0, 0)
        if self.image[entry + 11] & FAT_ATTR_DIRECTORY:
            raise IsADirectoryError(file_name)

        first_cluster = read_le16(self.image, entry + 26)
        if first_cluster:
            self.free_chain(first_cluster)
        chain = self.allocate_clusters(clusters_for_size(len(data))) if data else ()
        for index, cluster in enumerate(chain):
            start = self.cluster_offset(cluster)
            chunk = data[index * cluster_size():(index + 1) * cluster_size()]
            self.image[start:start + len(chunk)] = chunk
        self._write_directory_entry(entry, file_name, FAT_ATTR_ARCHIVE, chain[0] if chain else 0, len(data))
        return chain


def prove_dynamic_fat16_mutation(fs, proof_name=DYNAMIC_FAT_PROOF_NAME):
    """Exercise dynamic root-file FAT allocation on an in-memory image copy.

    The checker uses this as a host-side proof that the image still has enough
    root-directory and FAT headroom for create, sparse extend, shrink,
    truncate, delete, and root-slot reuse. It intentionally mutates only the
    caller-provided Fat16Image instance, so pass a copy when validating an
    artifact that should remain unchanged.
    """

    proof_name = Fat16Image.validate_root_83_name(proof_name)
    if fs.root_file_metadata(proof_name) is not None:
        raise ValueError("dynamic FAT proof scratch file already exists")

    def remount_and_validate():
        mounted = Fat16Image(fs.image)
        mounted.validate_fat_copies_match()
        mounted.validate_allocated_clusters_reachable()
        return mounted

    fs.validate_fat_copies_match()
    fs.validate_allocated_clusters_reachable()
    before_free = fs.free_data_clusters()
    if before_free < 8:
        raise ValueError("not enough free clusters for dynamic FAT proof")

    cluster_bytes = cluster_size()
    payload = b"A" * (cluster_bytes + 29)
    first_chain = fs.write_root_file(proof_name, payload)
    if len(first_chain) != clusters_for_size(len(payload)):
        raise ValueError("dynamic FAT proof initial allocation used an unexpected cluster count")
    first_entry = fs.root_entry_offset(proof_name)
    first_meta = fs.root_file_metadata(proof_name)
    if first_meta is None or first_meta["cluster"] != first_chain[0]:
        raise ValueError("dynamic FAT proof root entry did not record the first cluster")
    if first_meta["size"] != len(payload) or fs.read_root_file(proof_name) != payload:
        raise ValueError("dynamic FAT proof initial write did not round-trip")
    if fs.free_data_clusters() != before_free - len(first_chain):
        raise ValueError("dynamic FAT proof initial allocation did not consume the expected clusters")
    remounted = remount_and_validate()
    remounted_meta = remounted.root_file_metadata(proof_name)
    if remounted_meta is None or remounted_meta["cluster"] != first_chain[0]:
        raise ValueError("dynamic FAT proof initial write did not survive remount metadata")
    if remounted.read_root_file(proof_name) != payload:
        raise ValueError("dynamic FAT proof initial write did not survive remount readback")

    sparse_offset = cluster_bytes * 3 + 17
    grown_chain = fs.write_root_file_at(proof_name, sparse_offset, b"END")
    grown = fs.read_root_file(proof_name)
    if len(grown) != sparse_offset + 3:
        raise ValueError("dynamic FAT proof sparse write produced the wrong size")
    if grown[:len(payload)] != payload:
        raise ValueError("dynamic FAT proof sparse write did not preserve existing bytes")
    if grown[len(payload):sparse_offset] != b"\0" * (sparse_offset - len(payload)):
        raise ValueError("dynamic FAT proof sparse write gap was not zero-filled")
    if grown[sparse_offset:] != b"END":
        raise ValueError("dynamic FAT proof sparse write tail did not round-trip")
    if len(grown_chain) <= len(first_chain):
        raise ValueError("dynamic FAT proof sparse write did not grow the FAT chain")
    if fs.free_data_clusters() != before_free - len(grown_chain):
        raise ValueError("dynamic FAT proof sparse growth did not consume the expected clusters")
    remounted = remount_and_validate()
    if remounted.root_file_metadata(proof_name)["size"] != len(grown):
        raise ValueError("dynamic FAT proof sparse write did not survive remount size")
    if remounted.read_root_file(proof_name) != grown:
        raise ValueError("dynamic FAT proof sparse write did not survive remount readback")

    shrunk_size = cluster_bytes + 1
    shrunk_chain = fs.resize_root_file(proof_name, shrunk_size)
    shrunk = fs.read_root_file(proof_name)
    if len(shrunk) != shrunk_size or shrunk != payload[:shrunk_size]:
        raise ValueError("dynamic FAT proof shrink did not preserve the expected prefix")
    if len(shrunk_chain) >= len(grown_chain):
        raise ValueError("dynamic FAT proof shrink did not free tail clusters")
    if fs.fat_entry(shrunk_chain[-1]) != FAT16_EOC_VALUE:
        raise ValueError("dynamic FAT proof shrink did not terminate the kept chain")
    for cluster in grown_chain[len(shrunk_chain):]:
        if fs.fat_entry(cluster) != 0:
            raise ValueError("dynamic FAT proof shrink left a freed cluster allocated")
    clear_start = fs.cluster_offset(shrunk_chain[-1]) + 1
    clear_end = fs.cluster_offset(shrunk_chain[-1]) + cluster_bytes
    if fs.image[clear_start:clear_end] != b"\0" * (cluster_bytes - 1):
        raise ValueError("dynamic FAT proof shrink did not zero the truncated tail bytes")
    remounted = remount_and_validate()
    if remounted.cluster_chain(remounted.root_file_metadata(proof_name)["cluster"]) != shrunk_chain:
        raise ValueError("dynamic FAT proof shrink did not survive remount chain")
    if remounted.read_root_file(proof_name) != shrunk:
        raise ValueError("dynamic FAT proof shrink did not survive remount readback")

    truncated = fs.truncate_root_file(proof_name)
    if truncated != shrunk_chain:
        raise ValueError("dynamic FAT proof truncate did not free the current chain")
    truncated_meta = fs.root_file_metadata(proof_name)
    if truncated_meta is None or truncated_meta["cluster"] != 0 or truncated_meta["size"] != 0:
        raise ValueError("dynamic FAT proof truncate did not reset root metadata")
    if fs.read_root_file(proof_name) != b"":
        raise ValueError("dynamic FAT proof truncate did not leave an empty file")
    if fs.free_data_clusters() != before_free:
        raise ValueError("dynamic FAT proof truncate did not restore the free-cluster budget")
    remounted = remount_and_validate()
    remounted_meta = remounted.root_file_metadata(proof_name)
    if remounted_meta is None or remounted_meta["cluster"] != 0 or remounted_meta["size"] != 0:
        raise ValueError("dynamic FAT proof truncate did not survive remount metadata")
    if remounted.read_root_file(proof_name) != b"":
        raise ValueError("dynamic FAT proof truncate did not survive remount readback")

    replacement = b"recreated after truncate\n"
    replacement_chain = fs.write_root_file(proof_name, replacement)
    if fs.root_entry_offset(proof_name) != first_entry:
        raise ValueError("dynamic FAT proof rewrite did not reuse the same live root entry")
    if fs.read_root_file(proof_name) != replacement:
        raise ValueError("dynamic FAT proof rewrite did not round-trip")
    remounted = remount_and_validate()
    if remounted.root_file_metadata(proof_name)["entry"] != first_entry:
        raise ValueError("dynamic FAT proof rewrite did not survive remount root-slot reuse")
    if remounted.read_root_file(proof_name) != replacement:
        raise ValueError("dynamic FAT proof rewrite did not survive remount readback")
    deleted = fs.delete_root_file(proof_name)
    if deleted != replacement_chain:
        raise ValueError("dynamic FAT proof delete did not free the replacement chain")
    if fs.root_file_metadata(proof_name) is not None:
        raise ValueError("dynamic FAT proof delete left a live root entry")
    if fs.free_data_clusters() != before_free:
        raise ValueError("dynamic FAT proof delete did not restore the free-cluster budget")
    remounted = remount_and_validate()
    if remounted.root_file_metadata(proof_name) is not None:
        raise ValueError("dynamic FAT proof delete did not survive remount")
    reused_entry = fs.create_or_reuse_root_entry(proof_name)
    if reused_entry != first_entry:
        raise ValueError("dynamic FAT proof create did not reuse the deleted root slot")
    fs.truncate_root_file(proof_name)
    fs.delete_root_file(proof_name)

    fs.validate_fat_copies_match()
    fs.validate_allocated_clusters_reachable()
    return {
        "proof_name": Fat16Image._entry_label(proof_name),
        "initial_clusters": len(first_chain),
        "grown_clusters": len(grown_chain),
        "shrunk_clusters": len(shrunk_chain),
        "free_clusters": before_free,
        "remount_readback": True,
    }


def wad_name(name):
    raw = name.encode("ascii")
    if len(raw) > 8:
        raise ValueError(f"WAD lump name too long: {name}")
    return raw.ljust(8, b"\0")


def build_patch(pixel=0):
    patch = bytearray(18)
    write_le16(patch, 0, 1)
    write_le16(patch, 2, 1)
    write_le16(patch, 4, 0)
    write_le16(patch, 6, 0)
    write_le32(patch, 8, 12)
    patch[12:18] = bytes((0, 1, 0, pixel & 0xff, 0, 0xff))
    return bytes(patch)


def build_pnames(patch_names):
    data = bytearray(4 + len(patch_names) * 8)
    write_le32(data, 0, len(patch_names))
    for index, name in enumerate(patch_names):
        data[4 + index * 8:12 + index * 8] = wad_name(name)
    return bytes(data)


def build_texture1(texture_names, patch_index=0):
    directory_size = 4 + len(texture_names) * 4
    data = bytearray(directory_size)
    write_le32(data, 0, len(texture_names))

    for index, name in enumerate(texture_names):
        offset = len(data)
        write_le32(data, 4 + index * 4, offset)

        texture = bytearray(32)
        texture[0:8] = wad_name(name)
        write_le32(texture, 8, 0)
        write_le16(texture, 12, 1)
        write_le16(texture, 14, 1)
        write_le32(texture, 16, 0)
        write_le16(texture, 20, 1)
        write_le16(texture, 22, 0)
        write_le16(texture, 24, 0)
        write_le16(texture, 26, patch_index)
        write_le16(texture, 28, 0)
        write_le16(texture, 30, 0)
        data.extend(texture)

    return bytes(data)


def startup_patch_names():
    names = []
    names.extend(f"STCFN{code:03d}" for code in range(ord("!"), ord("_") + 1))
    names.extend(f"STTNUM{i}" for i in range(10))
    names.extend(f"STYSNUM{i}" for i in range(10))
    names.append("STTPRCNT")
    names.extend(f"STKEYS{i}" for i in range(6))
    names.append("STARMS")
    names.extend(f"STGNUM{i}" for i in range(2, 8))
    names.extend(("STFB0", "STBAR"))

    for pain in range(5):
        names.extend(f"STFST{pain}{straight}" for straight in range(3))
        names.extend((
            f"STFTR{pain}0",
            f"STFTL{pain}0",
            f"STFOUCH{pain}",
            f"STFEVL{pain}",
            f"STFKILL{pain}",
        ))
    names.extend(("STFGOD0", "STFDEAD0", "TITLEPIC", "CREDIT", "HELP2"))
    return tuple(dict.fromkeys(names))


def build_wad():
    wad = bytearray(FIXTURE_WAD_SIZE)
    patch = build_patch()
    lumps = [
        ("PLAYPAL", bytes((i % 64 for i in range(14 * 256 * 3)))),
        ("COLORMAP", bytes((i % 256 for i in range(34 * 256)))),
        ("PNAMES", build_pnames((SYNTHETIC_PATCH_NAME,))),
        ("TEXTURE1", build_texture1(SHAREWARE_SWITCH_TEXTURES)),
        ("F_START", b""),
        ("F_END", b""),
        ("S_START", b""),
        ("S_END", b""),
        (SYNTHETIC_PATCH_NAME, patch),
        ("D_INTRO", b""),
        ("E1M1", b""),
        ("THINGS", b"\0" * 10),
    ]
    lumps.extend((name, patch) for name in startup_patch_names())

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
    for offset in range(fill_start, FIXTURE_WAD_SIZE, len(pattern)):
        wad[offset:offset + len(pattern)] = pattern[: max(0, min(len(pattern), FIXTURE_WAD_SIZE - offset))]

    wad[0:4] = b"IWAD"
    return wad


def load_external_wad(path):
    wad = bytearray(Path(path).read_bytes())
    if len(wad) > MAX_KERNEL_WAD_BYTES:
        raise ValueError(
            f"{path} is {len(wad)} bytes, exceeds kernel WAD load limit "
            f"of {MAX_KERNEL_WAD_BYTES} bytes"
        )
    if len(wad) < 12:
        raise ValueError(f"{path} is too small to be a WAD")
    if wad[0:4] not in (b"IWAD", b"PWAD"):
        raise ValueError(f"{path} does not start with IWAD or PWAD")

    lump_count = read_le32(wad, 4)
    directory_offset = read_le32(wad, 8)
    directory_size = lump_count * 16
    if directory_offset + directory_size > len(wad):
        raise ValueError(f"{path} has a WAD directory outside the file")
    return wad


def parse_args():
    parser = argparse.ArgumentParser(
        description="Build a bootable vibe-os IDE/FAT16 disk image."
    )
    parser.add_argument(
        "--wad",
        metavar="PATH",
        help="use this external DOOM1.WAD/PWAD instead of the generated test fixture",
    )
    parser.add_argument("paths", nargs="+")
    args = parser.parse_args()

    if len(args.paths) not in (1, 4, 5, 6):
        parser.error("usage: make_wad_image.py [--wad PATH] OUTPUT [STAGE1 STAGE2 KERNEL [USER_ELF [DOOM_ELF]]]")
    return args


def main():
    args = parse_args()

    image = bytearray(IMAGE_SECTORS * SECTOR_SIZE)
    output_path = args.paths[0]
    boot_paths = args.paths[1:4] if len(args.paths) >= 4 else None
    user_elf_path = args.paths[4] if len(args.paths) >= 5 else None
    doom_elf_path = args.paths[5] if len(args.paths) == 6 else None

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

    wad = load_external_wad(args.wad) if args.wad else build_wad()
    wad_cluster, _wad_clusters = write_cluster_chain(image, fat_entries, data_start, wad)
    if wad_cluster != DOOM_WAD_CLUSTER:
        raise ValueError("DOOM1.WAD must start at cluster 2")
    write_root_entry(root, 0, b"DOOM1   WAD", wad_cluster, len(wad))
    next_root_index = 1

    if user_elf_path:
        with open(user_elf_path, "rb") as f:
            user_elf = f.read()
        user_cluster, _user_clusters = write_cluster_chain(image, fat_entries, data_start, user_elf)
        write_root_entry(root, next_root_index, USER_PROBE_NAME, user_cluster, len(user_elf))
        next_root_index += 1

        if doom_elf_path:
            with open(doom_elf_path, "rb") as f:
                doom_elf = f.read()
            doom_cluster, _doom_clusters = write_cluster_chain(image, fat_entries, data_start, doom_elf)
            write_root_entry(root, next_root_index, DOOM_ELF_NAME, doom_cluster, len(doom_elf))
            next_root_index += 1

    for name, _byte_capacity in WRITABLE_DYNAMIC_FILES:
        write_root_entry(root, next_root_index, name, 0, 0)
        next_root_index += 1

    assert_free_cluster_budget(fat_entries)

    fat_bytes = bytearray(SECTORS_PER_FAT * SECTOR_SIZE)
    for i, value in enumerate(fat_entries):
        struct.pack_into("<H", fat_bytes, i * 2, value)

    for fat_index in range(FAT_COUNT):
        start = sector_offset(fat_start + fat_index * SECTORS_PER_FAT)
        image[start:start + len(fat_bytes)] = fat_bytes

    with open(output_path, "wb") as f:
        f.write(image)


if __name__ == "__main__":
    try:
        main()
    except ValueError as exc:
        raise SystemExit(f"error: {exc}") from None
