--[[
	WebSocket Client for Roblox Studio
	
	Uses Roblox Studio's native WebSocket support (WebStreamClient) for real-time
	bidirectional communication with the sync daemon.
]]

local HttpService = game:GetService("HttpService")

local WebSocketClient = {}
WebSocketClient.__index = WebSocketClient

type configType = {
	debugMode: boolean?,
	silentMode: boolean?,
}

-- instance type
export type WebSocketClientInstance = {
	url: string,
	client: WebStreamClient?,
	connected: boolean,
	messageHandlers: { [string]: (any) -> () },
	config: configType,
	onClosed: BindableEvent,

	connect: (self: WebSocketClientInstance) -> boolean,
	on: (self: WebSocketClientInstance, event: string, handler: (any) -> ()) -> (),
	handleMessage: (self: WebSocketClientInstance, message: string) -> (),
	send: (self: WebSocketClientInstance, message: string) -> boolean,
	disconnect: (self: WebSocketClientInstance) -> (),
	debugPrint: (self: WebSocketClientInstance, ...any) -> (),
	infoPrint: (self: WebSocketClientInstance, ...any) -> (),
}

-- module type
type WebSocketClientModule = {
	new: (url: string?, config: configType?) -> WebSocketClientInstance,
}

-- self type (for backward compatibility)
type WebSocketClient = WebSocketClientInstance

function WebSocketClient.new(url, config: configType?)
	local self = setmetatable({}, WebSocketClient)
	self.url = url or "ws://localhost:8080"
	self.client = nil
	self.connected = false
	self.messageHandlers = {}
	self.onClosed = Instance.new("BindableEvent")
	self.config = config or {
		debugMode = false,
		silentMode = true,
	}

	if self.config.debugMode then
		print("[🐛 WebSocket]: Debug mode is enabled!")
	end

	return (self :: any) :: WebSocketClientInstance
end

function WebSocketClient:debugPrint(...)
	self = self :: WebSocketClientInstance
	if self.config.silentMode or not self.config.debugMode then
		return
	end
	print(...)
end

function WebSocketClient:infoPrint(...)
	self = self :: WebSocketClientInstance
	if self.config.silentMode then
		return
	end
	print(...)
end

function WebSocketClient:on(event, handler)
	self = self :: WebSocketClientInstance
	self.messageHandlers[event] = handler
end

function WebSocketClient:connect()
	self = self :: WebSocketClientInstance

	if self.connected then
		return true
	end

	-- Create WebSocket client using CreateWebStreamClient
	local success, result = pcall(function()
		return HttpService:CreateWebStreamClient(Enum.WebStreamClientType.WebSocket, {
			Url = self.url,
		})
	end)

	if not success then
		warn("[WebSocket]: Connection failed:", result)
		if self.messageHandlers.error then
			self.messageHandlers.error(result)
		end
		return false
	end

	self.client = result
	self.connected = true

	-- Set up message handler (only MessageReceived is documented)
	self.client.MessageReceived:Connect(function(message)
		local parseSuccess, parseError = pcall(function()
			self:handleMessage(message)
		end)
		if not parseSuccess then
			warn("[WebSocket]: Error handling message:", parseError)
		end
	end)

	-- Notify connection established
	self:debugPrint("[🐛 WebSocket]: Connected to", self.url)
	if self.messageHandlers.connect then
		task.defer(function()
			self.messageHandlers.connect()
		end)
	end

	return true
end

function WebSocketClient:handleMessage(message)
	self = self :: WebSocketClientInstance
	if not message or message == "" then
		return
	end

	self:debugPrint("[🐛 WebSocket]: Received message:", string.sub(message, 1, 100))

	local success, data = pcall(function()
		return HttpService:JSONDecode(message)
	end)

	if success and self.messageHandlers.message then
		self.messageHandlers.message(data)
	elseif not success then
		warn("[WebSocket]: Failed to parse message:", message)
	end
end

function WebSocketClient:send(message)
	self = self :: WebSocketClientInstance
	if not self.connected or not self.client then
		warn("[WebSocket]: Cannot send: not connected")
		return false
	end

	local success, err = pcall(function()
		self.client:Send(message)
	end)

	if not success then
		warn("[WebSocket]: Send failed:", err)
		return false
	end

	return true
end

function WebSocketClient:disconnect()
	self = self :: WebSocketClientInstance

	if not self.client then
		self.connected = false
		return
	end

	self.connected = false

	pcall(function()
		self.client:Close()
	end)

	self.client = nil

	if self.messageHandlers.disconnect then
		self.messageHandlers.disconnect()
	end
end

return (WebSocketClient :: any) :: WebSocketClientModule
