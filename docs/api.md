# API reference

## Zeta
| Method | Returns | Notes |
|---|---|---|
| `Zeta:CreateWindow(config)` | Window | See `window.md` |
| `Zeta:SetTheme(name)` | boolean | Hot swap |
| `Zeta:GetTheme()` / `GetThemes()` | string / {string} | |
| `Zeta:RegisterTheme(name, tokens)` | | `Base` supported |
| `Zeta:SetIconProvider(name)` | boolean | |
| `Zeta:RegisterIconProvider(name, resolve)` | | `resolve(name) -> spec?` |
| `Zeta:Notify(config)` | Notification | |
| `Zeta:SetFont(font)` | | `Enum.Font` or `Font` |
| `Zeta:SetScale(n)` | | 0.5 to 2 |
| `Zeta:RegisterComponent(name, factory)` | | Adds `Tab:Add<Name>` |
| `Zeta:SetDebug(bool)` | | Verbose logs |
| `Zeta:GetVersion()` | string | `"1.0.0"` |
| `Zeta:GetStats()` | `{Windows, Binds, Guis, Notifications}` | For tests |
| `Zeta:Unload()` | | Destroys everything |

Fields: `Zeta.Icons`, `Zeta.Config`, `Zeta.State`, `Zeta.Signal`, `Zeta.Capabilities`, `Zeta.Component`.

## Window:AddTab(config)
Parameters: `Title: string`, `Icon: string?` (or icon table). Returns: `Tab`.

## Tab / Section
`AddSection(title) -> Section`; `Add<Component>([id], config) -> Component`; `Select()`, `Deselect()`, `SetTitle(text)`, `SetIcon(icon)`, `Destroy()`.

## Components (shared)
`GetValue()`, `SetValue(v)`, `OnChanged(fn) -> Connection`, `SetTitle(text)`, `SetDescription(text)`, `SetIcon(icon \| nil)`, `SetVisible(bool)`, `SetEnabled(bool)`, `SetTooltip(text)`, `Destroy()`.
Config fields accepted by all: `Title`, `Description`, `Icon`, `Tooltip`, `Visible`, `Enabled`.

| Component | Config | Extra methods |
|---|---|---|
| Button | `Callback` | `Fire`, `SetCallback` |
| Toggle | `Default: boolean`, `Callback(bool)` | |
| Slider | `Min, Max, Default, Increment, Rounding, Callback(number)` | |
| Dropdown | `Values, Multi, Default, Callback(value \| map)` | `SetValues` |
| Input | `Default, Placeholder, MaxLength, Numeric, Live, Validate, Callback(string)` | `SetPlaceholder`, `Focus` |
| Keybind | `Default, Callback(key), ChangedCallback(key)` | `Reset`, `OnClick` |
| Colorpicker | `Default, Transparency, Callback(color, transparency)` | `GetTransparency`, `SetTransparency`, `GetHex`, `Copy`, `Reset` |
| Paragraph | `Title, Content, Icon, RichText` | `SetContent` |
| Label | `Text, Icon` | `SetText` |
| Divider | none | |

## Zeta.State
`State.new(initial)`, `:Get()`, `:Set(value)`, `:OnChanged(fn)`, `:Destroy()`.
UI state lives inside components; application state lives in `Zeta.Config` (bound by component id); persistence is separate and optional.

## Zeta.Config
`Set(key, value)`, `Get(key)`, `Has(key)`, `Export() -> table`, `Import(table)`, `Reset()`, `Serialize() -> json`, `Deserialize(json)`, `Save(name)`, `Load(name)` (the last two need `Capabilities.FileSystem` and return `false, reason` otherwise), `Changed` signal. Supported values: boolean, number, string, Color3, Enum items, tables.

## Zeta.Capabilities
`Http`, `FileSystem`, `Clipboard`, `Touch`, `Keyboard`, `Drawing`. Everything optional degrades gracefully.

## Zeta.Signal
`Signal.new()`, `:Connect(fn)`, `:Once(fn)`, `:Fire(...)`, `:Destroy()`.

## Custom components
```lua
Zeta:RegisterComponent("Stepper", function(ctx, id, config)
    local self = Zeta.Component.New(ctx, MyClass, "Stepper", id, config, { RightWidth = 90 })
    -- build UI inside self.Right, register everything in self.Cleanup
    return self
end)
Tab:AddStepper("Count", { Title = "Count" })
```
