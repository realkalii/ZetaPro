return function(import)
	local Search = {}
	Search.__index = Search

	function Search.new()
		return setmetatable({ _entries = {} }, Search)
	end

	-- entry: { Kind, Title, Description, Tab, Section, Frame, Component }
	-- Returns the entry with an added Remove() method.
	function Search:Add(entry)
		function entry.Remove()
			local index = table.find(self._entries, entry)
			if index then
				table.remove(self._entries, index)
			end
		end
		table.insert(self._entries, entry)
		return entry
	end

	function Search:Count()
		return #self._entries
	end

	function Search:Query(text)
		local needle = string.lower((string.gsub(tostring(text or ""), "^%s*(.-)%s*$", "%1")))
		if needle == "" then
			return {}
		end
		local scored = {}
		for _, entry in self._entries do
			local title = string.lower(entry.Title or "")
			local description = string.lower(entry.Description or "")
			local score = 0
			if string.sub(title, 1, #needle) == needle then
				score = 100
			elseif string.find(title, needle, 1, true) then
				score = 60
			elseif string.find(description, needle, 1, true) then
				score = 30
			elseif entry.Section and string.find(string.lower(entry.Section.Title or ""), needle, 1, true) then
				score = 10
			end
			if score > 0 then
				table.insert(scored, { entry = entry, score = score })
			end
		end
		table.sort(scored, function(a, b)
			if a.score ~= b.score then
				return a.score > b.score
			end
			return (a.entry.Title or "") < (b.entry.Title or "")
		end)
		local results = {}
		for index = 1, math.min(#scored, 25) do
			results[index] = scored[index].entry
		end
		return results
	end

	return Search
end
