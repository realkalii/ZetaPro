# Window

```lua
local Window = Zeta:CreateWindow({
    Title = "ZETA Pro",          -- string
    SubTitle = "v1.0.3",
    Icon = "terminal",           -- icon?
    Size = UDim2.fromOffset(720, 510),
    TabWidth = 160,
    MinSize = Vector2.new(560, 360),
    MaxSize = Vector2.new(1000, 800),
    Theme = "Dark",
    CloseButton = true,
    SearchEnabled = true,
    MinimizeKey = Enum.KeyCode.RightShift,
    Discord = { Invite = "https://discord.gg/HCE8KHzzDn" },
})
```

Home is created automatically and shows the player's profile, clock, executor, game, player count, and ping. A valid Discord invite adds a Copy card to Home. Custom tabs appear alongside Home.

The window starts centered and can always be dragged and resized. The resize grip is always enabled; `Resize` is a legacy compatibility field and does not turn it off. Size is saved separately per window when executor file APIs are available and restored on the next run. Saved dimensions take priority over `Size` and are clamped to the configured bounds and viewport. Without file APIs, the configured or default size is used.

Acrylic transparency is always enabled. `Acrylic = false` and `Window:SetAcrylic(false)` do not disable it. The v1.0.3 implementation creates screen blur whenever `BlurEffect` is supported; its accepted `Blur` field is not checked by `Window.luau`, so `Blur = false` does not currently disable blur.

| Method | Description |
|---|---|
| `Window:AddTab(config)` | Returns a Tab |
| `Window:SelectTab(tab \| index \| title)` | Selects a tab |
| `Window:SetTitle(text)` / `SetSubtitle(text)` | Update the header |
| `Window:SetTheme(name)` | Same as `Zeta:SetTheme` |
| `Window:SetSearchEnabled(bool)` | Show/hide global search |
| `Window:SetAcrylic(bool)` | Reapply mandatory acrylic; `false` does not make the window opaque |
| `Window:SetMinimizeKey(key \| nil)` | Rebind the hotkey |
| `Window:CreateDialog({ Title, Content, Buttons })` | Modal dialog |
| `Window:Minimize()` / `Restore()` | Hide or show the window |
| `Window:ToggleMinimize()` / `Toggle()` | Switch between minimized and restored |
| `Window:IsMinimized()` | Return the minimized state |
| `Window:Destroy()` | Releases everything created by the window |
| `Window.Options` | `{ [id] = component }` |
| `Window.OnDestroy` | Signal fired before cleanup |

The floating restore control is available by default when minimized. `RestoreButton = false` is still accepted for compatibility and hides that control. The window clamps to the viewport and supports mouse and touch dragging and resizing. Screen blur uses `BlurEffect`, which is screen-wide and is skipped only when the environment does not allow it.

`CloseButton = false` hides the top-right close control. `OnClose` is called when that control is activated, before the window is destroyed. `Window.MinimizedChanged` and `Window.OnDestroy` are signals for lifecycle changes. `Window:OpenPopup(anchor, width, height)` and `Window:ClosePopup()` manage an anchored popup.
