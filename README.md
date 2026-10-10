# JawaJutsuHub

Public release distribution for JawaJutsu scripts. Currently: **Baddies Jump V1.0.0**.

## Run

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/JawaJutsu/JawaJutsuHub/main/loader.lua"))()
```

## Structure

- `loader.lua` — version-pinned loader, currently Baddies Jump only
- `games/baddies-jump/v1.0.0.lua` — tested protected baseline
- `games/baddies-jump/manifest.json` — release metadata and SHA-256

## Compatibility / security

- Potassium: GUI, auto-jump and auto-upgrade tested by author; GitHub loader not yet tested.
- Xeno/Delta: **not tested**. `getconnections` is required by auto-upgrade.
- `crypt.hash` behavior varies. Loader blocks a **known hash mismatch**, but when hashing is missing or incompatible it logs `UNVERIFIED` and continues for compatibility. This mode does **not** guarantee integrity.
- This is **light UI obfuscation only**, not comprehensive protection of jump logic. Client-side code can still be inspected or copied.
- `loader.lua` pins SHA-256 and URL to v1.0.0. A new version needs a loader update; `manifest.json` alone does not trigger updates.
- Do not upload unprotected private source, keys, or build tooling.
