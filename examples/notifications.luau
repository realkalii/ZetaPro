-- Notifications: types, stacking, manual close, persistence.
local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/realkalii/ZetaPro/main/src/init.luau"))()

local Window = Zeta:CreateWindow({ Title = "Notifications", SubTitle = "Demo" })
local Tab = Window:AddTab({ Title = "Notify", Icon = "bell" })

for _, kind in { "Info", "Success", "Warning", "Error" } do
	Tab:AddButton({
		Title = kind,
		Description = "Show a " .. string.lower(kind) .. " notification",
		Callback = function()
			Zeta:Notify({ Title = kind, Content = "This is a " .. string.lower(kind) .. " message.", Type = kind, Duration = 4 })
		end,
	})
end

local Persistent
Tab:AddButton({
	Title = "Persistent",
	Description = "Stays until closed",
	Callback = function()
		Persistent = Zeta:Notify({ Title = "Pinned", Content = "Close me manually.", Duration = 0 })
	end,
})
Tab:AddButton({
	Title = "Close persistent",
	Callback = function()
		if Persistent then
			Persistent:Close()
		end
	end,
})
Tab:AddButton({
	Title = "Flood (stacking limit)",
	Callback = function()
		for index = 1, 8 do
			Zeta:Notify({ Title = "Notification " .. index, Duration = 5 })
		end
	end,
})
