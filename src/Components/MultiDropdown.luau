return function(import)
	local Dropdown = import("Components/Dropdown")

	return function(ctx, id, config)
		local copy = table.clone(config)
		copy.Multi = true
		return Dropdown(ctx, id, copy)
	end
end
