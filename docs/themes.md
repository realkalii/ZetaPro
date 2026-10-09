# Themes

Built in: `Dark`, `Light`, `Midnight`, `Zeta`, and `Pure Red`. `Halloween 2026` is a limited theme scheduled for removal after Halloween 2026.

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
Tokens: `Background, SecondaryBackground, TertiaryBackground, Text, MutedText, Accent, AccentText, Border, Hover, Pressed, Success, Warning, Error, Info, Overlay` (Color3) and `AcrylicTransparency`, `ElementTransparency`, `ComponentTransparency`, `ComponentStrokeTransparency` (numbers). Missing tokens fall back to defaults; a wrongly typed token raises an error.

Every component binds to tokens, so `SetTheme` updates all existing UI instantly. `Zeta:SetFont(Enum.Font.Gotham)` and `Zeta:SetScale(0.9)` also apply live.
