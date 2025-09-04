return function(x, y, octaves, lacunarity, persistence, scale, SEED)
	local value = 0
	
	local x1 = x
	local y1 = y
	
	local amp = 1
	
	for i = 1, octaves, 1 do
		value += math.abs(math.noise(x1 / scale, y1 / scale, SEED) * amp)
		
		x1 *= lacunarity
		y1 *= lacunarity
		
		amp *= persistence
	end
	value = value ^ 2
	return math.clamp(value, -1, 1)
end
