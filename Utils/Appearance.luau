local function linearStep(a, b, c)
	return math.clamp( (c - a) / (b - a), 0, 1)
end

return function(x: number, y: number, height: number, appearanceMap: {[number]: Color3 | MaterialVariant}, SEED: number)
	if not (x and y and height) then return end
	local color = nil
	local material = nil
	local transparency = nil
	
	for i = 1, #appearanceMap do
		local colorData = appearanceMap[i]
		if height >= colorData.StartHeight then
			if colorData.UseNoise then
				local colorValue = math.noise(x / colorData.NoiseScale, y/ colorData.NoiseScale, SEED * 123)
				colorValue = (colorValue + 1) / 2

				local stepResult = linearStep(colorData.StartHeight, colorData.EndHeight, height)
				colorValue = (1 - stepResult) * colorValue + stepResult

				if colorValue > colorData.Threshold then
					color = colorData.Color
					material = colorData.Material
					transparency = colorData.Transparency
				end
			else
				color = colorData.Color
				material = colorData.Material
				transparency = colorData.Transparency
			end
		end
	end
	return material, color, transparency

end
