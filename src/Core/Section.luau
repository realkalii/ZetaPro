return function(import)
	local Utility = import("Core/Utility")
	local Widgets = import("Core/Widgets")
	local Component = import("Core/Component")

	local Section = {}
	Component.MakeContainer(Section)

	function Section.new(tab, title)
		Utility.Check(type(title) == "string", "Section", title, "Title must be a string.")
		local self = setmetatable({}, Section)
		local window = tab.Window
		self.Window, self.Title, self.TabRef, self.SectionRef = window, title, tab, self
		self.Cleanup = tab.Cleanup:Extend()
		self._order = 0
		self.NextOrder = function()
			self._order += 1
			return self._order
		end
		local cleanup = self.Cleanup

		local frame = Utility.Create("Frame", {
			Name = "Section_" .. title,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = tab.NextOrder(),
			Parent = tab.Container,
		})
		cleanup:Add(frame)
		Widgets.List(frame, 10)
		self.Frame = frame

		local header = Utility.Create("Frame", {
			Name = "Header",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 24),
			LayoutOrder = 0,
			Parent = frame,
		})
		self._label = Widgets.Text(cleanup, {
			Parent = header,
			Text = title,
			Color = "MutedText",
			Bold = true,
			TextSize = 12,
			Size = UDim2.new(1, 0, 1, -4),
		})
		Widgets.Surface(cleanup, {
			Parent = header,
			Fill = "Border",
			Radius = 0,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -1),
		})
		self.Header = header

		self.Container = Utility.Create("Frame", {
			Name = "Body",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 1,
			Parent = frame,
		})
		Widgets.List(self.Container, 8)

		self._entry = window:_IndexAdd({ Kind = "Section", Title = title, Tab = tab, Section = self, Frame = header })
		cleanup:Add(function()
			if self._entry then
				self._entry.Remove()
			end
		end)
		return self
	end

	function Section:SetTitle(text)
		self.Title = text
		self._label.Text = text
		self._entry.Title = text
	end

	function Section:SetVisible(visible)
		self.Frame.Visible = visible
	end

	function Section:Destroy()
		self.Cleanup:Clean()
	end

	return Section
end
