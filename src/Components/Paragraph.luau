return function(import)
	local Component = import("Core/Component")

	local Paragraph = setmetatable({}, { __index = Component.Base })
	Paragraph.__index = Paragraph

	function Paragraph:SetContent(text)
		self:SetDescription(text)
	end

	-- config: Title, Content, Icon, RichText
	return function(ctx, id, config)
		return Component.New(ctx, Paragraph, "Paragraph", id, config, {})
	end
end
