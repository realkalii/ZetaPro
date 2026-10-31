# Slider

```lua
local Slider = Tab:AddSlider("Intensity", {
    Title = "Intensity",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,   -- optional step
    Rounding = 0,    -- decimals (defaults to 2 if Increment is fractional, else 0)
    Callback = function(value)
        Zeta:Notify({ Title = "Intensity", Content = value .. "%", Type = "Info" })
    end,
})
```
Drag the bar (mouse or touch) or type a number in the value box. Values are clamped, snapped to `Increment` and rounded.
`Slider:SetValue(n)`, `Slider:GetValue()`, `Slider:OnChanged(fn)`.
