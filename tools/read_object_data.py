#!/usr/bin/env python3
"""Read Warcraft III object data files (.w3u/.w3a) into inspectable JSON."""

from __future__ import annotations

import argparse
import json
import math
import re
import struct
import sys
from dataclasses import dataclass
from pathlib import Path


class ObjectDataError(RuntimeError):
    pass


@dataclass
class BinaryReader:
    data: bytes
    path: Path
    offset: int = 0

    def require(self, size: int, label: str) -> None:
        if size < 0 or self.offset + size > len(self.data):
            raise ObjectDataError(
                f"Unexpected EOF reading {label} at 0x{self.offset:X} "
                f"({size} bytes requested, {len(self.data) - self.offset} remain)"
            )

    def bytes(self, size: int, label: str) -> bytes:
        self.require(size, label)
        value = self.data[self.offset : self.offset + size]
        self.offset += size
        return value

    def u32(self, label: str) -> int:
        return struct.unpack("<I", self.bytes(4, label))[0]

    def i32(self, label: str) -> int:
        return struct.unpack("<i", self.bytes(4, label))[0]

    def f32(self, label: str) -> float:
        value = struct.unpack("<f", self.bytes(4, label))[0]
        if not math.isfinite(value):
            raise ObjectDataError(f"Non-finite float for {label} at 0x{self.offset - 4:X}")
        return value

    def c_string(self, label: str) -> tuple[str, str]:
        end = self.data.find(b"\0", self.offset)
        if end < 0:
            raise ObjectDataError(f"Unterminated string for {label} at 0x{self.offset:X}")
        raw = self.data[self.offset:end]
        self.offset = end + 1
        try:
            return raw.decode("utf-8"), "utf-8"
        except UnicodeDecodeError:
            return raw.decode("windows-1252"), "windows-1252"


def rawcode(raw: bytes) -> str | None:
    if raw == b"\0\0\0\0":
        return None
    try:
        return raw.decode("ascii")
    except UnicodeDecodeError:
        return raw.decode("latin-1")


def read_rawcode(reader: BinaryReader, label: str) -> tuple[str | None, str]:
    raw = reader.bytes(4, label)
    return rawcode(raw), raw.hex().upper()


def checked_count(reader: BinaryReader, label: str, maximum: int = 1_000_000) -> int:
    count = reader.u32(label)
    if count > maximum:
        raise ObjectDataError(f"Unreasonable {label}: {count} at 0x{reader.offset - 4:X}")
    return count


def read_modification(reader: BinaryReader, optional_ints: bool, version: int) -> dict:
    field_id, field_hex = read_rawcode(reader, "modification id")
    variable_type = reader.u32("variable type")
    if variable_type not in (0, 1, 2, 3):
        raise ObjectDataError(
            f"Unknown variable type {variable_type} for {field_id!r} at 0x{reader.offset - 4:X}"
        )

    modification: dict = {
        "field_id": field_id,
        "field_id_hex": field_hex,
        "type": ("integer", "real", "unreal", "string")[variable_type],
        "type_id": variable_type,
    }

    if optional_ints:
        modification["level"] = reader.u32("level/variation")
        modification["data_pointer"] = reader.u32("data pointer")

    if variable_type == 0:
        modification["value"] = reader.i32("integer value")
    elif variable_type in (1, 2):
        modification["value"] = reader.f32("float value")
    else:
        value, encoding = reader.c_string("string value")
        modification["value"] = value
        if encoding != "utf-8":
            modification["encoding"] = encoding

    if version > 0:
        end_token, end_hex = read_rawcode(reader, "end token")
        modification["end_token"] = end_token
        modification["end_token_hex"] = end_hex

    return modification


def read_object(reader: BinaryReader, optional_ints: bool, version: int, table_name: str) -> dict:
    original_id, original_hex = read_rawcode(reader, "original object id")
    modified_id, modified_hex = read_rawcode(reader, "modified object id")
    sets_count = checked_count(reader, "sets count", 10_000) if version >= 3 else 1

    sets: list[dict] = []
    for set_index in range(sets_count):
        item_set: dict = {"index": set_index}
        if version >= 3:
            item_set["flag"] = reader.u32("set flag")
        modifications_count = checked_count(reader, "modifications count")
        item_set["modifications"] = [
            read_modification(reader, optional_ints, version)
            for _ in range(modifications_count)
        ]
        sets.append(item_set)

    return {
        "table": table_name,
        "original_id": original_id,
        "original_id_hex": original_hex,
        "modified_id": modified_id,
        "modified_id_hex": modified_hex,
        "sets": sets,
    }


def read_table(reader: BinaryReader, optional_ints: bool, version: int, table_name: str) -> list[dict]:
    object_count = checked_count(reader, f"{table_name} object count")
    return [
        read_object(reader, optional_ints, version, table_name)
        for _ in range(object_count)
    ]


def parse_object_data(path: Path, kind: str) -> dict:
    data = path.read_bytes()
    reader = BinaryReader(data=data, path=path)
    version = reader.u32("format version")
    if version not in (1, 2, 3):
        raise ObjectDataError(f"Unsupported object data version {version}")

    optional_ints = kind == "abilities"
    tables: list[dict] = []
    for table_name in ("original", "custom"):
        if reader.offset == len(data):
            break
        objects = read_table(reader, optional_ints, version, table_name)
        tables.append({"name": table_name, "objects": objects})

    if reader.offset != len(data):
        raise ObjectDataError(
            f"Parser stopped at 0x{reader.offset:X}; {len(data) - reader.offset} unread bytes remain"
        )
    if not tables:
        raise ObjectDataError("Object data contains no tables")

    all_objects = [item for table in tables for item in table["objects"]]
    set_count = sum(len(item["sets"]) for item in all_objects)
    modification_count = sum(
        len(item_set["modifications"])
        for item in all_objects
        for item_set in item["sets"]
    )

    return {
        "format": "warcraft-iii-object-data",
        "kind": kind,
        "source_file": path.name,
        "version": version,
        "bytes": len(data),
        "bytes_consumed": reader.offset,
        "object_count": len(all_objects),
        "set_count": set_count,
        "modification_count": modification_count,
        "tables": tables,
    }


def infer_kind(path: Path) -> str:
    suffix = path.suffix.lower()
    if suffix == ".w3u":
        return "units"
    if suffix == ".w3a":
        return "abilities"
    raise ObjectDataError(f"Cannot infer object type from {path.name}; expected .w3u or .w3a")


def parse_wts(path: Path) -> dict[int, str]:
    raw = path.read_bytes()
    try:
        text = raw.decode("utf-8-sig")
    except UnicodeDecodeError:
        text = raw.decode("windows-1252")

    lines = text.replace("\r\n", "\n").replace("\r", "\n").split("\n")
    entries: dict[int, str] = {}
    index = 0
    while index < len(lines):
        match = re.fullmatch(r"\s*STRING\s+(\d+)\s*", lines[index], re.IGNORECASE)
        if not match:
            index += 1
            continue

        entry_id = int(match.group(1))
        if entry_id in entries:
            raise ObjectDataError(f"Duplicate STRING {entry_id} in {path}")
        index += 1
        while index < len(lines) and lines[index].strip() != "{":
            index += 1
        if index >= len(lines):
            raise ObjectDataError(f"Missing opening brace for STRING {entry_id} in {path}")
        index += 1
        body: list[str] = []
        while index < len(lines) and lines[index].strip() != "}":
            body.append(lines[index])
            index += 1
        if index >= len(lines):
            raise ObjectDataError(f"Missing closing brace for STRING {entry_id} in {path}")
        entries[entry_id] = "\n".join(body)
        index += 1
    return entries


def resolve_wts(parsed: dict, entries: dict[int, str], source_name: str) -> None:
    resolved = 0
    unresolved: set[str] = set()
    for table in parsed["tables"]:
        for item in table["objects"]:
            for item_set in item["sets"]:
                for modification in item_set["modifications"]:
                    value = modification.get("value")
                    if not isinstance(value, str):
                        continue
                    match = re.fullmatch(r"TRIGSTR_(\d+)", value, re.IGNORECASE)
                    if not match:
                        continue
                    entry_id = int(match.group(1))
                    if entry_id in entries:
                        modification["resolved_value"] = entries[entry_id]
                        resolved += 1
                    else:
                        unresolved.add(value)
    parsed["string_table"] = {
        "source_file": source_name,
        "resolved_references": resolved,
        "unresolved_references": sorted(unresolved),
    }


def simple_value(modification: dict):
    value = modification.get("resolved_value", modification["value"])
    if isinstance(value, float):
        value = round(value, 6)
        return 0.0 if value == 0 else value
    return value


def build_simple_export(documents: list[dict], kind: str) -> dict:
    """Merge core and skin data into a compact, human-oriented representation."""
    name_field = "unam" if kind == "units" else "anam"
    objects: dict[str, dict] = {}

    for document in documents:
        if document["kind"] != kind:
            continue
        for table in document["tables"]:
            for item in table["objects"]:
                object_id = item["modified_id"] or item["original_id"]
                if object_id is None:
                    raise ObjectDataError("Object has neither an original nor a modified id")

                entry = objects.setdefault(
                    object_id,
                    {
                        "name": None,
                        "base": item["original_id"] if item["modified_id"] else None,
                        "fields": {},
                        **({"levels": {}} if kind == "abilities" else {}),
                    },
                )
                fields = entry["fields"]

                for item_set in item["sets"]:
                    if item_set.get("flag", 0) != 0 or item_set["index"] != 0:
                        raise ObjectDataError(
                            f"Compact export cannot represent non-default set on {object_id}"
                        )
                    for modification in item_set["modifications"]:
                        field_id = modification["field_id"]
                        value = simple_value(modification)
                        if field_id == name_field:
                            entry["name"] = value
                            continue

                        level = modification.get("level", 0)
                        if kind == "abilities" and level > 0:
                            level_key = str(level)
                            level_fields = entry["levels"].setdefault(level_key, {})
                            if field_id in level_fields and level_fields[field_id] != value:
                                raise ObjectDataError(
                                    f"Conflicting values for {object_id}.{field_id} level {level}"
                                )
                            level_fields[field_id] = value
                        else:
                            if field_id in fields and fields[field_id] != value:
                                raise ObjectDataError(
                                    f"Conflicting values for {object_id}.{field_id}"
                                )
                            fields[field_id] = value

    for entry in objects.values():
        if "levels" in entry:
            declared_levels = entry["fields"].get("alev")
            if isinstance(declared_levels, int) and declared_levels > 0:
                entry["levels"] = {
                    key: value
                    for key, value in entry["levels"].items()
                    if int(key) <= declared_levels
                }
            entry["levels"] = {
                key: entry["levels"][key]
                for key in sorted(entry["levels"], key=int)
            }

    return {
        "format": "doltharion-simple-object-data",
        "kind": kind,
        "object_count": len(objects),
        "note": (
            "Compact merged view. Field keys such as uhpm/acdn are Warcraft III field IDs; "
            "ability values are grouped under their level."
        ),
        "objects": objects,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("inputs", nargs="+", type=Path, help="Input .w3u and/or .w3a files")
    parser.add_argument("--output-dir", type=Path, help="Directory for generated JSON files")
    parser.add_argument("--wts", type=Path, help="Optional war3map.wts used to resolve TRIGSTR references")
    parser.add_argument(
        "--simple-output-dir",
        type=Path,
        help="Also create compact merged units.json and abilities.json in this directory",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        wts_path = args.wts.resolve() if args.wts else None
        wts_entries = parse_wts(wts_path) if wts_path else None
        documents: list[dict] = []
        for input_path in args.inputs:
            source = input_path.resolve()
            if not source.is_file():
                raise ObjectDataError(f"Input does not exist: {source}")
            kind = infer_kind(source)
            parsed = parse_object_data(source, kind)
            if wts_entries is not None and wts_path is not None:
                resolve_wts(parsed, wts_entries, wts_path.name)
            documents.append(parsed)
            output_dir = args.output_dir.resolve() if args.output_dir else source.parent
            output_dir.mkdir(parents=True, exist_ok=True)
            output = output_dir / f"{source.name}.json"
            output.write_text(
                json.dumps(parsed, ensure_ascii=False, indent=2, allow_nan=False) + "\n",
                encoding="utf-8",
            )
            print(
                f"{source.name}: v{parsed['version']}, {parsed['object_count']} objects, "
                f"{parsed['set_count']} sets, {parsed['modification_count']} modifications, "
                f"{parsed['bytes_consumed']}/{parsed['bytes']} bytes consumed"
            )
            print(f"JSON: {output}")

        if args.simple_output_dir:
            simple_output_dir = args.simple_output_dir.resolve()
            simple_output_dir.mkdir(parents=True, exist_ok=True)
            for kind in ("units", "abilities"):
                if not any(document["kind"] == kind for document in documents):
                    continue
                simple = build_simple_export(documents, kind)
                output = simple_output_dir / f"{kind}.json"
                output.write_text(
                    json.dumps(simple, ensure_ascii=False, indent=2, allow_nan=False) + "\n",
                    encoding="utf-8",
                )
                print(f"Simple JSON: {output} ({simple['object_count']} objects)")
    except (OSError, ObjectDataError) as error:
        print(f"OBJECT DATA ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
