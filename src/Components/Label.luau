return function(import)
	local Component = import("Core/Component")

	local Label = setmetatable({}, { __index = Component.Base })
	Label.__index = Label

	function Label:SetText(text)
		self:SetTitle(text)
	end

	-- config: Text (or Title), Icon
	return function(ctx, id, config)
		return Component.New(ctx, Label, "Label", id, config, { Flat = true, MinHeight = 24 })
	end
end
