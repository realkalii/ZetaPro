# Window

```lua
local Window = Zeta:CreateWindow({
    Title = "ZETA Pro",          -- string
    SubTitle = "V1.0",           -- string?
    Icon = "terminal",           -- icon?
    Size = UDim2.fromOffset(520, 380),   -- initial size (offsets are used)
    TabWidth = 160,              -- sidebar width (collapses below ~500px window width)
    MinSize = Vector2.new(420, 320),
    MaxSize = Vector2.new(1000, 800),
    Theme = "Dark",
    Acrylic = true,              -- translucent surface (+ blur when supported)
    Blur = true,                 -- set false to keep acrylic transparency without screen blur
    Resize = false,              -- show a resize grip
    CloseButton = false,         -- show an X button (calls OnClose then Destroy)
    OnClose = function() end,
    SearchEnabled = true,
    MinimizeKey = Enum.KeyCode.RightShift,
})
```

| Method | Description |
|---|---|
| `Window:AddTab(config)` | Returns a Tab |
| `Window:SelectTab(tab \| index \| title)` | Selects a tab |
| `Window:SetTitle(text)` / `SetSubtitle(text)` | Update the header |
| `Window:SetTheme(name)` | Same as `Zeta:SetTheme` |
| `Window:SetSearchEnabled(bool)` | Show/hide global search |
| `Window:SetAcrylic(bool)` | Toggle acrylic live |
| `Window:SetMinimizeKey(key \| nil)` | Rebind the hotkey |
| `Window:CreateDialog({ Title, Content, Buttons })` | Modal dialog |
| `Window:Destroy()` | Releases everything created by the window |
| `Window.Options` | `{ [id] = component }` |
| `Window.OnDestroy` | Signal fired before cleanup |

The floating restore control is always available when minimized. The window is draggable from the top bar, clamps itself to the viewport, and works with mouse, keyboard and touch. Acrylic blur uses `BlurEffect`, which is screen-wide; it is skipped automatically when the environment does not allow it.
