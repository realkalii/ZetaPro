return function(import)
	local Players = game:GetService("Players")
	local MarketplaceService = game:GetService("MarketplaceService")
	local Utility = import("Core/Utility")
	local Widgets = import("Core/Widgets")
	local Theme = import("Core/Theme")
	local Animation = import("Services/Animation")
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
		tab:_SetCompact(window._compact)
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
		display.Size = UDim2.new(1, -84, 0, 21)
		local username = text(cleanup, profile, player and ("@" .. player.Name) or "Unavailable", 39, 12, "MutedText")
		username.Position = UDim2.fromOffset(74, 39)
		username.Size = UDim2.new(1, -84, 0, 18)
		if player then
			cleanup:Add(task.spawn(function()
				local ok, url = pcall(function()
					return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				end)
				if ok and type(url) == "string" and url ~= "" and avatar.Parent then avatar.Image = url end
			end))
		end
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
			local discordFallback = Icons.Create(discord, "messages-square", {
				Size = 27, Position = UDim2.fromOffset(13, 15),
				Color = Color3.fromRGB(88, 101, 242), Cleanup = cleanup,
			})
			local discordImage = Utility.Create("ImageLabel", {
				Name = "DiscordLogo", Parent = discord, BackgroundTransparency = 1,
				Image = "rbxassetid://18505728250", ImageColor3 = Color3.new(1, 1, 1),
				ImageTransparency = 1, ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromOffset(32, 32), Position = UDim2.fromOffset(10, 13),
			})
			local function updateDiscordImage()
				if cleanup:IsCleaned() or not discordImage.Parent then return end
				discordImage.ImageTransparency = discordImage.IsLoaded and 0 or 1
				discordFallback.Instance.Visible = not discordImage.IsLoaded
			end
			cleanup:Add(discordImage:GetPropertyChangedSignal("IsLoaded"):Connect(updateDiscordImage))
			updateDiscordImage()
			cleanup:Add(task.spawn(function()
				pcall(function()
					game:GetService("ContentProvider"):PreloadAsync({ discordImage })
				end)
				updateDiscordImage()
			end))
			local title = text(cleanup, discord, "Discord", 9, 13, "Text", true)
			title.Position = UDim2.fromOffset(52, 9)
			title.Size = UDim2.new(1, -150, 0, 18)
			local subtitle = text(cleanup, discord, "Community invite", 28, 11, "MutedText")
			subtitle.Position = UDim2.fromOffset(52, 28)
			subtitle.Size = UDim2.new(1, -150, 0, 16)
			local copy, copyStroke = Widgets.Surface(cleanup, {
				Class = "TextButton", Name = "CopyInvite", Parent = discord,
				BackgroundColor3 = Color3.new(1, 1, 1),
				Transparency = "ElementTransparency", Stroke = "Border", Radius = 10,
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -9, 0.5, 0),
				Size = UDim2.fromOffset(84, 30),
			})
			local gradient = Utility.Create("UIGradient", { Rotation = 35, Parent = copy })
			Icons.Create(copy, "copy", {
				Size = 14, Position = UDim2.fromOffset(10, 8), Color = "Text", Cleanup = cleanup,
			})
			Widgets.Text(cleanup, {
				Parent = copy, Text = "Copy", TextSize = 11, Bold = true,
				Position = UDim2.fromOffset(31, 0), Size = UDim2.new(1, -35, 1, 0),
			})
			local hover, pressed = false, false
			local function paint(instant)
				local alpha = math.clamp((Theme.Get("ElementTransparency") or 0.26) - (pressed and 0.1 or hover and 0.05 or 0), 0.14, 0.55)
				local borderAlpha = pressed and 0.25 or hover and 0.4 or 0.6
				local offset = Vector2.new(pressed and 0.1 or hover and 0.05 or 0, 0)
				if instant then
					Animation:Cancel(copy)
					Animation:Cancel(copyStroke)
					Animation:Cancel(gradient)
					copy.BackgroundTransparency = alpha
					copyStroke.Transparency = borderAlpha
					gradient.Offset = offset
				else
					Animation:Play(copy, { BackgroundTransparency = alpha }, { Duration = 0.15 })
					Animation:Play(copyStroke, { Transparency = borderAlpha }, { Duration = 0.15 })
					Animation:Play(gradient, { Offset = offset }, { Duration = 0.15 })
				end
			end
			Theme.BindFn(function()
				local base = Theme.Get("TertiaryBackground")
				gradient.Color = ColorSequence.new(base, base:Lerp(Theme.Get("Accent"), 0.14))
				paint(true)
			end, cleanup)
			cleanup:Add(copy.MouseEnter:Connect(function()
				hover = true
				paint(false)
			end))
			cleanup:Add(copy.MouseLeave:Connect(function()
				hover, pressed = false, false
				paint(false)
			end))
			cleanup:Add(copy.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					pressed = true
					paint(false)
				end
			end))
			cleanup:Add(copy.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					pressed = false
					if input.UserInputType == Enum.UserInputType.Touch then hover = false end
					paint(false)
				end
			end))
			cleanup:Add(copy.Activated:Connect(function()
				local copied = Capabilities.SetClipboard(invite)
				Notification.Notify({
					Type = copied and "Success" or "Warning", Title = copied and "Copied" or "Clipboard unavailable",
					Content = copied and "Discord invite copied." or "Your executor does not support copying this invite."
				})
			end))
		end

		local function refreshTime()
			local okTime, time = pcall(os.date, "%X")
			values.Time.Text = okTime and time or "Unavailable"
		end
		local function refreshPlayers(changedPlayer, leaving)
			local players = Players:GetPlayers()
			local count = #players
			if changedPlayer then
				local included = table.find(players, changedPlayer) ~= nil
				if leaving and included then count -= 1 end
				if not leaving and not included then count += 1 end
			end
			local okMax, maximum = pcall(function() return Players.MaxPlayers end)
			values.Players.Text = string.format("%d / %s", count, okMax and tostring(maximum) or "?")
		end
		local function refreshPing()
			if player then
				local okPing, ping = pcall(function() return player:GetNetworkPing() end)
				values.Ping.Text = okPing and type(ping) == "number" and string.format("%d ms", math.floor(ping * 1000 + 0.5)) or "Unavailable"
			end
		end
		refreshTime()
		refreshPlayers()
		refreshPing()
		cleanup:Add(Players.PlayerAdded:Connect(function(joined)
			refreshPlayers(joined, false)
		end))
		cleanup:Add(Players.PlayerRemoving:Connect(function(leaving)
			refreshPlayers(leaving, true)
		end))
		local updater = task.spawn(function()
			local elapsed = 0
			while not cleanup:IsCleaned() do
				task.wait(1)
				if cleanup:IsCleaned() then break end
				refreshTime()
				elapsed += 1
				if elapsed >= 5 then
					elapsed = 0
					refreshPing()
				end
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
