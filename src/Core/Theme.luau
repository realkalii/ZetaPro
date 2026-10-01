return function(import)
	local Signal = import("Core/Signal")
	local Default = import("Themes/Default")

	local ALIASES = { Secondary = "SecondaryBackground", Tertiary = "TertiaryBackground" }

	local Theme = {
		Changed = Signal.new(),
		ScaleChanged = Signal.new(),
		Scale = 1,
	}

	local themes = {}
	local current = "Dark"

	local function applyFont(font)
		Theme.Font = font
		Theme.FontBold = Font.new(font.Family, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	end
	applyFont(Font.fromEnum(Enum.Font.Gotham))

	function Theme.Register(name, definition)
		if type(name) ~= "string" or type(definition) ~= "table" then
			error("[ZETA][ERROR] Theme.Register expects (name: string, definition: table)", 2)
		end
		local base = definition.Base and themes[definition.Base] or Default
		local merged = table.clone(base)
		for key, value in definition do
			if key ~= "Base" then
				key = ALIASES[key] or key
				local expected = Default[key]
				if expected ~= nil and typeof(expected) ~= typeof(value) then
					error(string.format('[ZETA][ERROR] Theme "%s": token "%s" must be %s', name, key, typeof(expected)), 2)
				end
				merged[key] = value
			end
		end
		themes[name] = merged
		if name == current then
			Theme.Changed:Fire(current)
		end
	end

	function Theme.Set(name)
		if not themes[name] then
			warn(string.format('[ZETA][WARN] Theme "%s" is not registered.', tostring(name)))
			return false
		end
		current = name
		Theme.Changed:Fire(name)
		return true
	end

	function Theme.GetName()
		return current
	end

	function Theme.Names()
		local names = {}
		for name in themes do
			table.insert(names, name)
		end
		table.sort(names)
		return names
	end

	function Theme.Get(token)
		local active = themes[current]
		local value = active and active[token]
		if value == nil then
			value = Default[token]
		end
		return value
	end

	-- Runs `callback` now and after every theme/font change.
	function Theme.BindFn(callback, cleanup)
		callback()
		local connection = Theme.Changed:Connect(callback)
		if cleanup then
			cleanup:Add(connection)
		end
		return connection
	end

	-- map: { Property = "Token" | function(Theme) -> value }
	function Theme.Bind(instance, map, cleanup)
		return Theme.BindFn(function()
			for property, token in map do
				if type(token) == "function" then
					instance[property] = token(Theme)
				else
					instance[property] = Theme.Get(token)
				end
			end
		end, cleanup)
	end

	function Theme.SetFont(font)
		if typeof(font) == "EnumItem" then
			applyFont(Font.fromEnum(font))
		elseif typeof(font) == "Font" then
			applyFont(font)
		else
			error("[ZETA][ERROR] SetFont expects an Enum.Font or a Font", 2)
		end
		Theme.Changed:Fire(current)
	end

	function Theme.SetScale(scale)
		if type(scale) ~= "number" then
			error("[ZETA][ERROR] SetScale expects a number", 2)
		end
		Theme.Scale = math.clamp(scale, 0.5, 2)
		Theme.ScaleChanged:Fire(Theme.Scale)
	end

	function Theme.BindScale(uiScale, cleanup)
		uiScale.Scale = Theme.Scale
		local connection = Theme.ScaleChanged:Connect(function(value)
			uiScale.Scale = value
		end)
		if cleanup then
			cleanup:Add(connection)
		end
	end

	return Theme
end
