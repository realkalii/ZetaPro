# Notifications

```lua
local note = Zeta:Notify({
    Title = "Success",
    Content = "Settings saved.",
    Type = "Success",     -- Info | Success | Warning | Error
    Duration = 4,         -- seconds; 0 keeps it until closed
    Icon = nil,           -- override the type icon
    Progress = true,      -- progress bar while a duration runs
    Closable = true,
})
note:Close()
note.Closed:Connect(function() end)
```
Notifications stack at the bottom-right and follow the active theme and scale. The visible limit is at most five and decreases on shorter viewports; the oldest notification closes first.

`Type` accepts `Info`, `Success`, `Warning`, or `Error`. The returned notification supports `Close()` and a `Closed` signal. `Duration = 0` keeps it visible until it is closed.
