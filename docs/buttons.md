# Button

```lua
local Button = Tab:AddButton({
    Title = "Execute",
    Description = "Execute something",
    Icon = "play",
    Tooltip = "Runs once",
    Callback = function() print("Hello") end,
})
```
Supports hover, pressed and disabled states.

| Method | Description |
|---|---|
| `Button:Fire()` | Run the callback from code |
| `Button:SetCallback(fn)` | Replace the callback |
| `SetTitle`, `SetDescription`, `SetIcon`, `SetTooltip`, `SetVisible`, `SetEnabled`, `Destroy` | Shared lifecycle API |
