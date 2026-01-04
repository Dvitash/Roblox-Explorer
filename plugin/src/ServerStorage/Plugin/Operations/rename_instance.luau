local InstanceMap = require(script.Parent.Parent.Shared.InstanceMap)
local error = require(script.Parent.Parent.Utils.error)

return function(payload: { nodeId: string, newName: string }): boolean
	local nodeId = payload.nodeId
	local newName = payload.newName

	local instance = assert(InstanceMap[nodeId], "instance not found: " .. nodeId)

	if type(newName) ~= "string" or newName == "" then
		error("invalid name")
	end

	instance.Name = newName

	return true
end
