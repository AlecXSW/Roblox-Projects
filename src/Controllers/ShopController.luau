local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local Players = game:GetService("Players")
local Shop = {}

-- local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local currentMachine = 1

-- Get Shop Info
local ShopInfo = require(ReplicatedStorage.Shared.Shop)

local function SwitchCamera(newCF: CFrame)
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = newCF
end

function Shop.Init()
	for _, prompt in CollectionService:GetTagged("SwitchMachine") do
		print(prompt)
		prompt.Triggered:Connect(function()
			print("ACTIVATED")
			local currentInfo = ShopInfo[currentMachine]
			print(currentInfo)
			SwitchCamera(currentInfo.CameraCFrame)
		end)
	end
end

return Shop
