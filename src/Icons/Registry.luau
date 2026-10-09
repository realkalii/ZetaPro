return function(import)
	local Providers = import("Icons/Providers")
	local Utility = import("Core/Utility")

	local Registry = {
		_providers = { Builtin = Providers.Builtin.Resolve },
		_current = "Builtin",
	}

	function Registry.Register(name, resolve)
		Utility.Check(type(name) == "string" and type(resolve) == "function", "IconProvider", name, "Expected (name: string, resolve: function).")
		Registry._providers[name] = resolve
	end

	function Registry.SetProvider(name)
		if not Registry._providers[name] then
			Utility.Warn(string.format('Icon provider "%s" is not registered.', tostring(name)))
			return false
		end
		Registry._current = name
		return true
	end

	function Registry.GetProvider()
		return Registry._current
	end

	function Registry.Resolve(spec)
		if type(spec) == "string" then
			local resolver = Registry._providers[Registry._current]
			local ok, resolved = pcall(resolver, spec)
			if ok and resolved then
				return resolved
			end
			return Providers.Builtin.Resolve(spec)
		end
		if type(spec) == "table" and (spec.Type == "Image" or spec.Type == "Url") then
			return spec
		end
		return nil
	end

	return Registry
end
