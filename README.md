# Minecraft Modpacks

This repo uses [packwiz](https://packwiz.infra.link/) to keep the modpack as versioned TOML files and export a Modrinth `.mrpack`.

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

For a single mod, `<metadata-name>` is what packwiz expects after `refresh` — usually the `mods/*.pw.toml` filename without `.pw.toml` (for example `iris` for `mods/iris.pw.toml`).

### Help

```powershell
.\tools\packwiz.exe --help
.\tools\packwiz.exe modrinth --help
```

Use `.\tools\packwiz.exe <command> --help` for other commands (CurseForge, `url`, etc.).

## Deploying to a server (itzg/docker-minecraft-server)

> **Known bug (temporary):** after updating the `.mrpack`, the server does not pick up the new version automatically.
> Delete the existing mrpack file from the server data directory and restart the container to force a clean reinstall.
