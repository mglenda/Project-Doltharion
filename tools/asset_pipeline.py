#!/usr/bin/env python3
"""Extract and synchronize Warcraft III map imports managed as project files."""

from __future__ import annotations

import argparse
import fnmatch
import json
import struct
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path, PurePosixPath, PureWindowsPath


class AssetError(RuntimeError):
    pass


@dataclass(frozen=True)
class ImportEntry:
    import_type: int
    path: str


def run(command: list[str], cwd: Path, quiet: bool = False) -> None:
    result = subprocess.run(command, cwd=cwd, text=True, capture_output=True, check=False)
    if not quiet and result.stdout.strip():
        print(result.stdout.rstrip())
    if result.stderr.strip():
        print(result.stderr.rstrip(), file=sys.stderr)
    if result.returncode != 0:
        raise AssetError(f"Command failed ({result.returncode}): {' '.join(command)}")


def validate_archive_path(raw_path: str) -> str:
    if not raw_path or "\0" in raw_path:
        raise AssetError(f"Invalid archive path: {raw_path!r}")
    path = PureWindowsPath(raw_path.replace("/", "\\"))
    if path.is_absolute() or path.drive or ".." in path.parts or "." in path.parts:
        raise AssetError(f"Archive path must be relative and normalized: {raw_path!r}")
    return "\\".join(path.parts)


def casefold_unique(paths: list[str], label: str) -> None:
    seen: dict[str, str] = {}
    for path in paths:
        key = path.casefold()
        if key in seen and seen[key] != path:
            raise AssetError(f"Case-insensitive collision in {label}: {seen[key]!r} and {path!r}")
        if key in seen:
            raise AssetError(f"Duplicate path in {label}: {path!r}")
        seen[key] = path


def parse_imports(data: bytes) -> list[ImportEntry]:
    if len(data) < 8:
        raise AssetError("war3map.imp is shorter than its header")
    version, count = struct.unpack_from("<II", data)
    if version != 1:
        raise AssetError(f"Unsupported war3map.imp version: {version}")

    offset = 8
    entries: list[ImportEntry] = []
    for index in range(count):
        if offset >= len(data):
            raise AssetError(f"Unexpected EOF reading import {index}")
        import_type = data[offset]
        offset += 1
        if import_type not in (8, 13):
            raise AssetError(f"Unsupported import type {import_type} at index {index}")
        end = data.find(b"\0", offset)
        if end < 0:
            raise AssetError(f"Unterminated path for import {index}")
        raw_path = data[offset:end]
        offset = end + 1
        try:
            path = raw_path.decode("utf-8")
        except UnicodeDecodeError as error:
            raise AssetError(f"Import path {index} is not UTF-8: {error}") from error
        entries.append(ImportEntry(import_type, validate_archive_path(path)))

    if offset != len(data):
        raise AssetError(f"war3map.imp has {len(data) - offset} unexpected trailing bytes")
    casefold_unique([entry.path for entry in entries], "war3map.imp")
    return entries


def encode_imports(paths: list[str]) -> bytes:
    casefold_unique(paths, "generated imports")
    chunks = [struct.pack("<II", 1, len(paths))]
    for path in paths:
        normalized = validate_archive_path(path)
        encoded = normalized.encode("utf-8")
        if b"\0" in encoded:
            raise AssetError(f"Import path contains NUL: {path!r}")
        chunks.append(bytes((13,)) + encoded + b"\0")
    return b"".join(chunks)


def load_asset_manifest(path: Path, project_root: Path) -> tuple[dict, Path]:
    try:
        manifest = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise AssetError(f"Cannot read asset manifest {path}: {error}") from error

    required = {"source_root", "ignore", "exclude_from_map"}
    missing = sorted(required - manifest.keys())
    if missing:
        raise AssetError(f"Asset manifest is missing: {', '.join(missing)}")
    if not isinstance(manifest["source_root"], str):
        raise AssetError("asset source_root must be a string")
    if not isinstance(manifest["ignore"], list) or not all(
        isinstance(value, str) for value in manifest["ignore"]
    ):
        raise AssetError("asset ignore must be an array of strings")
    if not isinstance(manifest["exclude_from_map"], list) or not all(
        isinstance(value, str) for value in manifest["exclude_from_map"]
    ):
        raise AssetError("asset exclude_from_map must be an array of strings")

    relative = PurePosixPath(manifest["source_root"])
    if relative.is_absolute() or ".." in relative.parts:
        raise AssetError("asset source_root must stay inside the project")
    asset_root = (project_root / Path(*relative.parts)).resolve()
    try:
        asset_root.relative_to(project_root.resolve())
    except ValueError as error:
        raise AssetError("asset source_root escapes the project") from error

    exclusions = [validate_archive_path(value.replace("/", "\\")) for value in manifest["exclude_from_map"]]
    casefold_unique(exclusions, "exclude_from_map")
    manifest["exclude_from_map"] = exclusions
    return manifest, asset_root


def is_ignored(relative: str, patterns: list[str]) -> bool:
    return any(
        fnmatch.fnmatchcase(relative, pattern)
        or (pattern.startswith("**/") and fnmatch.fnmatchcase(relative, pattern[3:]))
        for pattern in patterns
    )


def scan_assets(asset_root: Path, patterns: list[str]) -> dict[str, Path]:
    if not asset_root.is_dir():
        raise AssetError(f"Asset directory does not exist: {asset_root}")
    assets: dict[str, Path] = {}
    folded: dict[str, str] = {}
    for path in sorted(asset_root.rglob("*")):
        if not path.is_file():
            continue
        relative = path.relative_to(asset_root).as_posix()
        if is_ignored(relative, patterns):
            continue
        archive_path = validate_archive_path(relative.replace("/", "\\"))
        key = archive_path.casefold()
        if key in folded:
            raise AssetError(
                f"Case-insensitive asset collision: {folded[key]!r} and {archive_path!r}"
            )
        folded[key] = archive_path
        assets[archive_path] = path
    return assets


def extract_import_file(tool: Path, map_path: Path, destination: Path, cwd: Path) -> Path:
    destination.mkdir(parents=True, exist_ok=True)
    output = destination / "war3map.imp"
    output.unlink(missing_ok=True)
    run(
        [str(tool), "extract", "-f", "war3map.imp", "-o", str(destination), str(map_path)],
        cwd,
        quiet=True,
    )
    if not output.is_file():
        raise AssetError("mpqcli did not extract war3map.imp")
    return output


def extract_assets(
    project_root: Path,
    map_path: Path,
    tool: Path,
    manifest_path: Path,
    force: bool,
) -> None:
    manifest, asset_root = load_asset_manifest(manifest_path, project_root)
    work_dir = project_root / "build" / ".work" / "asset-manifest"
    import_file = extract_import_file(tool, map_path, work_dir, project_root)
    entries = parse_imports(import_file.read_bytes())

    if asset_root.exists() and any(asset_root.rglob("*")) and not force:
        raise AssetError(f"Asset directory is not empty: {asset_root} (use --force to refresh it)")
    asset_root.mkdir(parents=True, exist_ok=True)

    exclusions = {path.casefold() for path in manifest["exclude_from_map"]}
    extracted = 0
    for entry in entries:
        if entry.path.casefold() in exclusions:
            continue
        run(
            [str(tool), "extract", "-k", "-f", entry.path, "-o", str(asset_root), str(map_path)],
            project_root,
            quiet=True,
        )
        destination = asset_root.joinpath(*PureWindowsPath(entry.path).parts)
        if not destination.is_file():
            raise AssetError(f"Import was not extracted: {entry.path}")
        extracted += 1

    print(f"Extracted assets: {extracted}")
    print(f"Asset directory: {asset_root}")


def synchronize_assets(
    project_root: Path,
    source_map: Path,
    output_map: Path,
    tool: Path,
    manifest_path: Path,
    work_dir: Path,
) -> tuple[int, int, int, bytes]:
    manifest, asset_root = load_asset_manifest(manifest_path, project_root)
    source_import_file = extract_import_file(tool, source_map, work_dir / "source", project_root)
    source_entries = parse_imports(source_import_file.read_bytes())
    source_by_fold = {entry.path.casefold(): entry.path for entry in source_entries}

    assets = scan_assets(asset_root, manifest["ignore"])
    assets_by_fold = {path.casefold(): (path, file_path) for path, file_path in assets.items()}
    exclusions = {path.casefold(): path for path in manifest["exclude_from_map"]}

    overlap = sorted(set(assets_by_fold) & set(exclusions))
    if overlap:
        names = [assets_by_fold[key][0] for key in overlap]
        raise AssetError("Excluded assets still exist in Assets:\n  " + "\n  ".join(names))

    missing = sorted(set(source_by_fold) - set(assets_by_fold) - set(exclusions))
    if missing:
        names = [source_by_fold[key] for key in missing]
        raise AssetError(
            "Imports exist in the source map but not in Assets or exclude_from_map. "
            "Run the asset extractor after World Editor changes:\n  " + "\n  ".join(names)
        )

    ordered: list[str] = []
    used: set[str] = set()
    for entry in source_entries:
        key = entry.path.casefold()
        if key in assets_by_fold and key not in exclusions:
            ordered.append(assets_by_fold[key][0])
            used.add(key)
    ordered.extend(path for path in sorted(assets) if path.casefold() not in used)

    removed = sorted(set(source_by_fold) - {path.casefold() for path in ordered})
    for key in removed:
        run([str(tool), "remove", str(output_map), source_by_fold[key]], project_root, quiet=True)

    for archive_path in ordered:
        run(
            [
                str(tool),
                "add",
                str(output_map),
                str(assets[archive_path]),
                "--path",
                archive_path,
                "--overwrite",
                "--game",
                "warcraft3-map",
            ],
            project_root,
            quiet=True,
        )

    encoded = encode_imports(ordered)
    generated_imp = work_dir / "war3map.imp"
    generated_imp.parent.mkdir(parents=True, exist_ok=True)
    generated_imp.write_bytes(encoded)
    run(
        [str(tool), "add", str(output_map), str(generated_imp), "--path", "war3map.imp", "--overwrite"],
        project_root,
        quiet=True,
    )
    run([str(tool), "compact", str(output_map)], project_root, quiet=True)

    added = len(set(assets_by_fold) - set(source_by_fold))
    return len(ordered), added, len(removed), encoded


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("extract", "status"))
    parser.add_argument("--map", type=Path, default=Path("GluenForest.w3m"))
    parser.add_argument("--manifest", type=Path, default=Path("assets-manifest.json"))
    parser.add_argument("--mpqcli", type=Path, default=Path("tools/mpqcli/mpqcli.exe"))
    parser.add_argument("--force", action="store_true", help="Allow overwriting extracted asset files")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    project_root = Path(__file__).resolve().parent.parent
    try:
        manifest_path = (project_root / args.manifest).resolve()
        map_path = (project_root / args.map).resolve()
        tool = (project_root / args.mpqcli).resolve()
        if args.command == "extract":
            extract_assets(project_root, map_path, tool, manifest_path, args.force)
        else:
            manifest, asset_root = load_asset_manifest(manifest_path, project_root)
            assets = scan_assets(asset_root, manifest["ignore"])
            print(f"Managed assets: {len(assets)}")
            print(f"Asset directory: {asset_root}")
    except (OSError, AssetError) as error:
        print(f"ASSET ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
