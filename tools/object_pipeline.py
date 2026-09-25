#!/usr/bin/env python3
"""Apply source-controlled string overrides to Warcraft III object data."""

from __future__ import annotations

import json
import re
import subprocess
from pathlib import Path

from read_object_data import parse_object_data, parse_wts


class ObjectOverrideError(RuntimeError):
    pass


def _run(command: list[str], cwd: Path) -> None:
    result = subprocess.run(command, cwd=cwd, text=True, capture_output=True, check=False)
    if result.returncode != 0:
        raise ObjectOverrideError(
            f"Command failed ({result.returncode}): {' '.join(command)}\n"
            f"{result.stdout}{result.stderr}"
        )


def _extract(tool: Path, map_path: Path, archive_path: str, output_dir: Path) -> Path:
    output_dir.mkdir(parents=True, exist_ok=True)
    output = output_dir / archive_path
    output.unlink(missing_ok=True)
    _run([str(tool), "extract", "-f", archive_path, "-o", str(output_dir), str(map_path)], output_dir)
    if not output.is_file():
        raise ObjectOverrideError(f"Could not extract {archive_path}")
    return output


def _load_overrides(path: Path) -> dict[str, dict[str, str]]:
    try:
        document = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ObjectOverrideError(f"Cannot read object overrides {path}: {error}") from error

    abilities = document.get("abilities")
    if not isinstance(abilities, dict):
        raise ObjectOverrideError("object overrides must contain an abilities object")
    for object_id, fields in abilities.items():
        if not isinstance(object_id, str) or len(object_id) != 4 or not isinstance(fields, dict):
            raise ObjectOverrideError(f"Invalid ability override: {object_id!r}")
        for field_id, value in fields.items():
            if not isinstance(field_id, str) or len(field_id) != 4 or not isinstance(value, str):
                raise ObjectOverrideError(f"Invalid string override {object_id}.{field_id}")
    return abilities


def _find_modification(documents: list[dict], object_id: str, field_id: str) -> dict:
    matches: list[dict] = []
    for document in documents:
        for table in document["tables"]:
            for item in table["objects"]:
                current_id = item["modified_id"] or item["original_id"]
                if current_id != object_id:
                    continue
                for item_set in item["sets"]:
                    for modification in item_set["modifications"]:
                        if modification["field_id"] == field_id and modification.get("level", 0) == 0:
                            matches.append(modification)
    if len(matches) != 1:
        raise ObjectOverrideError(
            f"Expected one level-0 field {object_id}.{field_id}, found {len(matches)}"
        )
    if matches[0]["type"] != "string":
        raise ObjectOverrideError(f"Override target {object_id}.{field_id} is not a string")
    return matches[0]


def encode_wts(entries: dict[int, str]) -> bytes:
    chunks: list[str] = []
    for entry_id in sorted(entries):
        value = entries[entry_id].replace("\r\n", "\n").replace("\r", "\n")
        chunks.append(f"STRING {entry_id}\n{{\n{value}\n}}\n")
    # Warcraft's World Editor writes WTS as UTF-8 with BOM and CRLF. Reforged
    # does not resolve TRIGSTR references reliably when either is discarded.
    text = ("\n".join(chunks) + "\n").replace("\n", "\r\n")
    return text.encode("utf-8-sig")


def apply_object_overrides(
    project_root: Path,
    output_map: Path,
    tool: Path,
    overrides_path: Path,
    work_dir: Path,
) -> tuple[int, bytes]:
    abilities = _load_overrides(overrides_path)
    core = _extract(tool, output_map, "war3map.w3a", work_dir)
    skin = _extract(tool, output_map, "war3mapSkin.w3a", work_dir)
    wts = _extract(tool, output_map, "war3map.wts", work_dir)
    documents = [parse_object_data(core, "abilities"), parse_object_data(skin, "abilities")]
    entries = parse_wts(wts)

    count = 0
    for object_id, fields in abilities.items():
        for field_id, value in fields.items():
            modification = _find_modification(documents, object_id, field_id)
            match = re.fullmatch(r"TRIGSTR_(\d+)", modification["value"], re.IGNORECASE)
            if not match:
                raise ObjectOverrideError(
                    f"{object_id}.{field_id} is not backed by a TRIGSTR in the current map"
                )
            entry_id = int(match.group(1))
            if entry_id not in entries:
                raise ObjectOverrideError(f"Missing STRING {entry_id} for {object_id}.{field_id}")
            entries[entry_id] = value
            count += 1

    encoded = encode_wts(entries)
    generated = work_dir / "generated" / "war3map.wts"
    generated.parent.mkdir(parents=True, exist_ok=True)
    generated.write_bytes(encoded)
    _run(
        [str(tool), "add", str(output_map), str(generated), "--path", "war3map.wts", "--overwrite"],
        project_root,
    )
    return count, encoded
