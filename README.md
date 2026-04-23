# Minecraft Modpacks

This repo uses [packwiz](https://packwiz.infra.link/) to keep the modpack as versioned TOML files and export a Modrinth `.mrpack`.

## Requirements

- [packwiz](https://packwiz.infra.link/) on your `PATH`, **or** use the vendored binary in the repository root (see [Bundled packwiz](#bundled-packwiz) below).

## Pack layout

Inside the pack directory (e.g. `minecraft-aeronautics/`):

| Path | Purpose |
|------|---------|
| `pack.toml` | Pack name/version, Minecraft and loader versions |
| `index.toml` | File list with hashes (normally maintained by packwiz) |
| `mods/*.pw.toml` | Per-mod metadata (download URL, hash, Modrinth update info) |
| `config/` | Config files that end up under `overrides/config/` when exported |

## Bundled packwiz

This repository ships a local copy of the [packwiz](https://packwiz.infra.link/) CLI so you do not have to install it system-wide. Pick the build that matches your OS:

| Environment | Use |
|---------------|-----|
| Windows | `packwiz.exe` in the repository root |
| Linux / macOS (shell / Bash) | The Unix `packwiz` binary (no extension) in the repository root |

Modpacks live under `modpacks/<name>/`. Each pack is identified by its `pack.toml`. From the **repository root**, pass `--pack-file` to every command that should affect a **specific** pack (refresh, update, export, etc.); otherwise packwiz may look for a pack in the current directory and miss the right project.

Example (Bash, from repo root):

```bash
./packwiz refresh --pack-file modpacks/minecraft-aeronautics/pack.toml
./packwiz update --pack-file modpacks/minecraft-aeronautics/pack.toml
./packwiz modrinth export --pack-file modpacks/minecraft-aeronautics/pack.toml
```

Example (Windows `cmd` / PowerShell, from repo root):

```powershell
.\packwiz.exe refresh --pack-file modpacks\minecraft-aeronautics\pack.toml
.\packwiz.exe update --pack-file modpacks\minecraft-aeronautics\pack.toml
.\packwiz.exe modrinth export --pack-file modpacks\minecraft-aeronautics\pack.toml
```

## Workflow

From the pack root:

```bash
cd minecraft-aeronautics
```

### Add a mod (Modrinth)

```bash
packwiz modrinth add <Modrinth URL | slug | search term>
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

```bash
packwiz refresh
```

### Add or remove config files

1. Create, edit, or delete files under `config/` (or elsewhere in the pack root as needed).
2. Regenerate the index:

```bash
packwiz refresh
```

### List mods

```bash
packwiz list
```

### Export a Modrinth `.mrpack`

```bash
packwiz modrinth export
```

This produces a `.mrpack` with `modrinth.index.json` and `overrides/`. Each mod’s `side` becomes the `env` field in the manifest so launchers skip client-only jars on servers (and the reverse) where supported.

### Update mods

```bash
packwiz update                 # everything that can update
packwiz update <file.pw.toml>  # one mod
```

Use `packwiz help` and `packwiz <command> --help` for other sources (CurseForge, `url`, etc.).

## Deploying to a server (itzg/docker-minecraft-server)

> **Known bug (temporary):** after updating the `.mrpack`, the server does not pick up the new version automatically.
> Delete the existing mrpack file from the server data directory and restart the container to force a clean reinstall.
