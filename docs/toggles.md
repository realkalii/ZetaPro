# Toggle

```lua
local Toggle = Tab:AddToggle("Alerts", {
    Title = "Release alerts",
    Description = "Show status notifications",
    Default = false,
    Callback = function(value)
        Zeta:Notify({ Title = value and "Alerts on" or "Alerts off", Type = "Info" })
    end,
})
Toggle:SetValue(true)
```
`Default` must be a boolean; anything else raises a `[ZETA][ERROR]`. State is shown by knob position as well as color.
