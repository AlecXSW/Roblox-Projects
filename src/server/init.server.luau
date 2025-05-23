-- local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Data = require(script.Data)
local playerMod = require(script.Player)
local Tycoon = require(script.Tycoon)
local Machines = require(ReplicatedStorage.Shared.Machines)

Data.Init()
playerMod.Init()

-- used to store players tycoon metatable
local Tycoons = {}
local Machines = {}

-- Cooldowns
local MachinePlaceCooldown = {}

local function PlayerAdded(player: Player)
	local playerTycoon = Tycoon.new(player)
	Tycoons[player] = playerTycoon

	-- while player.Parent == Players do
	-- 	task.wait(1)
	-- 	playerTycoon:UpdateBank()
	-- end
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

ReplicatedStorage.Events.PlaceMachine.OnServerEvent:Connect(function(player, playerAttributes)
	-- still in cooldown
	if MachinePlaceCooldown[player] then
		return
	end
	local playerTycoon = Tycoons[player]
	-- no tycoon yet
	if not playerTycoon then
		return
	end
	local machineInfo = Machines[playerAttributes.Index]
	-- machine is invalid
	if not machineInfo then
		warn("Not a valid machine:", playerAttributes.Index)
		return
	end

	Data.GetReplica(player):andThen(function(playerReplica)
		-- machine not found in replica
		if not playerReplica.Data.Inventory[playerAttributes.Index] then
			return warn("Not Found")
		end
		local PlotPart = playerTycoon.Starter.Built:FindFirstChild(`Slot[{playerAttributes.PlotSelected}]`)

		-- if there is already an object on the plot then destroy it
		if PlotPart:FindFirstChildOfClass("Model") then
			-- add back to inventory
			if playerReplica.Data.Inventory[playerAttributes.Index] then
				-- add to what the amount they already have
				playerReplica.Data.Inventory[playerAttributes.Index] += 1
			else
				-- if they don't have any then add the one back to the inventory
				playerReplica.Data.Inventory[playerAttributes.Index] = 1
			end

			PlotPart:FindFirstChildOfClass("Model"):Destroy()
		end
		local MachineModel = ServerStorage.Machines:FindFirstChild(playerAttributes.Index):Clone()
		MachineModel:PivotTo(PlotPart.CFrame)
		MachineModel.Parent = PlotPart

		playerReplica.Data.Inventory[MachineModel.Name] -= 1
		playerReplica:Set({ "Inventory" }, playerReplica.Data.Inventory)

		playerReplica.Data.Plots[playerAttributes.PlotSelected] = MachineModel.Name
	end)

	MachinePlaceCooldown[player] = true
	task.wait(0.5)
	MachinePlaceCooldown[player] = nil
end)
