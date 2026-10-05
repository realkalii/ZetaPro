## Changelog

## ZetaPro v1.0.1 - Early Beta

> «This update focuses on cleaning up the icon system, fixing a bunch of issues and improving the documentation.»

### Icons

- Reworked the entire icon system.
- Added support for icon families using the ""family:name"" format:
  - ""lucide""
  - ""solar""
  - ""geist""
  - ""craft""
  - ""sfsymbols""
- Example: "Icon = "solar:bomb"" or "Icon = "geist:code"".
- Family icons are powered by "Footagesus/Icons" (https://github.com/Footagesus/Icons).
- Families are downloaded in the background and cached locally in "ZetaPro/icons/<family>.lua".
- Icons that don't actually exist are no longer treated as valid.
- Invalid names such as "solar:sword" no longer turn into random generic icons.
- Added support for Solar variants such as "-linear", "-outline", "-bold", "-broken", "-line-duotone" and "-bold-duotone".
- You can also request an exact variant, for example "solar:bomb-bold-duotone".
- Added support for spritesheet and layered icons.
- Expanded the built-in icon set to around 180 icons and 220 aliases.
- Added a bunch of useful names for script hubs, including "farm", "combat", "movement", "esp", "fly", "weapons", "sword", "cards", "fire", "player", "quest", "teleport", "map", "inventory", "items", "pets", "npc", "script", "developer", "ui" and "settings".
- Existing icon features still work:
  - "Icon = "home""
  - "Icon = Zeta.Icons.Home"
  - Custom icon providers
  - Image and URL icons
  - "Tab:SetIcon()"
  - "Component:SetIcon()"

### Fixes

- Fixed the icon module failing to load because of invalid definitions.
- Fixed family icons showing generic drawings instead of the actual icon.
- Removed invalid icon names and aliases that pointed to icons that don't exist.
- Fixed an alias that was hiding the actual "crop" icon.
- Fixed icon definitions using reserved Lua keywords as table keys.
- Fixed random outlined squares appearing after opening dropdowns and color pickers.
- Popup frames are now properly cleaned up when they close.

### Docs

- Updated the documentation site with a new Quick Start, FAQ and Discord link.
- Added a Try ZetaPro playground.
- The current Try ZetaPro playground is temporary and will be improved and expanded in a future update.
- Added a new Keybinds page covering callbacks, rebinding, runtime changes, disabling, removing and supported keys.
- Reworked the Icons documentation with the new family system, Solar variants, custom providers, image/URL icons, hot swapping and credits.
- Documentation is now focused on executors.
- Updated the README with "Footagesus/Icons" (https://github.com/Footagesus/Icons) credits.

---

## ZetaPro v1.0.0

*Initial public release.*

- Window system with drag, resize, minimize/restore and responsive layout
- Acrylic with fallback support
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
- Paragraphs
- Labels
- Dividers
- Dialogs
- Tooltips
- Notifications
- Themes with Dark, Light, Midnight, Zeta and custom themes
- Runtime theme switching
- Built-in icons
- Image and URL icons
- Custom icon providers
- Search
- Config system with state, export/import and optional persistence
- Capability detection
- Component registry for custom components
