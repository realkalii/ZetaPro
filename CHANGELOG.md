# Changelog

## ZetaPro v1.0.1 - Early beta

### Icons

- Added icon families with the `family:name` syntax: `lucide`, `solar`, `geist`, `craft` and `sfsymbols`, for example `Icon = "solar:bomb"` and `Icon = "geist:code"`.
- The families are powered by [Footagesus/Icons](https://github.com/Footagesus/Icons) (MIT License, Copyright (c) 2025 Footages). Each family is downloaded once, in the background, and cached in `ZetaPro/icons/<family>.lua`.
- If a family cannot be loaded, the built-in local icon is shown instead, so the UI never breaks. When the family finishes loading, the real icon replaces the local one automatically.
- Solar variants: names resolve to the first variant that exists (`-linear`, `-outline`, `-bold`, `-broken`, `-line-duotone`, `-bold-duotone`), and an exact name such as `solar:bomb-bold-duotone` is also accepted.
- `family:name` falls back to the built-in names and aliases when the family does not know the name (for example `solar:combat` and `solar:movement`).
- The icon renderer now supports spritesheet icons (`ImageRectOffset` and `ImageRectSize`) and layered icons.
- Expanded the built-in local set to about 180 icons and 220 aliases, with names made for script hubs: `farm`, `combat`, `movement`, `esp`, `fly`, `weapons`, `sword`, `cards`, `fire`, `player`, `quest`, `teleport`, `map`, `inventory`, `items`, `pets`, `npc`, `script`, `developer`, `ui` and `settings`.
- Kept compatibility with `Icon = "home"`, `Icon = Zeta.Icons.Home`, custom providers (`Zeta:RegisterIconProvider` and `Zeta:SetIconProvider`), image and url icons, and hot swap (`Tab:SetIcon`, `Component:SetIcon`).

### Fixes

- Fixed stray outlined squares appearing over the window after opening dropdowns and color pickers. Popup frames are now destroyed when they close.
- Fixed icon definitions that used a reserved Lua word as a table key, which prevented the icon module from loading.
- Fixed icon aliases that pointed to icons that did not exist, and an alias that hid the real `crop` icon.

### Docs

- New documentation site with a Quick Start, an interactive "Try ZetaPro" playground, a FAQ and a Discord link.
- New Keybinds page covering the default key, callback, rebinding, changing the key at runtime, disabling and removing, supported keys, and the window key.
- Rewrote the Icons page: families, Solar variants, icons for script hubs, `Zeta.Icons:Get()`, `Zeta.Icons:List()`, custom providers, image icons, remote icons, hot swap, credits and compatibility.
- The documentation is now focused on executors.
- README credits now include Footagesus/Icons and the license of the icon system.

## ZetaPro v1.0.0

Initial public release.

- Window system (drag, resize, minimize/restore, responsive layout, acrylic with fallback)
- Tabs
- Sections
- Buttons
- Toggles
- Sliders
- Dropdowns
- MultiDropdown
- Inputs
- Keybinds
- Colorpickers
- Paragraph, Label, Divider
- Dialogs
- Tooltips
- Notifications
- Themes (Dark, Light, Midnight, Zeta, custom) with hot swap
- Icons (built-in Lucide-style set, image/url icons, provider system)
- Search
- Acrylic
- Config system (state, export/import, optional persistence)
- Capability detection
- Component registry for custom components
