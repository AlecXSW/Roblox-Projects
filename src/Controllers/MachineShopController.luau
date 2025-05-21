local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MachineShop = {}

local player = Players.LocalPlayer
local playergui = player.PlayerGui
local InventoryGUI = playergui:WaitForChild("Inventory")
local HUD = playergui:WaitForChild("HUD")
local ShopGUI = playergui:WaitForChild("Shop")

local camera = workspace.CurrentCamera
local currentMachine = 1
local TotalMachines = #ReplicatedStorage.Machines:GetChildren()

-- Hud Button
local OpenShop = HUD.Buttons:WaitForChild("MachineShop")

-- Get Shop Info
local ShopInfo = require(ReplicatedStorage.Shared.MachineShop)

-- Shop Buttons
local CloseShop = ShopGUI:WaitForChild("CloseShopButton")
local Previous = ShopGUI:WaitForChild("Previous")
local Next = ShopGUI:WaitForChild("Next")
local BuyButton = ShopGUI:WaitForChild("PurchaseButton")
-- Shop Labels
local MachineNameLabel = ShopGUI:WaitForChild("NameOfMachine")
local PriceOfMachine = ShopGUI:WaitForChild("PriceOfMachine")
local DescriptionOfMachine = ShopGUI:WaitForChild("Description")
local MachineCooldown = ShopGUI:WaitForChild("Cooldown")
local MoneyPerDrop = ShopGUI:WaitForChild("MoneyPerDrop")
local OwnedLabel = ShopGUI:WaitForChild("AmountOwned")

-- close button
CloseShop.TextButton.Activated:Connect(function()
	camera.CameraType = Enum.CameraType.Custom
	ShopGUI.Enabled = false
	HUD.Buttons:WaitForChild("Shop").Visible = true
end)

-- purchase item(can be machine or upgrader)
BuyButton.TextButton.Activated:Connect(function()
	if not ShopGUI.Enabled then
		return
	end -- gui not open
	ReplicatedStorage.Events.BuyMachine:FireServer(currentMachine) -- only fire the current machine number
end)

local function Activated(direction)
	camera.CameraType = Enum.CameraType.Scriptable
	if direction == 1 then
		if currentMachine == TotalMachines then
			currentMachine = 1
		else
			currentMachine += 1
		end
	else
		if currentMachine == 1 then
			currentMachine = TotalMachines
		else
			currentMachine -= 1
		end
	end
	local currentInfo = ShopInfo[currentMachine]

	MachineNameLabel.Text = currentInfo.Name
	PriceOfMachine.Text = `${currentInfo.Price}`
	DescriptionOfMachine.Text = currentInfo.Description
	MachineCooldown.Text = `{currentInfo.Stats.Cooldown}s Cooldown`
	MoneyPerDrop.Text = `${currentInfo.Stats.BaseValue}/drop`
	if player:FindFirstChild(currentInfo.Name) then
		OwnedLabel.Text = `Owned: {player:FindFirstChild(currentInfo.Name).Value}`
	else
		OwnedLabel.Text = `Owned: 0`
	end
	TweenService:Create(
		camera,
		TweenInfo.new(0.25, Enum.EasingStyle.Linear),
		{ CFrame = currentInfo.CameraCFrame * CFrame.Angles(0, math.rad(-90), 0) }
	):Play()
end

Next.TextButton.Activated:Connect(function()
	Activated(1)
end)
Previous.TextButton.Activated:Connect(function()
	Activated(2)
end)

local function ToggleGUI()
	InventoryGUI.Enabled = false
	camera.CameraType = Enum.CameraType.Scriptable
	local currentInfo = ShopInfo[currentMachine]
	camera.CFrame = currentInfo.CameraCFrame * CFrame.Angles(0, math.rad(-90), 0)

	MachineNameLabel.Text = currentInfo.Name
	PriceOfMachine.Text = `${currentInfo.Price}`
	DescriptionOfMachine.Text = currentInfo.Description
	MachineCooldown.Text = `{currentInfo.Stats.Cooldown}s Cooldown`
	MoneyPerDrop.Text = `${currentInfo.Stats.BaseValue}/drop`
	if player:FindFirstChild(currentInfo.Name) then
		OwnedLabel.Text = `Owned: {player:FindFirstChild(currentInfo.Name).Value}`
	else
		OwnedLabel.Text = `Owned: 0`
	end

	ShopGUI.Enabled = true
end

function MachineShop.Init()
	player.ChildAdded:Connect(function(child)
		if child.Name == ShopInfo[currentMachine].Name then
			OwnedLabel.Text = `Owned: {child.Value}`
			child.Changed:Connect(function()
				OwnedLabel.Text = `Owned: {child.Value}`
			end)
		end
	end)

	OpenShop.Activated:Connect(ToggleGUI)

	for _, prompt in CollectionService:GetTagged("SwitchMachine") do
		prompt.Triggered:Connect(ToggleGUI)
	end
end

return MachineShop
