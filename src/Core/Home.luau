return function(import)
	local Players = game:GetService("Players")
	local MarketplaceService = game:GetService("MarketplaceService")
	local Utility = import("Core/Utility")
	local Widgets = import("Core/Widgets")
	local Theme = import("Core/Theme")
	local Icons = import("Icons/Icon")
	local Capabilities = import("Core/Capabilities")
	local Design = import("Core/Design")
	local Notification = import("Services/Notification")
	local Tab = import("Core/Tab")

	local Home = {}

	local function inviteFrom(config)
		if type(config) ~= "table" or type(config.Invite) ~= "string" then
			return nil
		end
		local url = string.match(config.Invite, "^%s*(https://[%w_%.%-/]+)%s*$")
		if not url then return nil end
		if not string.match(url, "^https://discord%.gg/[A-Za-z0-9%-_]+/?$")
			and not string.match(url, "^https://discord%.com/invite/[A-Za-z0-9%-_]+/?$") then
			return nil
		end
		return url
	end

	local function text(cleanup, parent, value, y, size, color, bold)
		return Widgets.Text(cleanup, {
			Parent = parent, Text = value, TextSize = size or 12, Bold = bold,
			Color = color or "Text", TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(0, y), Size = UDim2.new(1, 0, 0, (size or 12) + 4),
		})
	end

	local function card(cleanup, parent, name, height)
		local frame = Widgets.Surface(cleanup, {
			Name = name, Parent = parent, Fill = "SecondaryBackground",
			Stroke = "Border", Transparency = "ComponentTransparency",
			Radius = Design.Radius.Card, Size = UDim2.new(1, 0, 0, height),
		})
		return frame
	end

	function Home.Create(window, config)
		local tab = Tab.new(window, { Title = "Home", Icon = "home" })
		tab.IsHome = true
		tab.Button.LayoutOrder = 0
		tab:_SetCompact(true)
		window:SelectTab(tab)
		local cleanup = tab.Cleanup
		local page = tab.Page
		local player = Players.LocalPlayer

		local profile = card(cleanup, page, "Profile", 76)
		profile.LayoutOrder = 1
		local avatarBackdrop = Widgets.Surface(cleanup, {
			Name = "AvatarFallback", Parent = profile, Fill = "TertiaryBackground", Radius = "Full",
			Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(54, 54),
		})
		Widgets.Text(cleanup, {
			Parent = avatarBackdrop, Text = "?", Bold = true, TextSize = 22,
			TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1),
		})
		local avatar = Utility.Create("ImageLabel", {
			Name = "Avatar", BackgroundTransparency = 1,
			Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(54, 54),
			Parent = profile,
		})
		Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = avatar })
		local display = text(cleanup, profile, player and player.DisplayName or "Player unavailable", 14, 15, "Text", true)
		display.Position = UDim2.fromOffset(74, 14)
		display.Size = UDim2.new(1, -104, 0, 21)
		local username = text(cleanup, profile, player and ("@" .. player.Name) or "Unavailable", 39, 12, "MutedText")
		username.Position = UDim2.fromOffset(74, 39)
		username.Size = UDim2.new(1, -104, 0, 18)
		if player then
			cleanup:Add(task.spawn(function()
				local ok, url = pcall(function()
					return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				end)
				if ok and type(url) == "string" and url ~= "" and avatar.Parent then avatar.Image = url end
			end))
		end
		Icons.Create(profile, "chevron-right", {
			Size = 14, Color = "MutedText", Cleanup = cleanup,
			Position = UDim2.new(1, -23, 0.5, -7),
		})

		local metrics = Utility.Create("Frame", {
			Name = "Metrics", BackgroundTransparency = 1, LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 154), Parent = page,
		})
		local fields = {
			{ "Time", "clock", "Unavailable" },
			{ "Executor", "layers", Capabilities.GetExecutorName() },
			{ "Game", "gamepad-2", "Unavailable" },
			{ "Players", "users", "Unavailable" },
			{ "Ping", "wifi", "Unavailable" },
		}
		local values = {}
		for index, field in fields do
			local tile = card(cleanup, metrics, field[1], 46)
			local wide = index == 5
			local col = (index - 1) % 2
			local row = math.floor((index - 1) / 2)
			tile.Size = UDim2.new(wide and 1 or 0.5, wide and 0 or -4, 0, 46)
			tile.Position = UDim2.new(wide and 0 or col * 0.5, wide and 0 or col * 4, 0, row * 54)
			Icons.Create(tile, field[2], { Size = 17, Position = UDim2.fromOffset(11, 14), Color = "Accent", Cleanup = cleanup })
			local label = text(cleanup, tile, field[1], 6, 10, "MutedText")
			label.Position = UDim2.fromOffset(36, 6)
			label.Size = UDim2.new(1, -44, 0, 15)
			local value = text(cleanup, tile, field[3], 23, 12, "Text", true)
			value.Position = UDim2.fromOffset(36, 23)
			value.Size = UDim2.new(1, -44, 0, 17)
			values[field[1]] = value
		end

		local invite = inviteFrom(config.Discord)
		if invite then
			local discord = card(cleanup, page, "Discord", 58)
			discord.LayoutOrder = 3
			local badge = Widgets.Surface(cleanup, {
				Name = "DiscordMark", Parent = discord, Radius = 8,
				Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(10, 12),
			})
			badge.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
			local shape = Widgets.Surface(cleanup, {
				Parent = badge, Radius = 7, Size = UDim2.fromOffset(22, 13),
				Position = UDim2.fromOffset(6, 11),
			})
			shape.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			for _, x in { 6, 13 } do
				local eye = Widgets.Surface(cleanup, { Parent = shape, Radius = "Full", Size = UDim2.fromOffset(3, 4), Position = UDim2.fromOffset(x, 4) })
				eye.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
			end
			local title = text(cleanup, discord, "Discord", 9, 13, "Text", true)
			title.Position = UDim2.fromOffset(52, 9)
			title.Size = UDim2.new(1, -133, 0, 18)
			local subtitle = text(cleanup, discord, "Community invite", 28, 11, "MutedText")
			subtitle.Position = UDim2.fromOffset(52, 28)
			subtitle.Size = UDim2.new(1, -133, 0, 16)
			local copy = Widgets.Surface(cleanup, {
				Class = "TextButton", Name = "CopyInvite", Parent = discord,
				Fill = "TertiaryBackground", Stroke = "Border", Radius = 9,
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -9, 0.5, 0),
				Size = UDim2.fromOffset(68, 32), Text = "Copy", TextSize = 12,
			})
			Theme.Bind(copy, { TextColor3 = "Text" }, cleanup)
			cleanup:Add(copy.Activated:Connect(function()
				local copied = Capabilities.SetClipboard(invite)
				Notification.Notify({
					Type = copied and "Success" or "Warning", Title = copied and "Copied" or "Clipboard unavailable",
					Content = copied and "Discord invite copied." or "Your executor does not support copying this invite."
				})
			end))
		end

		local function refresh()
			local okTime, time = pcall(os.date, "%X")
			values.Time.Text = okTime and time or "Unavailable"
			local okMax, maximum = pcall(function() return Players.MaxPlayers end)
			values.Players.Text = string.format("%d / %s", #Players:GetPlayers(), okMax and tostring(maximum) or "?")
			if player then
				local okPing, ping = pcall(function() return player:GetNetworkPing() end)
				values.Ping.Text = okPing and type(ping) == "number" and string.format("%d ms", math.floor(ping * 1000 + 0.5)) or "Unavailable"
			end
		end
		refresh()
		local updater = task.spawn(function()
			while not cleanup:IsCleaned() do
				task.wait(15)
				if not cleanup:IsCleaned() then refresh() end
			end
		end)
		cleanup:Add(updater)
		if game.PlaceId > 0 then
			cleanup:Add(task.spawn(function()
				local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
				if ok and type(info) == "table" and type(info.Name) == "string" and values.Game.Parent then
					values.Game.Text = info.Name
				end
			end))
		end
		return tab
	end

	return Home
end
