# Minecraft Modpacks

This repo uses [packwiz](https://packwiz.infra.link/) to keep the modpack as versioned TOML files and export a Modrinth `.mrpack`.

## Usage

Run **PowerShell from the repository root**. The binary is `.\tools\packwiz.exe`. Point at a pack with `--pack-file` (paths are relative to the repo root):

```powershell
.\tools\packwiz.exe --pack-file .\modpacks\minecraft-aeronautics\pack.toml <command> [args...]
```

For another pack under `modpacks/`, only change the `pack.toml` path.

## Pack layout

Inside a pack directory (e.g. `modpacks/minecraft-aeronautics/`):

| Path | Purpose |
|------|---------|
| `pack.toml` | Pack name/version, Minecraft and loader versions |
| `index.toml` | File list with hashes (normally maintained by packwiz) |
| `mods/*.pw.toml` | Per-mod metadata (download URL, hash, Modrinth update info) |
| `config/` | Config files that end up under `overrides/config/` when exported |

## Workflow

Replace `<…>` as needed. The `--pack-file …` line is the same for every command.

### Add a mod (Modrinth)

```powershell
.\tools\packwiz.exe --pack-file .\modpacks\minecraft-aeronautics\pack.toml modrinth add "<Modrinth URL | slug | search term>"
```

Packwiz creates a `.pw.toml` using the version metadata from Modrinth (including client/server env when the author set it).

### Client-only, server-only, or both

There is no `--side` flag on `add`. Set it in `mods/<mod>.pw.toml`:

```toml
side = "client"   # client only
side = "server"   # server only
side = "both"     # both sides
```

Then refresh the index:

```powershell
.\tools\packwiz.exe --pack-file .\modpacks\minecraft-aeronautics\pack.toml refresh
```

### Add or remove config files

1. Create, edit, or delete files under `modpacks/minecraft-aeronautics/config/` (or elsewhere in that pack root as needed).
2. Regenerate the index:

```powershell
.\tools\packwiz.exe --pack-file .\modpacks\minecraft-aeronautics\pack.toml refresh
```

### List mods

```powershell
.\tools\packwiz.exe --pack-file .\modpacks\minecraft-aeronautics\pack.toml list
```

### Export a Modrinth `.mrpack`

```powershell
.\tools\packwiz.exe --pack-file .\modpacks\minecraft-aeronautics\pack.toml modrinth export
```

This produces a `.mrpack` with `modrinth.index.json` and `overrides/`. Each mod’s `side` becomes the `env` field in the manifest so launchers skip client-only jars on servers (and the reverse) where supported.

### Update mods

```powershell
.\tools\packwiz.exe --pack-file .\modpacks\minecraft-aeronautics\pack.toml update
.\tools\packwiz.exe --pack-file .\modpacks\minecraft-aeronautics\pack.toml update <metadata-name>
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
