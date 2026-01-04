local function ParseName(name: string): (string, number)
	local baseName = name:gsub("%d+$", "")
	local suffix = name:match("(%d+)$")
	local number = suffix and tonumber(suffix) or 0
	return baseName, number
end

local function GetValidName(parent: Instance, baseName: string): string
	if not parent:FindFirstChild(baseName) then
		return baseName
	end

	local highestNumber = 0
	local baseLength = #baseName

	for _, child in parent:GetChildren() do
		local childName = child.Name
		if childName:sub(1, baseLength) == baseName then
			local suffix = childName:sub(baseLength + 1)
			if suffix == "" then
				highestNumber = math.max(highestNumber, 0)
			else
				local number = tonumber(suffix)
				if number then
					highestNumber = math.max(highestNumber, number)
				end
			end
		end
	end

	return baseName .. tostring(highestNumber + 1)
end

return {
	ParseName = ParseName,
	GetValidName = GetValidName,
}
