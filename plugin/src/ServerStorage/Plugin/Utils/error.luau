return function(...: any)
	local args = { ... }

	for i, arg in ipairs(args) do
		args[i] = tostring(arg)
	end

	error("[RblxExplorer] " .. table.concat(args, " "))
end
