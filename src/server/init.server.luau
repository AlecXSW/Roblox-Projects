local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(script.Data)
local playerMod = require(script.Player)
local ShopInfo = require(ReplicatedStorage.Shared.Shop)

Data.Init()
playerMod.Init()

ReplicatedStorage.Events.BuyMachine.OnServerEvent:Connect(function(player, machineNumber: number)
	local MachineInfo = ShopInfo[machineNumber]
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
