local InstanceMap = require(script.Parent.Parent.Shared.InstanceMap)
local Clipboard = require(script.Parent.Parent.Shared.Clipboard)
local NameUtils = require(script.Parent.Parent.Utils.name)

return function(payload: { targetNodeId: string? }): boolean
	local targetNodeId = payload.targetNodeId

	local targetParent = nil

	if targetNodeId then
		targetParent = assert(InstanceMap[targetNodeId], "target not found: " .. targetNodeId)
	else
		targetParent = game
	end

	-- nothing to copy
	if #Clipboard == 0 then
		return true
	end

	for _, clipboardContent in Clipboard do
		local pastedInstance = clipboardContent:Clone()

		local baseName, _ = NameUtils.ParseName(pastedInstance.Name)
		local newName = NameUtils.GetValidName(targetParent, baseName)

		pastedInstance.Name = newName
		pastedInstance.Parent = targetParent
	end

	return true
end
