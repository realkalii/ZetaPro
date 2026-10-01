# Slider

```lua
local Slider = Tab:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Min = 16,
    Max = 250,
    Default = 16,
    Increment = 1,   -- optional step
    Rounding = 0,    -- decimals (defaults to 2 if Increment is fractional, else 0)
    Callback = function(value) print(value) end,
})
```
Drag the bar (mouse or touch) or type a number in the value box. Values are clamped, snapped to `Increment` and rounded.
`Slider:SetValue(n)`, `Slider:GetValue()`, `Slider:OnChanged(fn)`.
