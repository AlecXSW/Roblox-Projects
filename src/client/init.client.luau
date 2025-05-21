for _, v in script.Parent.Controllers:GetChildren() do
	require(v).Init()
end
