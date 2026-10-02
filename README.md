<div align="center">

# ZETA Pro

**Modern Luau UI Library**

![Version](https://img.shields.io/badge/version-1.0.0-white?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square)
![Luau](https://img.shields.io/badge/Luau-typed-blue?style=flat-square)
![GitHub](https://img.shields.io/badge/GitHub-realkalii%2FZetaPro-black?style=flat-square&logo=github)

</div>

<!-- Add a screenshot after your first test run:
![ZETA Pro](assets/screenshots/preview.png)
-->

ZETA Pro is a minimal, dark, modular UI library for Roblox / Luau. The UX is familiar to anyone who has used Fluent (window, tabs, sections, components, notifications, acrylic), but the implementation, theme system, icon system, animation layer and API are independent. See `THIRD_PARTY.md`.

> **Status:** V1.0 was written without access to a Roblox runtime. Run `examples/tests.luau` in Studio or your executor first and report anything that breaks.

## Features
- Window: drag, optional resize, minimize/restore (hotkey + touch button), search, dialogs, responsive layout, `UIScale` scaling
- Tabs and sections with icons, hover/active states, scrolling and a compact sidebar on small windows
- Components: Button, Toggle, Slider, Dropdown, MultiDropdown, Input, Keybind, Colorpicker (RGB / HSV / hex / transparency), Paragraph, Label, Divider
- Theme engine with hot swap: Dark, Light, Midnight, Zeta, plus your own themes
- Icon system: built-in Lucide-style set, `Zeta.Icons.Home`, image / url icons, replaceable providers
- Notifications: Info / Success / Warning / Error, stacking, limit, progress bar, manual close
- Global search that navigates to and highlights the result
- Acrylic with graceful fallback, tooltips, centralized animations and input
- State + Config: export / import / reset, optional file persistence, never assumes `writefile`
- Capability detection (`Zeta.Capabilities`) and clear `[ZETA][ERROR]` messages
- Full cleanup: `Window:Destroy()` releases every connection, tween, thread and instance
- Extensible: `Zeta:RegisterComponent(name, factory)`

## Installation

**Executor**
```lua
local Zeta = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/realkalii/ZetaPro/main/src/init.luau"
))()
```
Modules are downloaded in parallel and cached for the session. Use `getgenv().ZETA_BASE = "https://.../src/"` to load from a fork or a local server. Re-running the script cleanly unloads the previous instance.

**Roblox Studio (Rojo)**
```lua
local Zeta = require(game.ReplicatedStorage.ZetaPro)
```
Clone the repository, run `rojo serve` (the repo ships `default.project.json`), and require the `src` folder.

## Quick start
```lua
local Window = Zeta:CreateWindow({
    Title = "ZETA Pro",
    SubTitle = "Example",
    Size = UDim2.fromOffset(620, 480),
    Theme = "Dark",
    Acrylic = true,
    MinimizeKey = Enum.KeyCode.RightShift,
})

local Main = Window:AddTab({ Title = "Main", Icon = "home" })

Main:AddButton({
    Title = "Hello",
    Description = "Print hello",
    Callback = function()
        print("Hello from ZETA")
    end,
})

local Toggle = Main:AddToggle("Enabled", {
    Title = "Enabled",
    Default = false,
    Callback = function(value)
        print(value)
    end,
})

Toggle:SetValue(true)
```

## Components
All components share one API: `GetValue`, `SetValue`, `OnChanged`, `SetTitle`, `SetDescription`, `SetIcon`, `SetVisible`, `SetEnabled`, `SetTooltip`, `Destroy`. Add them to a tab or a section; pass an id first to make them part of `Window.Options` and `Zeta.Config`.

| Component | Docs |
|---|---|
| Button | [docs/buttons.md](docs/buttons.md) |
| Toggle | [docs/toggles.md](docs/toggles.md) |
| Slider | [docs/sliders.md](docs/sliders.md) |
| Dropdown / MultiDropdown | [docs/dropdowns.md](docs/dropdowns.md) |
| Input | [docs/inputs.md](docs/inputs.md) |
| Keybind | [docs/keybinds.md](docs/keybinds.md) |
| Colorpicker | [docs/colorpickers.md](docs/colorpickers.md) |

## Themes
```lua
Zeta:SetTheme("Midnight")            -- hot swap, no rebuild
Zeta:RegisterTheme("Mine", { Background = ..., Secondary = ..., Text = ..., MutedText = ..., Accent = ..., Border = ... })
```
See [docs/themes.md](docs/themes.md). Colors are never hardcoded in components.

## Icons
```lua
Main:AddButton({ Title = "Settings", Icon = "settings" })
Main:AddButton({ Title = "Home", Icon = Zeta.Icons.Home })
Main:AddButton({ Title = "Mine", Icon = { Type = "Image", Source = "rbxassetid://..." } })
```
Built-in icons are original line drawings rendered with Frames: no assets, no network, no license obligations. See [docs/icons.md](docs/icons.md).

## Notifications
```lua
local note = Zeta:Notify({ Title = "Success", Content = "Settings saved.", Type = "Success", Duration = 4 })
note:Close()
```
See [docs/notifications.md](docs/notifications.md).

## Examples
`examples/`: `basic`, `complete`, `components`, `themes`, `icons`, `notifications`, `settings`, and `tests` (internal test suite, including 25 create/destroy cycles that check for leaks).

## API
See [docs/api.md](docs/api.md) for every public method.

## Roadmap
- Verified-in-game screenshots and a recorded demo
- Optional bundler script that emits a single-file build
- Keyboard navigation between components
- Per-component search weighting and tags
- More built-in icons and a Lucide spritesheet provider
- Resizable sidebar and collapsible sections

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## License
MIT. A permissive license suits UI libraries: anyone can use, modify and ship it, including in closed-source scripts, as long as the copyright notice stays. Third-party notices: [THIRD_PARTY.md](THIRD_PARTY.md).
