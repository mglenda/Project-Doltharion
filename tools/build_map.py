#!/usr/bin/env python3
"""Build and inject Project Doltharion's Lua code into a fresh map copy."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Iterable

from asset_pipeline import AssetError, parse_imports, synchronize_assets
from object_pipeline import ObjectOverrideError, apply_object_overrides


BEGIN_MARKER = "-- DOLTHARION:SCRIPTS:BEGIN"
END_MARKER = "-- DOLTHARION:SCRIPTS:END"

# These are emitted by Warcraft III's map script generator. The first one after
# InitGlobals marks the beginning of the generated suffix that must be retained.
GENERATED_FUNCTION_NAMES = {
    "InitSounds",
    "CreateRegions",
    "CreateCameras",
    "CreateAllItems",
    "CreateAllDestructables",
    "CreateDestructables",
    "CreateDoodads",
    "CreateAllUnits",
    "InitCustomTriggers",
    "RunInitializationTriggers",
    "InitCustomPlayerSlots",
    "InitCustomTeams",
    "InitAllyPriorities",
    "main",
}

GENERATED_FUNCTION_PREFIXES = (
    "CreateBuildingsForPlayer",
    "CreateUnitsForPlayer",
    "CreateNeutralHostile",
    "CreateNeutralPassive",
    "CreatePlayerBuildings",
    "CreatePlayerUnits",
    "InitTrig_",
    "Trig_",
)


class BuildError(RuntimeError):
    pass


@dataclass(frozen=True)
class Token:
    value: str
    start: int
    end: int


@dataclass(frozen=True)
class FunctionSpan:
    name: str
    start: int
    end: int


def _long_bracket_end(text: str, start: int) -> int | None:
    match = re.match(r"\[(=*)\[", text[start:])
    if not match:
        return None
    closing = "]" + match.group(1) + "]"
    content_start = start + match.end()
    close_at = text.find(closing, content_start)
    if close_at < 0:
        raise BuildError(f"Unterminated Lua long bracket at offset {start}")
    return close_at + len(closing)


def tokenize_lua(text: str) -> list[Token]:
    """Tokenize enough Lua syntax to track top-level block boundaries safely."""
    tokens: list[Token] = []
    i = 0
    length = len(text)

    while i < length:
        char = text[i]

        if char.isspace():
            i += 1
            continue

        if text.startswith("--", i):
            long_end = _long_bracket_end(text, i + 2)
            if long_end is not None:
                i = long_end
            else:
                newline = text.find("\n", i + 2)
                i = length if newline < 0 else newline + 1
            continue

        if char in ("'", '"'):
            quote = char
            start = i
            i += 1
            while i < length:
                if text[i] == "\\":
                    i += 2
                    continue
                if text[i] == quote:
                    i += 1
                    break
                i += 1
            else:
                raise BuildError(f"Unterminated Lua string at offset {start}")
            continue

        if char == "[":
            long_end = _long_bracket_end(text, i)
            if long_end is not None:
                i = long_end
                continue

        if char.isalpha() or char == "_":
            start = i
            i += 1
            while i < length and (text[i].isalnum() or text[i] == "_"):
                i += 1
            tokens.append(Token(text[start:i], start, i))
            continue

        tokens.append(Token(char, i, i + 1))
        i += 1

    return tokens


def find_top_level_functions(text: str) -> list[FunctionSpan]:
    tokens = tokenize_lua(text)
    stack: list[str] = []
    active: tuple[str, int] | None = None
    functions: list[FunctionSpan] = []

    for index, token in enumerate(tokens):
        value = token.value
        depth = len(stack)

        if value == "function":
            if depth == 0:
                if index + 1 >= len(tokens):
                    raise BuildError("Unexpected end after top-level function keyword")
                name = tokens[index + 1].value
                if not (name[0].isalpha() or name[0] == "_"):
                    # Anonymous top-level function expression, not a declaration.
                    name = "<anonymous>"
                active = (name, token.start)
            stack.append("end")
        elif value == "if":
            stack.append("end")
        elif value == "do":
            stack.append("end")
        elif value == "repeat":
            stack.append("until")
        elif value == "end":
            if not stack or stack[-1] != "end":
                raise BuildError(f"Unexpected Lua 'end' at offset {token.start}")
            stack.pop()
            if not stack and active is not None:
                functions.append(FunctionSpan(active[0], active[1], token.end))
                active = None
        elif value == "until":
            if not stack or stack[-1] != "until":
                raise BuildError(f"Unexpected Lua 'until' at offset {token.start}")
            stack.pop()

    if stack:
        raise BuildError("Unclosed Lua block while parsing war3map.lua")
    return functions


def is_generated_function(name: str) -> bool:
    return name in GENERATED_FUNCTION_NAMES or name.startswith(GENERATED_FUNCTION_PREFIXES)


def find_injection_bounds(text: str) -> tuple[int, int, str]:
    functions = find_top_level_functions(text)
    init_globals = [function for function in functions if function.name == "InitGlobals"]
    main_functions = [function for function in functions if function.name == "main"]
    config_functions = [function for function in functions if function.name == "config"]

    if len(init_globals) != 1:
        raise BuildError(f"Expected exactly one top-level InitGlobals, found {len(init_globals)}")
    if len(main_functions) != 1:
        raise BuildError(f"Expected exactly one top-level main, found {len(main_functions)}")
    if len(config_functions) != 1:
        raise BuildError(f"Expected exactly one top-level config, found {len(config_functions)}")

    init_global = init_globals[0]
    main = main_functions[0]
    config = config_functions[0]
    if not (init_global.end < main.start < config.start):
        raise BuildError("Unexpected InitGlobals/main/config order in war3map.lua")

    candidates = [
        function
        for function in functions
        if init_global.end < function.start <= main.start and is_generated_function(function.name)
    ]
    if not candidates:
        raise BuildError("Could not locate the World Editor generated suffix after InitGlobals")

    suffix = min(candidates, key=lambda function: function.start)
    if suffix.name == "main":
        # Valid for an almost empty map, but make the unusual case explicit.
        anchor_name = "main"
    else:
        anchor_name = suffix.name

    if suffix.start <= init_global.end:
        raise BuildError("Computed injection range is empty or reversed")
    return init_global.end, suffix.start, anchor_name


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def project_path(root: Path, raw_path: str, label: str) -> Path:
    relative = PurePosixPath(raw_path)
    if relative.is_absolute() or ".." in relative.parts:
        raise BuildError(f"{label} must stay inside the project: {raw_path}")
    resolved = (root / Path(*relative.parts)).resolve()
    try:
        resolved.relative_to(root.resolve())
    except ValueError as error:
        raise BuildError(f"{label} escapes the project: {raw_path}") from error
    return resolved


def unique_paths(values: Iterable[str], label: str) -> list[str]:
    result = list(values)
    duplicates = sorted({value for value in result if result.count(value) > 1})
    if duplicates:
        raise BuildError(f"Duplicate entries in {label}: {', '.join(duplicates)}")
    return result


def load_manifest(manifest_path: Path) -> tuple[dict, Path]:
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise BuildError(f"Cannot read manifest {manifest_path}: {error}") from error

    required = {
        "map",
        "output_map",
        "output_script",
        "source_root",
        "mpqcli",
        "assets_manifest",
        "object_overrides",
        "scripts",
        "ignore",
    }
    missing = sorted(required - manifest.keys())
    if missing:
        raise BuildError(f"Manifest is missing: {', '.join(missing)}")
    if not isinstance(manifest["scripts"], list) or not isinstance(manifest["ignore"], list):
        raise BuildError("Manifest scripts and ignore must be arrays")
    return manifest, manifest_path.parent.resolve()


def validate_sources(root: Path, manifest: dict) -> list[Path]:
    source_root = project_path(root, manifest["source_root"], "source_root")
    if not source_root.is_dir():
        raise BuildError(f"Source directory does not exist: {source_root}")

    scripts = unique_paths(manifest["scripts"], "scripts")
    ignored = unique_paths(manifest["ignore"], "ignore")
    overlap = sorted(set(scripts) & set(ignored))
    if overlap:
        raise BuildError(f"Files cannot be both loaded and ignored: {', '.join(overlap)}")

    discovered = {
        path.relative_to(source_root).as_posix()
        for path in source_root.rglob("*.lua")
        if path.is_file()
    }
    classified = set(scripts) | set(ignored)
    unclassified = sorted(discovered - classified)
    missing = sorted(classified - discovered)
    if unclassified:
        raise BuildError("Unclassified Lua files (add to scripts or ignore):\n  " + "\n  ".join(unclassified))
    if missing:
        raise BuildError("Manifest entries that do not exist:\n  " + "\n  ".join(missing))

    return [source_root / Path(*PurePosixPath(path).parts) for path in scripts]


def decode_utf8(data: bytes, label: str) -> tuple[str, bool]:
    bom = data.startswith(b"\xef\xbb\xbf")
    payload = data[3:] if bom else data
    try:
        return payload.decode("utf-8"), bom
    except UnicodeDecodeError as error:
        raise BuildError(f"{label} is not valid UTF-8: {error}") from error


def normalize_newlines(text: str, newline: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n").replace("\n", newline)


def assemble_script(base_bytes: bytes, sources: list[Path]) -> tuple[bytes, str]:
    base_text, has_bom = decode_utf8(base_bytes, "Extracted war3map.lua")
    newline = "\r\n" if base_text.count("\r\n") >= max(1, base_text.count("\n") // 2) else "\n"
    injection_start, injection_end, anchor = find_injection_bounds(base_text)

    chunks = [BEGIN_MARKER]
    for source in sources:
        source_text, _ = decode_utf8(source.read_bytes(), str(source))
        chunks.append(normalize_newlines(source_text, newline).rstrip("\r\n"))
    chunks.append(END_MARKER)
    custom_code = (newline * 2).join(chunks)

    prefix = base_text[:injection_start].rstrip("\r\n")
    suffix = base_text[injection_end:].lstrip("\r\n")
    result = prefix + newline * 2 + custom_code + newline * 2 + suffix
    encoded = result.encode("utf-8")
    if has_bom:
        encoded = b"\xef\xbb\xbf" + encoded
    return encoded, anchor


def run(command: list[str], cwd: Path) -> None:
    result = subprocess.run(command, cwd=cwd, text=True, capture_output=True, check=False)
    if result.stdout.strip():
        print(result.stdout.rstrip())
    if result.stderr.strip():
        print(result.stderr.rstrip(), file=sys.stderr)
    if result.returncode != 0:
        raise BuildError(f"Command failed ({result.returncode}): {' '.join(command)}")


def build(manifest_path: Path, output_override: str | None, script_only: bool) -> None:
    manifest, root = load_manifest(manifest_path)
    sources = validate_sources(root, manifest)
    source_map = project_path(root, manifest["map"], "map")
    output_script = project_path(root, manifest["output_script"], "output_script")
    tool = project_path(root, manifest["mpqcli"], "mpqcli")
    assets_manifest = project_path(root, manifest["assets_manifest"], "assets_manifest")
    object_overrides = project_path(root, manifest["object_overrides"], "object_overrides")
    output_map = project_path(root, output_override or manifest["output_map"], "output_map")

    if not source_map.is_file():
        raise BuildError(f"Source map does not exist: {source_map}")
    if not tool.is_file():
        raise BuildError(f"mpqcli does not exist: {tool}")
    if not assets_manifest.is_file():
        raise BuildError(f"Asset manifest does not exist: {assets_manifest}")
    if not object_overrides.is_file():
        raise BuildError(f"Object overrides do not exist: {object_overrides}")
    if source_map == output_map:
        raise BuildError("output_map must not overwrite the source map")

    source_hash_before = sha256(source_map)
    output_script.parent.mkdir(parents=True, exist_ok=True)

    work_root = root / "build" / ".work"
    extracted_dir = work_root / "extracted"
    verification_dir = work_root / "verification"
    extracted_dir.mkdir(parents=True, exist_ok=True)
    verification_dir.mkdir(parents=True, exist_ok=True)
    extracted_script = extracted_dir / "war3map.lua"
    verification_script = verification_dir / "war3map.lua"
    verification_imp = verification_dir / "war3map.imp"
    extracted_script.unlink(missing_ok=True)
    verification_script.unlink(missing_ok=True)
    verification_imp.unlink(missing_ok=True)

    run(
        [str(tool), "extract", "-f", "war3map.lua", "-o", str(extracted_dir), str(source_map)],
        cwd=work_root,
    )
    if not extracted_script.is_file():
        raise BuildError("mpqcli did not extract war3map.lua")

    built_bytes, suffix_anchor = assemble_script(extracted_script.read_bytes(), sources)
    output_script.write_bytes(built_bytes)

    if not script_only:
        output_map.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_map, output_map)
        run(
            [
                str(tool),
                "add",
                str(output_map),
                str(output_script),
                "--path",
                "war3map.lua",
                "--overwrite",
            ],
            cwd=work_root,
        )

        try:
            override_count, expected_wts = apply_object_overrides(
                root,
                output_map,
                tool,
                object_overrides,
                work_root / "object-build",
            )
            asset_count, added_assets, removed_assets, expected_imp = synchronize_assets(
                root,
                source_map,
                output_map,
                tool,
                assets_manifest,
                work_root / "assets-build",
            )
        except (AssetError, ObjectOverrideError) as error:
            raise BuildError(str(error)) from error

        run(
            [str(tool), "extract", "-f", "war3map.lua", "-o", str(verification_dir), str(output_map)],
            cwd=work_root,
        )
        if not verification_script.is_file() or verification_script.read_bytes() != built_bytes:
            raise BuildError("Injected war3map.lua failed byte-for-byte verification")
        run(
            [str(tool), "extract", "-f", "war3map.imp", "-o", str(verification_dir), str(output_map)],
            cwd=work_root,
        )
        if not verification_imp.is_file() or verification_imp.read_bytes() != expected_imp:
            raise BuildError("Injected war3map.imp failed byte-for-byte verification")
        verified_imports = parse_imports(verification_imp.read_bytes())
        if len(verified_imports) != asset_count:
            raise BuildError("Injected war3map.imp contains an unexpected number of imports")
        verification_wts = verification_dir / "war3map.wts"
        verification_wts.unlink(missing_ok=True)
        run(
            [str(tool), "extract", "-f", "war3map.wts", "-o", str(verification_dir), str(output_map)],
            cwd=work_root,
        )
        if not verification_wts.is_file() or verification_wts.read_bytes() != expected_wts:
            raise BuildError("Injected war3map.wts failed byte-for-byte verification")

    source_hash_after = sha256(source_map)
    if source_hash_before != source_hash_after:
        raise BuildError("Source map changed during the build")

    print(f"Loaded scripts: {len(sources)}")
    print(f"World Editor suffix anchor: {suffix_anchor}")
    print(f"Built script: {output_script} ({output_script.stat().st_size} bytes)")
    if not script_only:
        print(
            f"Managed assets: {asset_count} "
            f"({added_assets} added, {removed_assets} removed from source-map snapshot)"
        )
        print(f"Object string overrides: {override_count}")
        print(f"Built map: {output_map} ({output_map.stat().st_size} bytes)")
        print(f"Built map SHA-256: {sha256(output_map)}")
    print(f"Source map unchanged: {source_hash_after}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--manifest",
        type=Path,
        default=Path(__file__).resolve().parent.parent / "build-manifest.json",
        help="Path to build-manifest.json",
    )
    parser.add_argument("--output-map", help="Override output_map from the manifest")
    parser.add_argument(
        "--script-only",
        action="store_true",
        help="Build war3map.lua but do not copy or modify an output map",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        build(args.manifest.resolve(), args.output_map, args.script_only)
    except (OSError, BuildError) as error:
        print(f"BUILD ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
