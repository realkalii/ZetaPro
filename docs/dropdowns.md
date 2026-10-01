# Dropdown and MultiDropdown

```lua
local Mode = Tab:AddDropdown("Mode", {
    Title = "Mode",
    Values = { "Legit", "Rage", "Silent" },
    Multi = false,
    Default = 1,           -- index or value name
    Callback = function(value) print(value) end,
})

local Targets = Tab:AddDropdown("Targets", {   -- or Tab:AddMultiDropdown(...)
    Title = "Targets",
    Values = { "Players", "NPCs", "Bosses" },
    Multi = true,
    Default = { Players = true },              -- map or array of names
    Callback = function(map) print(map.Players, map.NPCs, map.Bosses) end,
})
```
Multi values are always returned as a full map: `{ Players = true, NPCs = false, Bosses = true }`.

| Method | Description |
|---|---|
| `SetValues(values)` | Replace the options; invalid selections are dropped |
| `SetValue(value)` | Single: name or index. Multi: map or array |
| `GetValue()` | Single: string or nil. Multi: map |
