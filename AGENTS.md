# Tools4Nerds — Agent Guide

## Project Overview

Tools4Nerds is an Elder Scrolls Online addon targeting PvP players. It provides:
- **CC immunity countdown** — tracks when your target is immune to crowd control
- **Block indicator** — briefly shows when your attack is blocked
- **Crit hit marker** — animated overlay when you land a critical hit
- **Auto queue accept** — automatically accepts dungeon and PvP queue pop-ups

## File Structure

| File | Purpose |
|------|---------|
| `Tools4Nerds.lua` | All addon logic |
| `Tools4Nerds.xml` | UI control definitions (`T4NCCContainer`, `T4NBlockContainer`, `T4NCritContainer`) |
| `Tools4Nerds.txt` | Addon manifest — version, dependencies, load order |
| `Tools4NerdsBindings.xml` | Keybinding definitions |
| `marker.dds` | Texture used for the crit hit marker |
| `CHANGELOG.md` | Version history |

## ESO API Notes

**Buff visibility in PvP** — `GetNumBuffs("reticleover")` and `GetUnitBuffInfo` do not reliably return enemy player buffs in all contexts. Duels (open world) work; Battlegrounds and Cyrodiil may not. Do not rely solely on buff reading for CC immunity tracking — use combat event inference (`ccImmuneTimes`) as the primary or fallback mechanism.

**Saved variables** — `sv` points to either `Tools4NerdsSV` (per-character) or `Tools4NerdsAccountSV` (account-wide) depending on the sync setting. Always read and write through `sv`, never directly to the underlying tables.

**LAM (LibAddonMenu)** — settings panel is registered via `LibAddonMenu2`. The panel is defined in `RegisterSettings()`. LAM must be listed as a dependency in `Tools4Nerds.txt`.

**Unit tags** — `"reticleover"` is the current target. `"player"` is the local player. These are the only two unit tags used in this addon.

**Tick loop** — CC immunity polling uses a self-rescheduling `zo_callLater` loop (100ms interval). The loop starts from `UpdateIndicator()` and stops itself when the player leaves combat or loses a player target. `tickId` is used to cancel stale ticks.

## Code Conventions

- All UI control names are prefixed with `T4N` (e.g. `T4NLabel`, `T4NBlockContainer`)
- `sv` is the active saved variable table — always use this, never the raw global
- `accountSv` holds account-level saved variables including the sync flag
- CC combat result types are stored in `CC_RESULTS` table, populated on load from `ACTION_RESULT_*` constants
- `ccImmuneTimes` maps cleaned target names to expiry timestamps for combat-event-based CC inference
- Control names are stripped of color codes with `:gsub("%^.*", "")` before use as table keys

## Testing

There are no automated tests. All validation must be done in-game.

- **Settings panel test buttons** — "Test CC Indicator", "Test Block Indicator", and "Test Marker" in the LAM settings panel trigger each feature without needing a real combat event
- **`/t4n debug`** — prints current state to chat: combat flag, target unit type, buff count, CC buff presence, inferred CC remaining, and tick status. Use this when diagnosing why an indicator isn't showing
- When making changes to combat event handling, test in both a duel and a Battleground as behavior can differ

## Changelog Rule

**Always update `CHANGELOG.md` before considering any change done.** Use [Semantic Versioning](https://semver.org/):

- **Patch** (`x.x.1`) — bug fixes, no new features
- **Minor** (`x.1.0`) — new features, backwards compatible
- **Major** (`2.0.0`) — breaking changes, significant renames or rewrites

Also update the version in **both** `Tools4Nerds.txt` (`## Version:`) and the `panelData.version` string inside `RegisterSettings()` in `Tools4Nerds.lua` to match.

## No-Go List

- Do not read enemy player buffs as the sole source of truth for CC immunity — it is unreliable in BGs/Cyrodiil; always ensure `ccImmuneTimes` inference is in place as a fallback
- Do not access `Tools4NerdsSV` or `Tools4NerdsAccountSV` directly from feature code — always go through `sv`. The only legitimate exception is the sync toggle in `RegisterSettings()`, which must copy settings between the two tables when switching scope.
- Do not add `sleep` or long `zo_callLater` chains for polling — use the existing tick loop pattern
