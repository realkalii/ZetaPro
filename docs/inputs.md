# Input

```lua
local Input = Tab:AddInput("Username", {
    Title = "Username",
    Description = "Enter a username",
    Default = "",
    Placeholder = "Username...",
    MaxLength = 20,
    Numeric = false,
    Live = false,                         -- true: update on every keystroke
    Validate = function(text) return #text >= 3 end,
    Callback = function(value) print(value) end,
})
```
The value is committed when the box loses focus (or on every change with `Live`). Invalid text is reverted and the border flashes red. A clear button appears when the box has text.
