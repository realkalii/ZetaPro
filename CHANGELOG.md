# Changelog

# ZetaPro v1.0.1 - Early Beta

«This update fixes and cleans up the icon system, removes invalid icons, and improves the documentation.»

Icons

- Fixed and reworked the icon system.
- Added icon families using the "family:name" syntax:
  - "lucide"
  - "solar"
  - "geist"
  - "craft"
  - "sfsymbols"
- Example: "Icon = "solar:bomb"" or "Icon = "geist:code"".
- Icon families are powered by "Footagesus/Icons" (https://github.com/Footagesus/Icons) under the MIT License.
- Families are downloaded in the background and cached locally in "ZetaPro/icons/<family>.lua".
- Only icons that actually exist in each family are now resolved.
- Invalid names such as "solar:sword" no longer resolve to generic drawings and now use the normal fallback.
- Solar variants are supported, including "-linear", "-outline", "-bold", "-broken", "-line-duotone" and "-bold-duotone".
- Exact variants are also supported, such as "solar:bomb-bold-duotone".
- Added support for spritesheet and layered icons.
- Expanded the built-in icon set to around 180 icons and 220 aliases.
- Added icons and aliases commonly useful for script hubs, including "farm", "combat", "movement", "esp", "fly", "weapons", "sword", "cards", "fire", "player", "quest", "teleport", "map", "inventory", "items", "pets", "npc", "script", "developer", "ui" and "settings".
- Kept compatibility with:
  - "Icon = "home""
  - "Icon = Zeta.Icons.Home"
  - Custom icon providers
  - Image and URL icons
  - "Tab:SetIcon()"
  - "Component:SetIcon()"

Fixes

- Fixed the icon module failing to load because of invalid definitions.
- Fixed icon families displaying generic drawings instead of their actual icons.
- Removed invalid icon names and aliases that pointed to icons that do not exist.
- Fixed an alias that was hiding the real "crop" icon.
- Fixed icon definitions that used reserved Lua keywords as table keys.
- Fixed stray outlined squares appearing after opening dropdowns and color pickers.
- Popup frames are now properly destroyed when they close.

Docs

- Updated the documentation site with a new Quick Start, FAQ and Discord link.
- Added a Try ZetaPro playground to the docs.
- «The current Try ZetaPro playground is temporary and will be improved and expanded in a future update.»
- Added a new Keybinds page covering callbacks, rebinding, runtime changes, disabling, removing and supported keys.
- Reworked the Icons documentation with information about icon families, Solar variants, custom providers, image/URL icons, hot swapping and credits.
- Documentation is now focused on executors.
- Updated the README with "Footagesus/Icons" (https://github.com/Footagesus/Icons) credits and license information.

---

ZetaPro v1.0.0

Initial public release.

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
