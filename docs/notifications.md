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
Notifications stack at the bottom-right, are limited to 5 at a time (the oldest closes first) and follow the active theme and scale.
