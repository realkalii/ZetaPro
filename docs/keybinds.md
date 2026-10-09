# Keybind

```lua
local Enabled = false
local Keybind = Tab:AddKeybind("ActionKey", {
    Title = "Toggle Action",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        Enabled = not Enabled
        print("Action enabled:", Enabled)
    end,
    ChangedCallback = function(key) print("rebound", key) end,
})
```
Click the button, then press a key or mouse button 2/3. `Esc` cancels, `Backspace` clears, a left click cancels, right-click on the button resets to the default. Binding a key already used by another bind shows a warning notification.

`Keybind:SetValue(keyOrName)`, `GetValue()`, `Reset()`, `OnClick(fn)`, `OnChanged(fn)`.
All keybinds share one input pipeline (`Services/Input`).
