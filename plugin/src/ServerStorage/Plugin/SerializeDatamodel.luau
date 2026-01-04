--[[
	SerializeDatamodel.luau
	Serialize the datamodel to a snapshot representation.

	Dvitash 1/4/2026
--]]

local Services = require(script.Parent.Shared.Services)

type Node = {
	id: string,
	name: string,
	className: string,
	parentId: string?,
	children: { string },
}

type Snapshot = {
	rootIds: { string },
	nodes: { Node },
}

local MAX_DEPTH = 10000
local MAX_NODES = math.huge

return function(): (Snapshot, { [string]: Instance })
	local nodes: { Node } = {}
	local instanceMap: { [string]: Instance } = {}
	local rootIds: { string } = {}
	local nodeCount = 0

	local function processInstance(instance: Instance, parentId: string, depth: number)
		if depth >= MAX_DEPTH then
			return
		end

		if nodeCount >= MAX_NODES then
			return
		end

		local id = instance:GetDebugId(0)

		local node: Node = {
			id = id,
			name = instance.Name,
			className = instance.ClassName,
			parentId = parentId,
			children = {},
		}

		instanceMap[id] = instance

		table.insert(nodes, node)
		nodeCount += 1

		for _, child in instance:GetChildren() do
			local childId = processInstance(child, id, depth + 1)

			if childId then
				table.insert(node.children, childId)
			end
		end

		return id
	end

	for _, serviceName in Services do
		local service = game:GetService(serviceName)
		local serviceId = processInstance(service, nil, 0)

		if serviceId then
			table.insert(rootIds, serviceId)
		end
	end

	local snapshot: Snapshot = {
		rootIds = rootIds,
		nodes = nodes,
	}

	return snapshot, instanceMap
end
