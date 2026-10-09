return function(import)
	local Registry = import("Icons/Registry")
	local Providers = import("Icons/Providers")
	local Theme = import("Core/Theme")
	local Utility = import("Core/Utility")
	local Cleanup = import("Services/Cleanup")

	local Icons = {}

	function Icons:Get(name)
		return Registry.Resolve(name)
	end

	function Icons:List()
		return Providers.Builtin.Names()
	end

	-- Zeta.Icons.Home / Zeta.Icons.ChevronDown
	setmetatable(Icons, {
		__index = function(_, key)
			if type(key) ~= "string" then
				return nil
			end
			local kebab = string.lower((string.gsub(key, "(%l)(%u)", "%1-%2")))
			return Registry.Resolve(kebab)
		end,
	})

	-- opts: Size, Color (token or Color3), Position, AnchorPoint, Cleanup
	function Icons.Create(parent, spec, opts)
		opts = opts or {}
		local size = opts.Size or 16
		local cleanup = opts.Cleanup and opts.Cleanup:Extend() or Cleanup.new()
		local self = {}

		local container = Utility.Create("Frame", {
			Name = "Icon",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(size, size),
			Position = opts.Position or UDim2.new(),
			AnchorPoint = opts.AnchorPoint or Vector2.zero,
			Parent = parent,
		})
		cleanup:Add(container)
		self.Instance = container

		local colorSource = opts.Color or "MutedText"
		local parts = {}
		local image, tinted
		local ticket = 0

		local function color()
			if typeof(colorSource) == "Color3" then
				return colorSource
			end
			return Theme.Get(colorSource)
		end

		local function paint()
			local value = color()
			for _, part in parts do
				if part.stroke then
					part.stroke.Color = value
				else
					part.instance.BackgroundColor3 = value
				end
			end
			if image and tinted then
				image.ImageColor3 = value
			end
		end

		local function clear()
			container:ClearAllChildren()
			table.clear(parts)
			image, tinted = nil, false
		end

		local function drawVector(vector)
			local thickness = math.max(1.25, size / 24 * 1.8)
			for _, segment in vector.L do
				local x1, y1, x2, y2 = segment[1], segment[2], segment[3], segment[4]
				local dx, dy = x2 - x1, y2 - y1
				local length = math.max(math.sqrt(dx * dx + dy * dy), 0.01)
				local line = Utility.Create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale((x1 + x2) / 48, (y1 + y2) / 48),
					Size = UDim2.new(length / 24, thickness, 0, thickness),
					Rotation = math.deg(math.atan2(dy, dx)),
					Parent = container,
				})
				Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = line })
				table.insert(parts, { instance = line })
			end
			for _, circle in vector.C do
				local diameter = circle[3] * 2 / 24
				local ring = Utility.Create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(circle[1] / 24, circle[2] / 24),
					Size = UDim2.fromScale(diameter, diameter),
					Parent = container,
				})
				Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ring })
				local stroke = Utility.Create("UIStroke", {
					Thickness = thickness,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Parent = ring,
				})
				table.insert(parts, { instance = ring, stroke = stroke })
			end
		end

		local function newImage(source, tint)
			image = Utility.Create("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Image = source or "",
				Parent = container,
			})
			tinted = tint == true
			return image
		end

		local function draw(newSpec)
			ticket += 1
			local mine = ticket
			clear()
			if newSpec == nil then
				container.Visible = false
				return
			end
			container.Visible = true
			local resolved = Registry.Resolve(newSpec)
			if not resolved then
				Utility.Log("Unknown icon:", tostring(newSpec))
				resolved = Providers.Fallback
			end
			if not resolved then
				container.Visible = false
				return
			end
			if resolved.Type == "Vector" then
				drawVector(resolved)
			elseif resolved.Type == "Image" then
				newImage(resolved.Source, resolved.Tint)
			else
				newImage(nil, resolved.Tint)
				Providers.LoadUrl(resolved.Source, function(asset)
					if mine ~= ticket or not container.Parent then
						return
					end
					if asset and image then
						image.Image = asset
					elseif not asset then
						clear()
						local fallback = Providers.Fallback
						if fallback then
							newImage(fallback.Source, fallback.Tint)
						end
						paint()
					end
				end)
			end
			paint()
		end

		function self.Set(_, newSpec)
			draw(newSpec)
		end

		function self.SetColor(_, newColor)
			colorSource = newColor
			paint()
		end

		function self.Destroy()
			cleanup:Clean()
		end

		Theme.BindFn(paint, cleanup)
		draw(spec)
		return self
	end

	return Icons
end
