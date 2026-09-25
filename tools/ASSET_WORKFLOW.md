# Asset workflow

`Assets/` mirrors paths inside the Warcraft III map archive. For example:

```text
Assets/war3mapImported/Penance.mdx
Assets/ReplaceableTextures/CommandButtons/BTNMage.dds
Assets/Prototype.ttf
```

## Commands

Extract imports from the current source map for the first time:

```powershell
python .\tools\asset_pipeline.py extract
```

Refresh files after adding imports through World Editor:

```powershell
python .\tools\asset_pipeline.py extract --force
```

Show the number of locally managed assets:

```powershell
python .\tools\asset_pipeline.py status
```

Build Lua and synchronize all managed assets into a fresh map copy:

```powershell
python .\tools\build_map.py
```

## Adding and removing assets

- Add an asset by placing it below `Assets/` at its intended archive path.
- Replace an asset by replacing the corresponding local file.
- Remove an existing source-map import by deleting its local file and adding its archive path to
  `exclude_from_map` in `assets-manifest.json`.
- Development files matched by `ignore` are never inserted into the map.

The build never modifies `GluenForest.w3m`. It copies the current map, synchronizes assets,
regenerates `war3map.imp`, injects Lua, compacts the MPQ, and writes the result below `build/`.
