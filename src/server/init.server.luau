local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(script.Data)
local playerMod = require(script.Player)
local Tycoon = require(script.Tycoon)
local MachineShopInfo = require(ReplicatedStorage.Shared.MachineShop)

Data.Init()
playerMod.Init()

local Drops = ReplicatedStorage.Drops
local Animations = ReplicatedStorage.Animations

-- Testing Animations
local function AddTP(character)
	local tpModel = Drops.ToiletPaperStack2:Clone()
	tpModel.Parent = character
	tpModel.Weld.Part0 = tpModel
	tpModel.Weld.Part1 = character:FindFirstChild("RightHand")

	local Humanoid = character.Humanoid
	local Animator = Humanoid.Animator :: Animator

	Animator:LoadAnimation(Animations.ThreeToiletPaper):Play()
end

-- used to store players tycoon metatable
local Tycoons = {}

local function PlayerAdded(player: Player)
	local playerTycoon = Tycoon.new(player)
	Tycoons[player] = playerTycoon
	playerTycoon:UpdateBank()
	local Character = player.Character or player.CharacterAdded:Wait()
	AddTP(Character)
	player.CharacterAdded:Connect(function(newCharacter)
		task.spawn(AddTP, newCharacter)
	end)
end

for _, player in Players:GetPlayers() do
	task.spawn(PlayerAdded, player)
end
Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local playerTycoon = Tycoons[player]
	if not playerTycoon then
		return
	end -- no tycoon so don't continue
	playerTycoon:Destroy()
end)

ReplicatedStorage.Events.BuyMachine.OnServerEvent:Connect(function(player, machineNumber: number)
	local MachineInfo = MachineShopInfo[machineNumber]
	if not MachineInfo then
		return
	end
	Data.GetReplica(player):andThen(function(replica)
		if replica.Data.Money < MachineInfo.Price then
			return
		end -- cannot afford so just dont do anything else

		replica:Set({ "Money" }, replica.Data.Money - MachineInfo.Price)
		player.leaderstats.Money.Value = replica.Data.Money
		if not replica.Data.Inventory[MachineInfo.Name] then
			replica.Data.Inventory[MachineInfo.Name] = 1
		else
			replica.Data.Inventory[MachineInfo.Name] += 1
		end
		replica:Set({ "Inventory" }, replica.Data.Inventory)
	end)
end)

ReplicatedStorage.Events.PlaceMachine.OnServerEvent:Connect(function(player, plotNum, machineNumber: number)
	local newMachineInfo = MachineShopInfo[machineNumber]
	local playerTycoon = Tycoons[player]
	if not playerTycoon then
		return
	end
	if not newMachineInfo then
		return
	end
	local Plot = playerTycoon.Starter.Plots[plotNum]
	local hasOldModel = Plot:FindFirstChildOfClass("Model")
	Data.GetReplica(player):andThen(function(replica)
		if not replica.Data.Inventory[newMachineInfo.Name] then
			return
		end
		if replica.Data.Inventory[newMachineInfo.Name] == 0 then
			return
		end
		if hasOldModel and hasOldModel.Name == newMachineInfo.Name then
			return -- already there
		end
		if hasOldModel then
			replica.Data.Inventory[hasOldModel.Name] += 1
			hasOldModel:Destroy()
		end

		replica.Data.Plots[plotNum] = newMachineInfo.Name
		replica.Data.Inventory[newMachineInfo.Name] -= 1
		print(replica.Data.Inventory[newMachineInfo.Name])
		replica:Set({ "Inventory" }, replica.Data.Inventory)

		local newModel = ReplicatedStorage.Machines:FindFirstChild(newMachineInfo.Name):Clone()
		newModel.Parent = Plot
		newModel:PivotTo(Plot.CFrame)

		print("placed")
	end)
end)
