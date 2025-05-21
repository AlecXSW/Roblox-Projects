local Players = game:GetService("Players")
local Data = require(script.Data)
Data.Init()

Players.PlayerAdded:Connect(function(player)
	while player.Parent == Players do
		task.wait(0.01)
		Data.GetReplica(player):andThen(function(replica)
			replica:Set({ "Money" }, replica.Data.Money + 2_000_000_000)
			player.leaderstats.Money.Value = replica.Data.Money
		end)
	end
end)
