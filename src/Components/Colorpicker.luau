return function(import)
	local Component = import("Core/Component")
	local Utility = import("Core/Utility")
	local Widgets = import("Core/Widgets")
	local Theme = import("Core/Theme")
	local State = import("Core/State")
	local Config = import("Core/Config")
	local Capabilities = import("Core/Capabilities")
	local Drag = import("Services/Drag")

	local Colorpicker = setmetatable({}, { __index = Component.Base })
	Colorpicker.__index = Colorpicker

	local function to255(value)
		return math.floor(value * 255 + 0.5)
	end

	local function sameColor(a, b)
		return to255(a.R) == to255(b.R) and to255(a.G) == to255(b.G) and to255(a.B) == to255(b.B)
	end

	function Colorpicker:_Normalize(value)
		if typeof(value) == "Color3" then
			return true, value
		end
		return false
	end

	-- Callback(color, transparency)
	function Colorpicker:_Emit(value)
		if self._destroyed then
			return
		end
		local transparency = self.TransparencyState:Get()
		Utility.SafeCall("Colorpicker " .. tostring(self.Id), self.Config.Callback, value, transparency)
		self.Changed:Fire(value, transparency)
	end

	function Colorpicker:GetTransparency()
		return self.TransparencyState:Get()
	end

	function Colorpicker:SetTransparency(value)
		if type(value) == "number" then
			self.TransparencyState:Set(math.clamp(value, 0, 1))
		end
	end

	function Colorpicker:GetHex()
		return Utility.ToHex(self.State:Get())
	end

	function Colorpicker:Copy()
		return Capabilities.SetClipboard(self:GetHex())
	end

	function Colorpicker:Reset()
		self.State:Set(self._default)
		if self._hasAlpha then
			self.TransparencyState:Set(self._defaultAlpha)
		end
	end

	local HUES = {}
	for step = 0, 6 do
		table.insert(HUES, ColorSequenceKeypoint.new(step / 6, Color3.fromHSV(math.min(step / 6, 1), 1, 1)))
	end

	return function(ctx, id, config)
		local default = config.Default or Color3.new(1, 1, 1)
		Utility.Check(typeof(default) == "Color3", "Colorpicker", id, "Default must be a Color3.")
		local hasAlpha = config.Transparency ~= nil
		Utility.Check(not hasAlpha or (type(config.Transparency) == "number" and config.Transparency >= 0 and config.Transparency <= 1), "Colorpicker", id, "Transparency must be a number between 0 and 1.")

		local self = Component.New(ctx, Colorpicker, "Colorpicker", id, config, { RightWidth = 44, RightHeight = 22 })
		local cleanup = self.Cleanup
		self._default, self._hasAlpha, self._defaultAlpha = default, hasAlpha, config.Transparency or 0

		if id then
			self.TransparencyState = Config:Register(id .. "/Transparency", self._defaultAlpha)
		else
			self.TransparencyState = cleanup:Add(State.new(self._defaultAlpha))
		end
		self._h, self._s, self._v = default:ToHSV()

		local swatch = Widgets.Surface(cleanup, {
			Class = "TextButton",
			Name = "Swatch",
			Parent = self.Right,
			Stroke = "Border",
			Radius = 8,
			BackgroundTransparency = 0,
			Size = UDim2.fromScale(1, 1),
		})

		local function paintSwatch()
			swatch.BackgroundColor3 = self.State:Get()
			swatch.BackgroundTransparency = hasAlpha and self.TransparencyState:Get() or 0
		end
		Component.BindValue(self, id, default, function(color)
			if not sameColor(color, Color3.fromHSV(self._h, self._s, self._v)) then
				self._h, self._s, self._v = color:ToHSV()
			end
			paintSwatch()
		end)
		cleanup:Add(self.TransparencyState.Changed:Connect(function()
			if self._destroyed then
				return
			end
			paintSwatch()
			self:_Emit(self.State:Get())
		end))

		cleanup:Add(swatch.Activated:Connect(function()
			if self._destroyed or not self.Enabled then
				return
			end
			local popup = self.Window:OpenPopup(swatch, 232, hasAlpha and 292 or 272)
			self._popup = popup
			local pcl, frame = popup.Cleanup, popup.Frame
			pcl:Add(popup.Closed:Connect(function()
				if self._popup == popup then
					self._popup = nil
				end
			end))

			local hexBox, rBox, gBox, bBox, hBox, sBox, vBox
			local svBase, svCursor, hueCursor, alphaBar, alphaCursor

			local function refresh()
				local color = self.State:Get()
				svBase.BackgroundColor3 = Color3.fromHSV(self._h, 1, 1)
				svCursor.Position = UDim2.fromScale(self._s, 1 - self._v)
				hueCursor.Position = UDim2.fromScale(self._h, 0.5)
				if hasAlpha then
					alphaBar.BackgroundColor3 = color
					alphaCursor.Position = UDim2.fromScale(self.TransparencyState:Get(), 0.5)
				end
				local function put(box, text)
					if not box:IsFocused() then
						box.Text = text
					end
				end
				put(hexBox, Utility.ToHex(color))
				put(rBox, tostring(to255(color.R)))
				put(gBox, tostring(to255(color.G)))
				put(bBox, tostring(to255(color.B)))
				put(hBox, tostring(math.floor(self._h * 360 + 0.5)))
				put(sBox, tostring(math.floor(self._s * 100 + 0.5)))
				put(vBox, tostring(math.floor(self._v * 100 + 0.5)))
			end

			local function apply()
				self.State:Set(Color3.fromHSV(self._h, self._s, self._v))
				refresh()
			end

			local function gradientBar(y, token)
				local bar = Widgets.Surface(pcl, {
					Parent = frame,
					BackgroundTransparency = 0,
					BackgroundColor3 = Color3.new(1, 1, 1),
					Radius = 5,
					Position = UDim2.fromOffset(10, y),
					Size = UDim2.fromOffset(212, 12),
				})
				local hit = Utility.Create("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = bar })
				local cursor = Widgets.Surface(pcl, {
					Parent = bar,
					Fill = "Text",
					Stroke = "Background",
					Radius = 3,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.fromOffset(4, 18),
					ZIndex = 4,
				})
				return bar, hit, cursor
			end

			-- Saturation / value square
			svBase = Widgets.Surface(pcl, {
				Parent = frame,
				BackgroundTransparency = 0,
				Radius = 0,
				ClipsDescendants = true,
				Position = UDim2.fromOffset(10, 10),
				Size = UDim2.fromOffset(212, 112),
			})
			local white = Utility.Create("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), Parent = svBase })
			Utility.Create("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })
			local black = Utility.Create("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.fromScale(1, 1), Parent = svBase })
			Utility.Create("UIGradient", { Transparency = NumberSequence.new(1, 0), Rotation = 90, Parent = black })
			local svHit = Utility.Create("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = svBase })
			svCursor = Widgets.Surface(pcl, {
				Parent = svBase,
				Stroke = "Text",
				Radius = "Full",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(10, 10),
				ZIndex = 4,
			})
			Drag.Track(svHit, pcl, function(position)
				self._s = math.clamp((position.X - svBase.AbsolutePosition.X) / math.max(svBase.AbsoluteSize.X, 1), 0, 1)
				self._v = 1 - math.clamp((position.Y - svBase.AbsolutePosition.Y) / math.max(svBase.AbsoluteSize.Y, 1), 0, 1)
				apply()
			end)

			-- Hue bar
			local hueBar, hueHit
			hueBar, hueHit, hueCursor = gradientBar(130)
			Utility.Create("UIGradient", { Color = ColorSequence.new(HUES), Parent = hueBar })
			Drag.Track(hueHit, pcl, function(position)
				self._h = math.clamp((position.X - hueBar.AbsolutePosition.X) / math.max(hueBar.AbsoluteSize.X, 1), 0, 1)
				apply()
			end)

			local fieldsY = 152
			if hasAlpha then
				local alphaHit
				alphaBar, alphaHit, alphaCursor = gradientBar(150)
				Utility.Create("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = alphaBar })
				Drag.Track(alphaHit, pcl, function(position)
					local alpha = math.clamp((position.X - alphaBar.AbsolutePosition.X) / math.max(alphaBar.AbsoluteSize.X, 1), 0, 1)
					self.TransparencyState:Set(Utility.Round(alpha, 2))
				end)
				fieldsY = 172
			end

			local function field(x, y, width, label, commit)
				Widgets.Text(pcl, {
					Parent = frame,
					Text = label,
					Color = "MutedText",
					TextSize = 10,
					Position = UDim2.fromOffset(x, y),
					Size = UDim2.fromOffset(width, 12),
				})
				local holder = Widgets.Surface(pcl, {
					Parent = frame,
					Fill = "TertiaryBackground",
					Stroke = "Border",
					Radius = 6,
					Position = UDim2.fromOffset(x, y + 13),
					Size = UDim2.fromOffset(width, 22),
				})
				local box = Widgets.Text(pcl, {
					Class = "TextBox",
					Parent = holder,
					Size = UDim2.fromScale(1, 1),
					TextXAlignment = Enum.TextXAlignment.Center,
					ClearTextOnFocus = false,
					TextSize = 12,
				})
				pcl:Add(box.FocusLost:Connect(function()
					commit(box.Text)
					refresh()
				end))
				return box
			end

			local function setRGB(r, g, b)
				self.State:Set(Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255)))
			end
			local function channel(index)
				return function(text)
					local number = tonumber(text)
					if number then
						local color = self.State:Get()
						local values = { to255(color.R), to255(color.G), to255(color.B) }
						values[index] = number
						setRGB(values[1], values[2], values[3])
					end
				end
			end
			local function hsv(key, scale)
				return function(text)
					local number = tonumber(text)
					if number then
						self[key] = math.clamp(number / scale, 0, 1)
						self.State:Set(Color3.fromHSV(self._h, self._s, self._v))
					end
				end
			end

			hexBox = field(10, fieldsY, 70, "HEX", function(text)
				local color = Utility.FromHex(text)
				if color then
					self.State:Set(color)
				end
			end)
			rBox = field(86, fieldsY, 40, "R", channel(1))
			gBox = field(132, fieldsY, 40, "G", channel(2))
			bBox = field(178, fieldsY, 44, "B", channel(3))
			hBox = field(10, fieldsY + 42, 66, "H", hsv("_h", 360))
			sBox = field(82, fieldsY + 42, 66, "S", hsv("_s", 100))
			vBox = field(154, fieldsY + 42, 68, "V", hsv("_v", 100))

			local buttonsY = fieldsY + 86
			local function button(x, width, text, callback)
				local control = Widgets.Surface(pcl, {
					Class = "TextButton",
					Parent = frame,
					Fill = "TertiaryBackground",
					Stroke = "Border",
					Radius = 8,
					Position = UDim2.fromOffset(x, buttonsY),
					Size = UDim2.fromOffset(width, 24),
					Text = text,
					TextSize = 12,
				})
				Theme.BindFn(function()
					control.TextColor3 = Theme.Get("Text")
					control.FontFace = Theme.Font
				end, pcl)
				Widgets.Interactive(pcl, control, control, { Base = "TertiaryBackground" })
				pcl:Add(control.Activated:Connect(callback))
			end
			local copyable = Capabilities.Clipboard
			button(10, copyable and 100 or 212, "Reset", function()
				self:Reset()
				refresh()
			end)
			if copyable then
				button(118, 104, "Copy HEX", function()
					self:Copy()
				end)
			end

			pcl:Add(self.State.Changed:Connect(refresh))
			pcl:Add(self.TransparencyState.Changed:Connect(refresh))
			refresh()
		end))
		cleanup:Add(function()
			if self._popup then
				self._popup.Close()
			end
		end)
		return self
	end
end
