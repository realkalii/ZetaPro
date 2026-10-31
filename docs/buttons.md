# Button

```lua
local Button = Tab:AddButton({
    Title = "Check status",
    Description = "Show the current interface status",
    Icon = "play",
    Tooltip = "Runs once",
    Callback = function()
        Zeta:Notify({ Title = "Interface ready", Type = "Success" })
    end,
})
```
Supports hover, pressed and disabled states.
The entire row is clickable and shows a small chevron. `ButtonText` and `SetButtonText(text)` remain accepted for compatibility, but the current button does not render that text.

| Method | Description |
|---|---|
| `Button:Fire()` | Run the callback from code |
| `Button:SetCallback(fn)` | Replace the callback |
| `Button:SetButtonText(text)` | Store the legacy button text value; it is not rendered by the current row |
| `SetTitle`, `SetDescription`, `SetIcon`, `SetTooltip`, `SetVisible`, `SetEnabled`, `Destroy` | Shared lifecycle API |
