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

	-- MoneyLabel.Text = `${Format.Simple.Format(math.round(currentNum))}`
end

function ClientData.Init()
	Replica.OnNew("PlayerData", function(replica)
		MoneyLabel.Text = `${Format.Simple.Format(replica.Data.Money)}`

		replica:OnSet({ "Money" }, function(new_value, old_value)
			task.spawn(AnimateText, old_value, new_value)
		end)
		replica:OnSet({ "Inventory" }, function(new_value, old_value)
			for i, v in new_value do
				local newInstanceValue = player:FindFirstChild(i)
				if not newInstanceValue then
					newInstanceValue = Instance.new("NumberValue")
				end
				newInstanceValue.Parent = player
				newInstanceValue.Name = i
				newInstanceValue.Value = v
			end
		end)
	end)
end
Replica.RequestData()
return ClientData
