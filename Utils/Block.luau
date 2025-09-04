local generated = workspace.Generated

return function(x: number, y: number, z: number, color: Color3, material: MaterialVariant, transparency: number)
	if not (x and y and z and color) then return end
	
	
	local block = Instance.new("Part")
	block.Parent = workspace
	block.Color = color
	block.Size = Vector3.new(1, 1, 1)
	block.Anchored = true
	block.Material = material
	block.CanCollide = true
	block.Position = Vector3.new(x, math.floor(y), z)
	block.Transparency = transparency
	
end
