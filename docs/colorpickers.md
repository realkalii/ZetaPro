# Colorpicker

```lua
local Picker = Tab:AddColorpicker("Accent", {
    Title = "Accent Color",
    Default = Color3.fromRGB(255, 255, 255),
    Transparency = 0,                         -- include to enable the alpha slider
    Callback = function(color, transparency) print(color, transparency) end,
})
```
The panel has a saturation/value square, hue bar, optional alpha bar, hex / RGB / HSV fields, Reset, and Copy HEX (only when the environment has a clipboard).

`SetValue(Color3)`, `GetValue()`, `SetTransparency(n)`, `GetTransparency()`, `GetHex()`, `Copy()`, `Reset()`.
With an id, transparency is stored in `Zeta.Config` under `"<id>/Transparency"`.
