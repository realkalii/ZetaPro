# Toggle

```lua
local Toggle = Tab:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Description = "Automatically farms resources",
    Default = false,
    Callback = function(value) print(value) end,
})
Toggle:SetValue(true)
print(Toggle:GetValue())
Toggle:OnChanged(function(value) end)
```
`Default` must be a boolean; anything else raises a `[ZETA][ERROR]`. State is shown by knob position as well as color.
