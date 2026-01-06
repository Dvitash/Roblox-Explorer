local Services = require(script.Parent.Parent.Shared.Services)

local serviceInstances = {}

for _, serviceName in Services do
	serviceInstances[serviceName] = game:GetService(serviceName)
end

return function(instance: Instance): boolean
	for _, service in serviceInstances do
		if instance:IsDescendantOf(service) then
			return true
		end
	end

	return false
end
