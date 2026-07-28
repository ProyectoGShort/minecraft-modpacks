# Minecraft Modpacks

This repo uses [packwiz](https://packwiz.infra.link/) to keep the modpack as versioned TOML files and export a Modrinth `.mrpack`.

## Naming conventions

Pack folders and build filenames share one slug; the display `name` in `pack.toml` is separate (human-readable). Getting the slug wrong breaks CI export paths and server deployments.

| What | Rule | Example |
|------|------|---------|
| Pack folder | `modpacks/minecraft-<slug>/` — lowercase, words and numbers separated by **hyphens** (`-`). Never camelCase, glued numbers, or underscores. | `modpacks/minecraft-horizons-2/` |
| Display `name` in `pack.toml` | Human-readable title with spaces (not the folder slug). Prefer the `Minecraft …` prefix used by existing packs. | `name = "Minecraft Horizons 2"` |
| `author` in `pack.toml` | Your **nickname**, not a placeholder or real full name unless that is your nickname. | `author = "YourNickname"` |
| Build artifacts | Same slug as the folder: `builds/<slug>-<version>.mrpack` and `builds/<slug>-latest.mrpack`. | `builds/minecraft-horizons-2-1.0.0.mrpack`, `builds/minecraft-horizons-2-latest.mrpack` |

**Wrong vs right:**

```text
❌ modpacks/minecraft-horizons2/          ✅ modpacks/minecraft-horizons-2/
❌ modpacks/minecraft-horizons_2/         ✅ modpacks/minecraft-horizons-2/
❌ name = "Horizons2"                     ✅ name = "Minecraft Horizons 2"
❌ builds/Horizons2-1.0.0.mrpack          ✅ builds/minecraft-horizons-2-1.0.0.mrpack
```

The GitHub Actions export workflow names builds from the **folder basename**, not from `pack.toml` `name`. Do not commit a `.mrpack` whose filename comes from the display name (e.g. `Horizons2-1.0.0.mrpack`); it must match `builds/<slug>-<version>.mrpack` and `builds/<slug>-latest.mrpack`.

## Usage

Run **PowerShell from the repository root**. The binary is `.\tools\packwiz.exe`.

**Important:** `--pack-file` selects which `pack.toml` to use, but **new** metadata files (for example from `modrinth add`) are placed under `--meta-folder-base` (defaults to `.`, i.e. the current working directory). If you omit it while running from the repo root, packwiz writes `mods/*.pw.toml` **at the repo root** instead of inside the pack folder. Always pass **both**:

- `--pack-file` → `<pack-dir>\pack.toml`
- `--meta-folder-base` → the same `<pack-dir>` (the folder that contains `pack.toml`, `mods/`, `config/`, etc.)

Define the pack folder once per session (adjust for another pack):

```powershell
$pack = ".\modpacks\minecraft-aeronautics"
```

Then every invocation should follow this shape:

```powershell
& .\tools\packwiz.exe --pack-file "$pack\pack.toml" --meta-folder-base $pack <command> [args...]
```

## Pack layout

Inside a pack directory (e.g. `modpacks/minecraft-aeronautics/`):

| Path | Purpose |
|------|---------|
| `pack.toml` | Pack name/version, Minecraft and loader versions |
| `index.toml` | File list with hashes (normally maintained by packwiz) |
| `mods/*.pw.toml` | Per-mod metadata (download URL, hash, Modrinth update info) |
| `config/` | Config files that end up under `overrides/config/` when exported |

## Workflow

Use the same `$pack` as in [Usage](#usage). Examples skip repeating the comment line.

### Initialise a new modpack

Pick a kebab-case folder slug first (see [Naming conventions](#naming-conventions)), then set `$pack` to that path. `init` must run inside the pack folder (`Push-Location` / `Pop-Location` return you to the repo root):

```powershell
$pack = ".\modpacks\minecraft-horizons-2"
New-Item -ItemType Directory -Path $pack -Force
Push-Location $pack
& ..\..\tools\packwiz.exe init `
  --name "Minecraft Horizons 2" `
  --author "YourNickname" `
  --version "1.0.0" `
  --mc-version "1.21.1" `
  --modloader neoforge `
  --neoforge-version "21.1.227"
Pop-Location
```

Swap NeoForge for Forge/Fabric/Quilt with the matching `--modloader` and version flags as needed.

### Add a mod (Modrinth)

```powershell
& .\tools\packwiz.exe --pack-file "$pack\pack.toml" --meta-folder-base $pack modrinth add "<Modrinth URL | slug | search term>"
```

Packwiz creates a `.pw.toml` using the version metadata from Modrinth (including client/server env when the author set it).

### Client-only, server-only, or both

There is no `--side` flag on `add`. Set it inside the pack — `mods/<mod>.pw.toml` under `$pack`:

```toml
side = "client"   # client only
side = "server"   # server only
side = "both"     # both sides
```

Then refresh the index:

```powershell
& .\tools\packwiz.exe --pack-file "$pack\pack.toml" --meta-folder-base $pack refresh
```

### Add or remove config files

1. Create, edit, or delete files under `$pack/config/` (or elsewhere under `$pack` as needed).
2. Regenerate the index:

```powershell
& .\tools\packwiz.exe --pack-file "$pack\pack.toml" --meta-folder-base $pack refresh
```

### List mods

```powershell
& .\tools\packwiz.exe --pack-file "$pack\pack.toml" --meta-folder-base $pack list
```

### Export a Modrinth `.mrpack`

```powershell
& .\tools\packwiz.exe --pack-file "$pack\pack.toml" --meta-folder-base $pack modrinth export
```

This produces a `.mrpack` with `modrinth.index.json` and `overrides/`. Each mod’s `side` becomes the `env` field in the manifest so launchers skip client-only jars on servers (and the reverse) where supported.

### Update mods

```powershell
& .\tools\packwiz.exe --pack-file "$pack\pack.toml" --meta-folder-base $pack update
& .\tools\packwiz.exe --pack-file "$pack\pack.toml" --meta-folder-base $pack update <metadata-name>
```

For a single mod, `<metadata-name>` is what packwiz expects after `refresh` — usually the `mods/*.pw.toml` filename without `.pw.toml` (for example `sodium-neoforge-0.6.13+mc1.21.1` for `mods/sodium-neoforge-0.6.13+mc1.21.1.pw.toml`).

### Help

```powershell
.\tools\packwiz.exe --help
.\tools\packwiz.exe modrinth --help
```

Use `.\tools\packwiz.exe <command> --help` for other commands (CurseForge, `url`, etc.).

## Deploying to a server (itzg/docker-minecraft-server)

> **Known bug (temporary):** after updating the `.mrpack`, the server does not pick up the new version automatically.
> Delete the existing mrpack file from the server data directory and restart the container to force a clean reinstall.
