local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientData = {}

local Replica = require(ReplicatedStorage.Packages.Replica)
local player = Players.LocalPlayer
local playergui = player.PlayerGui
local HUD = playergui:WaitForChild("HUD")
local MoneyLabel = HUD:WaitForChild("MoneyAmount")

local Format = require(ReplicatedStorage.Packages.FormatNumber)

local function AnimateText(old_value: number, new_value: number)
	local currentNum = old_value

	while true do
		local dt = task.wait()
		if currentNum == new_value then
			break
		end
		currentNum = math.lerp(currentNum, new_value, dt * 20)
		MoneyLabel.Text = `${Format.Simple.Format(math.round(currentNum))}`
	end

	MoneyLabel.Text = `${new_value}`
end

function ClientData.Init()
	Replica.OnNew("PlayerData", function(replica)
		print(replica.Data)
		MoneyLabel.Text = `${replica.Data.Money}`
		replica:OnSet({ "Money" }, function(new_value, old_value)
			task.spawn(AnimateText, old_value, new_value)
		end)
	end)
end
Replica.RequestData()
return ClientData
