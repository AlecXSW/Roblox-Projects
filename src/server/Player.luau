local Players = game:GetService("Players")
local mod = {}

local function CollisionSetup(player: Player)
	player.CharacterAdded:Connect(function(character)
		for _, part in character:GetDescendants() do
			if part:IsA("BasePart") or part:IsA("MeshPart") then
				part.CollisionGroup = "Player"
			end
		end
	end)
end

function mod.Init()
	for _, player in Players:GetPlayers() do
		task.spawn(CollisionSetup, player)
	end
	Players.PlayerAdded:Connect(CollisionSetup)
end

return mod
