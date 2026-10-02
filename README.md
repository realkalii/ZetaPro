<div align="center">

![ZETA Pro](assets/screenshots/preview.png)

**A dark, modular UI library for Roblox executors.**

![Version](https://img.shields.io/badge/version-1.0.0-white?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square)
![Luau](https://img.shields.io/badge/Luau-typed-blue?style=flat-square)

</div>

---

## Features

- Window with drag, resize, minimize/restore and global search
- Tabs, sections and a compact sidebar on smaller windows
- Button, Toggle, Slider, Dropdown, MultiDropdown, Input, Keybind, Colorpicker, Label, Divider
- Theme engine with hot swap — Dark, Light, Midnight, Zeta, and custom themes
- Built-in icon set, image/url icons and replaceable providers
- Notifications with stacking, progress bar and manual close
- Acrylic effect with graceful fallback
- Config export, import and reset — never assumes `writefile`
- Full cleanup on `Window:Destroy()`

## Installation

```lua
local Zeta = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/realkalii/ZetaPro/main/src/init.luau"
))()
```

## Usage

[Example Script](examples/basic.luau) — [Full API](docs/api.md)

## Credits

- [dawid-scripts/Fluent](https://github.com/dawid-scripts/Fluent) — UX, component set and API shape inspiration
- [Lucide](https://lucide.dev) / [Feather](https://feathericons.com) — icon style inspiration (24x24 grid, round-capped strokes). Icons were drawn from scratch as Roblox Frames, no SVG data included

