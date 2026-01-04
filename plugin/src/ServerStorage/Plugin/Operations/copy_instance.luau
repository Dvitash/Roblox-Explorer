local InstanceMap = require(script.Parent.Parent.Shared.InstanceMap)
local Clipboard = require(script.Parent.Parent.Shared.Clipboard)

return function(payload: { nodeIds: { string } }): boolean
	local nodeIds = payload.nodeIds

	table.clear(Clipboard)

	for _, nodeId in nodeIds do
		local instance = assert(InstanceMap[nodeId], "instance not found: " .. nodeId)

		local clonedInstance = instance:Clone()

		table.insert(Clipboard, clonedInstance)
	end

	return true
end
