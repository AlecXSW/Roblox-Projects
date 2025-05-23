local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Tycoon = {}
Tycoon.__index = Tycoon

local Locations = {
	CFrame.new(-0.5, 11.625, 104.5) * CFrame.Angles(0, math.rad(-90), 0),
	CFrame.new(-133.75, 11.625, -95.5) * CFrame.Angles(0, math.rad(-90), 0),
}

local ClaimedLocations = {}
local Data = require(script.Parent.Data)
local FormatNumber = require(ReplicatedStorage.Packages.FormatNumber)

-- Cooldowns
local PadDebounce = {}

local function UpdateBank(tycoon, player_replica)
	local player = Players:GetPlayerByUserId(tycoon.Owner)

	local Bank = tycoon.Starter.Bank
	Bank.SurfaceGui.TextLabel.Text = `${FormatNumber.Simple.Format(player_replica.Data.Money)}`
	player.leaderstats.Money.Changed:Connect(function()
		Bank.SurfaceGui.TextLabel.Text = `${FormatNumber.Simple.Format(player_replica.Data.Money)}`
	end)
end

function Tycoon.new(player: Player)
	local self = setmetatable({
		Owner = player.UserId,
		Model = ServerStorage.TycoonModel:Clone(),
	}, Tycoon.__index)

	self.Model.Parent = ServerStorage
	self.Model:SetAttribute("Owner", player.UserId)

	local newLocation
	repeat
		newLocation = Locations[math.random(1, #Locations)]
		task.wait()
	until not table.find(ClaimedLocations, newLocation)
	table.insert(ClaimedLocations, newLocation)

	-- Setup The Tycoon
	self.Model:PivotTo(newLocation)
	local StarterTycoon = self.Model.Starter
	StarterTycoon.Parent = workspace.Tycoons
	StarterTycoon:SetAttribute("Owner", self.Owner)
	self.Starter = StarterTycoon
	self.Location = ClaimedLocations[newLocation]
	self.Builds = self.Model.Builds :: Folder

	-- Teleport Player To Their Tycoon (Change to a spawn part)
	local Character = player.Character or player.CharacterAdded:Wait()
	Character:PivotTo(newLocation)
	player.CharacterAdded:Connect(function(newCharacter)
		newCharacter:PivotTo(newLocation)
	end)

	-- Load Tycoon Data
	Data.GetReplica(player):andThen(function(playerReplica)
		-- Pads Setup
		task.spawn(UpdateBank, self, playerReplica)
		task.spawn(function()
			for _, pad in self.Starter.Pads:GetChildren() do
				pad.Button.Touched:Connect(function(otherpart)
					local touchedPlayer = Players:GetPlayerFromCharacter(otherpart.Parent)
					-- not a player
					if not touchedPlayer then
						return
					end
					-- not the owner
					if touchedPlayer.UserId ~= self.Owner then
						return
					end
					-- still in cooldown
					if PadDebounce[touchedPlayer] then
						return
					end
					-- cannot afford
					if playerReplica.Data.Money < pad:GetAttribute("Price") then
						return
					end

					playerReplica:Set({ "Money" }, playerReplica.Data.Money - pad:GetAttribute("Price"))
					player.leaderstats.Money.Value = playerReplica.Data.Money

					local Build = self.Builds:FindFirstChild(pad.Name)
					Build.Parent = self.Starter.Built

					playerReplica:TableInsert({ "OwnedPads" }, pad.Name)
					-- print(playerReplica.Data.OwnedPads)
					pad:Destroy()

					PadDebounce[touchedPlayer] = true
					task.wait(0.15)
					PadDebounce[touchedPlayer] = nil
				end)
			end
		end)
		-- Load Owned Pads
		task.spawn(function()
			for _, ownedPad in playerReplica.Data.OwnedPads do
				local padModel = self.Starter.Pads:FindFirstChild(ownedPad)
				padModel:Destroy()
				local build = self.Builds:FindFirstChild(ownedPad)
				build.Parent = self.Starter.Built
				print(`Loaded: {ownedPad}`)
			end
		end)
	end)
	return self
end

function Tycoon:Destroy()
	self.Model:Destroy() -- destroy the players tycoon within serverstorage
	self.Starter:Destroy() -- destroy the model within workspace
	table.remove(ClaimedLocations, self.Location)
end

return Tycoon
