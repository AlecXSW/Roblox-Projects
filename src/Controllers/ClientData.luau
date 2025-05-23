local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientData = {}

local Replica = require(ReplicatedStorage.Packages.Replica)
local player = Players.LocalPlayer
local playergui = player.PlayerGui
local HUD = playergui:WaitForChild("HUD")
local InventoryGUI = playergui:WaitForChild("Inventory")

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

local function UpdateInventory(newTable)
	for i, v in newTable do
		local newInstanceValue = player:FindFirstChild(i)
		if not newInstanceValue then
			newInstanceValue = Instance.new("NumberValue")
		end
		newInstanceValue:AddTag("NewInstanceValue")
		newInstanceValue.Parent = player
		newInstanceValue.Name = i
		newInstanceValue.Value = v
		local temp = InventoryGUI.ScrollingFrame:FindFirstChild(i)
		if not temp then
			temp = InventoryGUI.Template:Clone()
			temp.Parent = InventoryGUI.ScrollingFrame
			temp.Name = i
		end
		if newInstanceValue.Value == 0 then
			temp:Destroy()
		end
		local imageButton = temp:WaitForChild("ImageButton")
		if imageButton then
			imageButton.Activated:Connect(function()
				player:SetAttribute("Index", i)
				ReplicatedStorage.Events.PlaceMachine:FireServer(player:GetAttributes())
			end)
		end
		temp.amount.Text = `{v}X`
		temp.machineName.Text = i
		temp.Visible = true

		newInstanceValue.Changed:Connect(function()
			if newInstanceValue.Value == 0 then
				newInstanceValue:Destroy()
				temp:Destroy()
			end
		end)
	end
end

function ClientData.Init()
	Replica.OnNew("PlayerData", function(replica)
		MoneyLabel.Text = `${Format.Simple.Format(replica.Data.Money)}`
		task.spawn(UpdateInventory, replica.Data.Inventory)
		replica:OnSet({ "Money" }, function(new_value, old_value)
			task.spawn(AnimateText, old_value, new_value)
		end)
		replica:OnSet({ "Inventory" }, function(new_value)
			task.spawn(UpdateInventory, new_value)
		end)
	end)
end
Replica.RequestData()
return ClientData
