# Modrinth Modpacks

## How to edit a modpack

Note: if you are using the `itzg/docker-minecraft-server`, delete the `/data/modpack.mrpack` and then restart the server after applying any change. 

### 1. Modrinth App (official workflow)

If you are not already using it, the Modrinth App lets you edit the instance directly.

- **Add or remove mods:** Drag and drop `.jar` files or browse in the UI. The app updates the manifest for you.
- **Export:** When you are done, use **Export** to generate a clean `.mrpack` in one click, without editing JSON by hand.

### 2. Packwiz (recommended for serious / dev workflows)

For a production-style modpack, Packwiz is the common tooling choice. Instead of one huge `.mrpack`, you work with individual `.pw.toml` files per mod.

**How it works:**

- Keep a folder with your config files and the `.toml` entries.
- Add mods from the terminal: `packwiz mr add <mod-url>`.
- **Fast export:** Run `packwiz mr export` to build the `.mrpack` quickly.
- **Version control:** You can use Git to see exactly what changed per release—much harder with a single opaque zip.

### 3. In-place editing with 7-Zip or WinRAR

To tweak a config file quickly without fully unpacking the pack:

1. Right-click the `.mrpack` → **Open with** 7-Zip (or WinRAR).
2. Go to `overrides/config`.
3. Drag your updated file into the archive window.
4. Close the window. 7-Zip updates the compressed file in place, so you do not need to re-export the whole pack.
