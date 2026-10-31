# Themes

Built in: `Dark`, `Light`, `Midnight`, `Zeta`, `Pure Red`, and `Halloween 2026`. Halloween 2026 is included in v1.0.3.

```lua
Zeta:SetTheme("Midnight")
Zeta:GetTheme()      -- "Midnight"
for _, theme in ipairs(Zeta:GetThemes()) do print(theme) end

Zeta:RegisterTheme("Mine", {
    Base = "Dark",                        -- optional: inherit another theme
    Background = Color3.fromRGB(10, 10, 12),
    Secondary = Color3.fromRGB(18, 18, 20),   -- alias of SecondaryBackground
    Tertiary = Color3.fromRGB(26, 26, 29),    -- alias of TertiaryBackground
    Text = Color3.fromRGB(235, 235, 235),
    MutedText = Color3.fromRGB(140, 140, 146),
    Accent = Color3.fromRGB(120, 200, 255),
    AccentText = Color3.fromRGB(8, 8, 10),
    Border = Color3.fromRGB(40, 40, 44),
})
```
Color tokens: `Background`, `Sidebar`, `SecondaryBackground`, `TertiaryBackground`, `Text`, `MutedText`, `Accent`, `AccentText`, `Border`, `Hover`, `Active`, `HoverSurface`, `PressedSurface`, `Pressed`, `Success`, `Warning`, `Error`, `Info`, and `Overlay`. Transparency tokens: `AcrylicTransparency`, `SidebarTransparency`, `ElementTransparency`, `ComponentTransparency`, and `ComponentStrokeTransparency`. Missing tokens fall back to the base or defaults; a wrongly typed known token raises an error. `Secondary` and `Tertiary` are aliases.

Every component binds to tokens, so `SetTheme` updates all existing UI instantly. `Zeta:SetFont(Enum.Font.Gotham)` and `Zeta:SetScale(0.9)` also apply live.

Every built-in theme retains translucent acrylic surfaces. The v1.0.3 implementation applies screen blur when supported even if `Blur = false` is supplied; see [Window](window.md).
