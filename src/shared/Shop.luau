return {
	[1] = {
		Name = "Simple Machine", -- name of machine
		Price = 150, -- price of machine
		Description = "Really interesting description about the machine", -- short description of machine
		Stats = {
			Cooldown = 5, -- time in seconds it takes to generate
			BaseValue = 2, -- base value of toilet paper before being upgraded
		},
		CameraCFrame = CFrame.new(35, 4.5, -27),
	},
	[2] = {
		Name = "Advanced Machine",
		Price = 350,
		Description = "Slightly Better than the previous machine.",
		Stats = {
			Cooldown = 3.5,
			BaseValue = 5,
		},
		CameraCFrame = CFrame.new(35, 4.5, -22),
	},
	[3] = {
		Name = "Testing Machine",
		Price = 400,
		Description = "Just a machine for testing",
		Stats = {
			Cooldown = 99,
			BaseValue = 99,
		},
		CameraCFrame = CFrame.new(35, 4.5, -17),
	},
}
