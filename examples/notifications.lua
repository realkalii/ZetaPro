local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/realkalii/ZetaPro/beta/src/init.luau"))()

local Window = Zeta:CreateWindow({ Title = "Notifications", SubTitle = "Status center" })
local Tab = Window:AddTab({ Title = "Status", Icon = "bell" })

for _, kind in { "Info", "Success", "Warning", "Error" } do
	Tab:AddButton({
		Title = kind,
		Description = "Show a " .. string.lower(kind) .. " notification",
		Callback = function()
			Zeta:Notify({ Title = kind .. " status", Content = "The status center is active.", Type = kind, Duration = 4 })
		end,
	})
end

local Persistent
Tab:AddButton({
	Title = "Pin a notice",
	Description = "Keep a notice visible until it is dismissed.",
	Callback = function()
		Persistent = Zeta:Notify({ Title = "Pinned notice", Content = "This notice remains visible.", Duration = 0 })
	end,
})
Tab:AddButton({
	Title = "Dismiss pinned notice",
	Callback = function()
		if Persistent then
			Persistent:Close()
		end
	end,
})
Tab:AddButton({
	Title = "Preview the stack limit",
	Callback = function()
		for index = 1, 8 do
			Zeta:Notify({ Title = "Notification " .. index, Duration = 5 })
		end
	end,
})
Tab:AddButton({
	Title = "Review notification settings",
	Description = "Confirm a change before showing its result.",
	Callback = function()
		local dialog = Window:CreateDialog({
			Title = "Review status",
			Content = "Show a confirmation notice?",
		})
		dialog:AddButton({ Title = "Keep reviewing" })
		dialog:AddButton({
			Title = "Confirm",
			Primary = true,
			Callback = function()
				Zeta:Notify({ Title = "Review confirmed", Type = "Success" })
			end,
		})
	end,
})
