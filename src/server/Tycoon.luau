local Players = game:GetService("Players")
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

function Tycoon:UpdateBank()
	local player = Players:GetPlayerByUserId(self.Owner)
	local Bank = self.Starter.Bank

	Data.GetReplica(player):andThen(function(replica)
		Bank.SurfaceGui.TextLabel.Text = `${FormatNumber.Simple.Format(replica.Data.Money)}`
		player.leaderstats.Money.Changed:Connect(function()
			Bank.SurfaceGui.TextLabel.Text = `${FormatNumber.Simple.Format(replica.Data.Money)}`
		end)
		-- task.spawn(function()
		-- 	while self.Model ~= nil do
		-- 		task.wait(1)
		-- 		Bank.SurfaceGui.TextLabel.Text = `${FormatNumber.Simple.Format(replica.Data.Money)}`
		-- 	end
		-- end)
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

	self.Model:PivotTo(newLocation)
	local StarterTycoon = self.Model.Starter
	StarterTycoon.Parent = workspace.Tycoons
	StarterTycoon:SetAttribute("Owner", self.Owner)
	self.Starter = StarterTycoon
	self.Location = ClaimedLocations[newLocation]

	local Character = player.Character or player.CharacterAdded:Wait()
	Character:PivotTo(newLocation)
	player.CharacterAdded:Connect(function(newCharacter)
		newCharacter:PivotTo(newLocation)
	end)

	local Plots = self.Starter.Plots
	local Tubes = self.Starter.Tubes

	Data.GetReplica(player):andThen(function(replica)
		for plotNum, value in replica.Data.Plots do
			print(plotNum, value)
			local plotPart = Plots[plotNum]
			local tubeModel = Tubes[plotNum]
			task.spawn(function()
				for _, v in tubeModel:GetChildren() do
					if v:IsA("MeshPart") then
						v.Transparency = v:GetAttribute("OGTransparency")
					end
				end
			end)
			local clonedMachine = ReplicatedStorage.Machines:FindFirstChild(value):Clone()
			clonedMachine.Parent = plotPart
			clonedMachine:PivotTo(plotPart.CFrame)
		end
	end)
	task.spawn(function()
		for _, v in self.Starter.KillOthers:GetChildren() do
			v.Touched:Connect(function(otherPart)
				local otherPlayer = Players:GetPlayerFromCharacter(otherPart.Parent)
				if otherPlayer == nil then
					return
				end
				if otherPlayer.UserId == self.Owner then
					return
				end
				local character = otherPlayer.Character or otherPlayer.CharacterAdded:Wait()
				character.Humanoid.Health = 0
			end)
		end
	end)
	return self
end

function Tycoon:AddToPlot(plot, item)
	if plot:GetAttribute("DropperPlot") then
	elseif plot:GetAttribute("UpgraderPlot") then
	end
end

function Tycoon:Destroy()
	self.Model:Destroy() -- destroy the players tycoon within serverstorage
	self.Starter:Destroy() -- destroy the base
	table.remove(ClaimedLocations, self.Location)
end

return Tycoon
