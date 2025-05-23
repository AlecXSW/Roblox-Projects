local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
for _, v in script.Parent.Controllers:GetChildren() do
	require(v).Init()
end

local player = Players.LocalPlayer

local function GetTycoon()
	for _, v in workspace:WaitForChild("Tycoons"):GetChildren() do
		if v:GetAttribute("Owner") == player.UserId then
			return v
		end
	end
end

local playerTycoon = GetTycoon()

repeat
	playerTycoon = GetTycoon()
	task.wait(0.1)
until playerTycoon ~= nil
print("Local Player Tycoon Loaded")

local playerGui = player.PlayerGui
local inventory = playerGui:WaitForChild("Inventory")

ProximityPromptService.PromptTriggered:Connect(function(prompt, playerWhoTriggered)
	-- I called it a dropper because i consider it a dropper
	local isDropperPlot = prompt.Parent:GetAttribute("DropperPlot")
	local isUpgrader = prompt.Parent:GetAttribute("UpgraderPlot")

	if isDropperPlot then
		inventory.Enabled = true
		player:SetAttribute("PlotSelected", string.match(prompt.Parent.Name, "%[(%d+)%]"))
		player:SetAttribute("PlotType", "Dropper")
	elseif isUpgrader then
		-- Open Upgrader frame? (or) load the same frame as the "droppers" but replace it with upgraders (way harder lol) but.. might be more performant not sure yet
	end
end)
