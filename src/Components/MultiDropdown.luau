return function(import)
	local Dropdown = import("Components/Dropdown")

	-- Tab:AddMultiDropdown(id, config) is Tab:AddDropdown with Multi = true.
	return function(ctx, id, config)
		local copy = table.clone(config)
		copy.Multi = true
		return Dropdown(ctx, id, copy)
	end
end
