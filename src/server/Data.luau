local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Data = {}
local Profiles = {}
local Replicas = {}

local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local Template = {
	Money = 1_000,
	Inventory = {
		["Simple Machine"] = 2,
		["Advanced Machine"] = 1,
	},
	Plots = {}, -- "1st" plot is taken by "Advanced Machine"
	OwnedPads = { "OwnerDoor[1]" },
}

local PlayerStore = ProfileStore.New("1", Template)

local InDev = true
if InDev then
	PlayerStore = PlayerStore.Mock
end

local Promise = require(ReplicatedStorage.Packages.Promise)
local ReplicaServer = require(ReplicatedStorage.Packages.Replica)
local DataToken = ReplicaServer.Token("PlayerData")

local function PlayerAdded(player: Player)
	local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		profile.OnSessionEnd:Connect(function()
			Profiles[player] = nil
			player:Kick("Profile session ended - Please rejoin")
		end)

		if player.Parent == Players then
			Profiles[player] = profile
			print(`Profile loaded for {player.DisplayName}`)
			local player_replica = ReplicaServer.New({
				Data = profile.Data,
				Tags = { player.UserId },
				Token = DataToken,
			})
			player_replica:Replicate()
			Replicas[player] = player_replica

			local leaderstats = Instance.new("Folder")
			leaderstats.Name = "leaderstats"
			leaderstats.Parent = player

			local Money = Instance.new("NumberValue")
			Money.Name = "Money"
			Money.Parent = leaderstats
			Money.Value = profile.Data.Money
			task.spawn(function()
				task.wait(5)
				player_replica:Set({ "Money" }, profile.Data.Money + 1_000)
				Money.Value = player_replica.Data.Money
			end)
			for i, v in profile.Data.Inventory do
				local newInstanceValue = Instance.new("NumberValue")
				newInstanceValue.Parent = player
				newInstanceValue.Name = i
				newInstanceValue.Value = v
			end
		else
			profile:EndSession()
		end
	else
		player:Kick(`Profile load fail - Please Rejoin`)
	end
end

function Data.GetReplica(player: Player)
	return Promise.new(function(resolve, reject)
		-- assert(typeof(player) == "Instance" and player:IsDescendantOf(Players), "Value passed is not a valid player")
		if not Profiles[player] then
			repeat
				if player then
					task.wait()
				else
					reject(`Player left game`)
				end
			until Profiles[player] and Replicas[player]
		end
		local profile = Profiles[player]
		local playerReplica = Replicas[player]

		if profile and profile:IsActive() then
			if playerReplica and playerReplica:IsActive() then
				resolve(playerReplica)
			else
				reject(`Problem with replica`)
			end
		else
			reject(`Profile did not exist or wasn't active`)
		end
	end)
end

function Data.Init()
	Players.PlayerAdded:Connect(PlayerAdded)
	for _, player in Players:GetPlayers() do
		task.spawn(PlayerAdded, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		local Profile = Profiles[player]
		local player_replica = Replicas[player]
		if Profile ~= nil then
			Profile:EndSession()
		end
		if player_replica ~= nil then
			player_replica:Destroy()
		end
	end)
end

return Data
