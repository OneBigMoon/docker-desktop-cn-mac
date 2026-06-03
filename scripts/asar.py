#!/usr/bin/env python3
import json
import os
import shutil
import stat
import struct
import sys
from pathlib import Path


def usage():
    print("Usage: asar.py extract <app.asar> <out-dir>", file=sys.stderr)
    print("       asar.py pack <in-dir> <app.asar>", file=sys.stderr)
    raise SystemExit(2)


def align4(size):
    return (size + 3) & ~3


def make_pickle_with_string(text):
    data = text.encode("utf-8") + b"\0"
    payload = struct.pack("<I", len(data)) + data
    payload += b"\0" * (align4(len(payload)) - len(payload))
    return struct.pack("<I", len(payload)) + payload


def read_header(asar_path):
    with open(asar_path, "rb") as f:
        size_pickle = f.read(8)
        if len(size_pickle) != 8:
            raise RuntimeError("Invalid ASAR: missing size pickle")
        header_size = struct.unpack("<I", size_pickle[4:8])[0]
        header_buf = f.read(header_size)
        if len(header_buf) != header_size:
            raise RuntimeError("Invalid ASAR: incomplete header")
        if len(header_buf) < 8:
            raise RuntimeError("Invalid ASAR: header too small")
        string_size = struct.unpack("<I", header_buf[4:8])[0]
        raw = header_buf[8:8 + string_size]
        if raw.endswith(b"\0"):
            raw = raw[:-1]
        header = json.loads(raw.decode("utf-8"))
        return header, 8 + header_size


def copy_range(src, dst, offset, size):
    src.seek(offset)
    remaining = size
    while remaining:
        chunk = src.read(min(1024 * 1024, remaining))
        if not chunk:
            raise RuntimeError("Unexpected EOF while extracting ASAR file data")
        dst.write(chunk)
        remaining -= len(chunk)


def extract_entry(asar_path, asar_file, data_offset, entry, out_path, rel_path):
    if "files" in entry:
        out_path.mkdir(parents=True, exist_ok=True)
        for name, child in entry.get("files", {}).items():
            extract_entry(asar_path, asar_file, data_offset, child, out_path / name, rel_path / name)
        return

    out_path.parent.mkdir(parents=True, exist_ok=True)

    if "link" in entry:
        try:
            if out_path.exists() or out_path.is_symlink():
                out_path.unlink()
            os.symlink(entry["link"], out_path)
        except OSError:
            # Fall back to a small text file so extraction can continue on filesystems
            # that do not allow symlinks.
            out_path.write_text(entry["link"], encoding="utf-8")
        return

    size = int(entry.get("size", 0))
    if entry.get("unpacked"):
        unpacked_root = asar_path.with_name(asar_path.name + ".unpacked")
        unpacked_file = unpacked_root / rel_path
        if unpacked_file.exists():
            shutil.copy2(unpacked_file, out_path)
        else:
            out_path.write_bytes(b"")
    else:
        offset = int(entry.get("offset", 0))
        with open(out_path, "wb") as dst:
            copy_range(asar_file, dst, data_offset + offset, size)

    if entry.get("executable"):
        mode = out_path.stat().st_mode
        out_path.chmod(mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def extract(asar_path, out_dir):
    asar_path = Path(asar_path)
    out_dir = Path(out_dir)
    if out_dir.exists():
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    header, data_offset = read_header(asar_path)
    with open(asar_path, "rb") as asar_file:
        root = {"files": header.get("files", {})}
        extract_entry(asar_path, asar_file, data_offset, root, out_dir, Path(""))


def add_path(root, rel_parts, entry):
    current = root.setdefault("files", {})
    for part in rel_parts[:-1]:
        node = current.setdefault(part, {"files": {}})
        current = node.setdefault("files", {})
    current[rel_parts[-1]] = entry


def build_header_and_file_list(in_dir):
    in_dir = Path(in_dir)
    root = {"files": {}}
    file_records = []
    offset = 0

    for current_dir, dirnames, filenames in os.walk(in_dir, followlinks=False):
        current = Path(current_dir)
        dirnames[:] = sorted([name for name in dirnames if name != "__MACOSX"])
        filenames = sorted([name for name in filenames if name != ".DS_Store"])

        rel_dir = current.relative_to(in_dir)
        if rel_dir != Path("."):
            parts = rel_dir.parts
            node = root.setdefault("files", {})
            for part in parts:
                node = node.setdefault(part, {"files": {}}).setdefault("files", {})

        for name in filenames:
            abs_path = current / name
            rel_path = abs_path.relative_to(in_dir)
            parts = rel_path.parts

            if abs_path.is_symlink():
                add_path(root, parts, {"link": os.readlink(abs_path)})
                continue

            size = abs_path.stat().st_size
            entry = {"size": size, "offset": str(offset)}
            if os.access(abs_path, os.X_OK):
                entry["executable"] = True
            add_path(root, parts, entry)
            file_records.append((abs_path, size))
            offset += size

    return root, file_records


def write_asar(out_path, header, file_records):
    header_json = json.dumps(header, ensure_ascii=False, separators=(",", ":"))
    header_pickle = make_pickle_with_string(header_json)
    size_pickle = struct.pack("<II", 4, len(header_pickle))

    with open(out_path, "wb") as out:
        out.write(size_pickle)
        out.write(header_pickle)
        for abs_path, _size in file_records:
            with open(abs_path, "rb") as src:
                shutil.copyfileobj(src, out, length=1024 * 1024)


def pack(in_dir, out_path):
    header, file_records = build_header_and_file_list(in_dir)
    write_asar(out_path, header, file_records)


def main(argv):
    if len(argv) != 4:
        usage()
    command, source, target = argv[1], argv[2], argv[3]
    if command == "extract":
        extract(source, target)
    elif command == "pack":
        pack(source, target)
    else:
        usage()


if __name__ == "__main__":
    main(sys.argv)
