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
| `Zeta:GetVersion()` | string | `"1.0.3"` |
| `Zeta:GetStats()` | `{Windows, Binds, Guis, Notifications}` | For tests |
| `Zeta:Unload()` | | Destroys everything |

Fields: `Zeta.Icons`, `Zeta.Config`, `Zeta.State`, `Zeta.Signal`, `Zeta.Capabilities`, `Zeta.Component`.

## Window:AddTab(config)
Parameters: `Title: string`, `Icon: string?` (or icon table). Returns: `Tab`.

## Tab / Section
`AddSection(title, options?) -> Section`; `Add<Component>([id], config) -> Component`; `Select()`, `Deselect()`, `SetTitle(text)`, `SetIcon(icon)`, `Destroy()`. Section options are `Collapsible` and `DefaultExpanded`. Sections also support `IsExpanded()`, `Expand()`, `Collapse()`, `Toggle()`, `SetTitle(text)`, `SetVisible(bool)`, and `Destroy()`.

## Components (shared)
`GetValue()`, `SetValue(v)`, `OnChanged(fn) -> Connection`, `SetTitle(text)`, `SetDescription(text)`, `SetIcon(icon \| nil)`, `SetVisible(bool)`, `SetEnabled(bool)`, `SetTooltip(text)`, `Destroy()`.
Shared config fields: `Title`, `Description`, `Icon`, `Tooltip`, `SearchKeywords`, `Visible`, `Enabled`. Paragraph, Label, and Divider have their own narrower configs.

| Component | Config | Extra methods |
|---|---|---|
| Button | `Callback`, `ButtonText` | `Fire`, `SetCallback`, `SetButtonText` |
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
`Register(key, default)`, `Set(key, value)`, `Get(key)`, `Has(key)`, `Export() -> table`, `Import(table)`, `Reset()`, `Wipe()`, `Serialize() -> json`, `Deserialize(json)`, `Save(name)`, `Load(name)` (the last two need `Capabilities.FileSystem` and return `false, reason` otherwise), `Changed` signal. Supported values: boolean, number, string, Color3, Enum items, tables.

## Zeta.Capabilities
`Http`, `FileSystem`, `Clipboard`, `Touch`, `Keyboard`, `Drawing`, `GetExecutorName()`, and `SetClipboard(text)`. File and clipboard operations depend on executor support.

## Zeta.Signal
`Signal.new()`, `:Connect(fn)`, `:Once(fn)`, `:Fire(...)`, `:Destroy()`.

## Custom components

`Zeta:RegisterComponent(name, factory)` registers `Tab:Add<Name>` and `Section:Add<Name>`. A factory receives the component context, optional id, and config. Use `Zeta.Component.New(ctx, class, kind, id, config, layout)` for the shared component lifecycle; see the built-in components for a complete factory pattern.
