local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PromptController = {}
local playerTycoon = nil
local MachineShopInfo = require(ReplicatedStorage.Shared.MachineShop)

local player = Players.LocalPlayer
local playergui = player.PlayerGui
local HUD = playergui:WaitForChild("HUD")
local InventoryGUI = playergui:WaitForChild("Inventory")
local CloseInventory = InventoryGUI:WaitForChild("CloseInventoryButton")

CloseInventory.TextButton.Activated:Connect(function()
	InventoryGUI.Enabled = false
end)

local function GetTycoon()
	for _, v in workspace.Tycoons:GetChildren() do
		if v:GetAttribute("Owner") == player.UserId then
			return v
		end
	end
end

repeat
	playerTycoon = GetTycoon()
	task.wait(0.01)
until playerTycoon ~= nil
print(playerTycoon)

local function GetIndex(machineName)
	for i, v in MachineShopInfo do
		if v.Name == machineName then
			return i
		end
	end
end

local function PlaceMachine(plotNum)
	for _, v in InventoryGUI.ScrollingFrame:GetChildren() do
		if not v:IsA("Frame") then
			continue
		end
		local button = v.ImageButton
		button.Activated:Connect(function()
			ReplicatedStorage.Events.PlaceMachine:FireServer(plotNum, GetIndex(v.Name))
		end)
	end
end

function PromptController.Init()
	for _, v in playerTycoon:GetDescendants() do
		if v:IsA("ProximityPrompt") then
			v.Enabled = true
			v.Triggered:Connect(function()
				InventoryGUI.Enabled = true
				task.spawn(PlaceMachine, tonumber(v.Parent.Name))
				InventoryGUI.ScrollingFrame.ChildAdded:Connect(function()
					task.spawn(PlaceMachine, tonumber(v.Parent.Name))
				end)
			end)
		end
	end
end

return PromptController
