local InstanceMap = require(script.Parent.Parent.Shared.InstanceMap)

return function(payload: { nodeId: string }): boolean
	local nodeId = payload.nodeId

	local instance = assert(InstanceMap[nodeId], "instance not found: " .. nodeId)
	instance:Destroy()

	return true
end
