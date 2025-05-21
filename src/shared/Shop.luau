return {
	[1] = {
		Name = "Simple Machine", -- name of machine
		Price = 150, -- price of machine
		Description = "Really interesting description about the machine", -- short description of machine
		Stats = {
			Cooldown = 5, -- time in seconds it takes to generate
			DropAmount = 1,
			BaseValue = 2, -- base value of toilet paper before being upgraded
		},
		CameraCFrame = CFrame.new(16, 6.5, 34),
	},
	[2] = {
		Name = "Advanced Machine",
		Price = 350,
		Description = "Slightly Better than the previous machine.",
		Stats = {
			Cooldown = 3.5,
			DropAmount = 2,
			BaseValue = 5,
		},
		CameraCFrame = CFrame.new(11, 6.5, 34),
	},
}
