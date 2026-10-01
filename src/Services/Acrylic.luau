return function(import)
	local Lighting = game:GetService("Lighting")
	local Animation = import("Services/Animation")

	-- Acrylic = themed translucent surface (handled by Window) plus an optional
	-- screen blur while the window is visible. Blur is screen-wide by nature
	-- (BlurEffect), and is skipped when the environment does not allow it.
	local Acrylic = {}

	function Acrylic.Supported()
		return (pcall(function()
			local probe = Instance.new("BlurEffect")
			probe.Parent = Lighting
			probe:Destroy()
		end))
	end

	function Acrylic.new(cleanup, size)
		local self = {}
		local blur = Instance.new("BlurEffect")
		blur.Name = "ZetaBlur"
		blur.Size = 0
		blur.Parent = Lighting
		cleanup:Add(blur)

		function self.SetActive(active)
			Animation:Play(blur, { Size = active and (size or 10) or 0 }, { Duration = 0.25 })
		end

		function self.Destroy()
			blur:Destroy()
		end

		return self
	end

	return Acrylic
end
