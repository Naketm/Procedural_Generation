local utils = script.Utils
local maps = script.Maps
local _settings = script.Settings

local NoiseSettings = require(_settings.Noise)
local MapSettings = require(_settings.Map)

local NoiseUtil = require(utils.Noise)
local BlockUtil = require(utils.Block)
local AppearanceUtil = require(utils.Appearance)
local waitUtil = require(utils.quickWait)

local AppearanceMap = require(maps.Appearance)

local adjacentCoordinates = {
	Vector2.new(1,0),
	Vector2.new(0,1),
	Vector2.new(-1,0),
	Vector2.new(0,-1),
}
local blocks = {}

local Generation = {
	SEED = os.time()
}

export type Generation = typeof(Generation)

function Generation.getHeight(self: Generation, x: number, y: number)
	return NoiseUtil(
		x, 
		y, 
		NoiseSettings.OCTAVES, 
		NoiseSettings.LACUNARITY, 
		NoiseSettings.PERSISTENCE, 
		NoiseSettings.NOISE_SCALE,
		self.SEED
	) * NoiseSettings.HEIGHT_SCALE		
end

function Generation.start(self: Generation)
	local start = tick()
	local mapSize = MapSettings.MAP_SIZE
	local sizeX, sizeY = mapSize.X, mapSize.Y

	for x = 1, sizeX, 1 do
		for y = 1, sizeY, 1 do
			local height = self:getHeight(x, y)
			local material, color, transparency = AppearanceUtil(x, y, height, AppearanceMap, self.SEED)

			table.insert(blocks, {
				x, height, y, color, material, transparency
			})

			for i = 1, #adjacentCoordinates do
				local offset = adjacentCoordinates[i]
				local adjacentX, adjacentY = offset.X + x, offset.Y + y
				local adjacentHeight = self:getHeight(adjacentX, adjacentY)

				local flooredAdjacentHeight, flooredHeight = math.floor(adjacentHeight), math.floor(height)
				if flooredAdjacentHeight < (flooredHeight + 1) then continue end	
				

				for j = 1, flooredAdjacentHeight - flooredHeight - 1 do
					local newBlockHeight = adjacentHeight - j
					local newBlockMaterial, newBlockColor, newBlockTransparency = AppearanceUtil(adjacentX, adjacentY, newBlockHeight, AppearanceMap, self.SEED)
	
					table.insert(blocks, {
						adjacentX, newBlockHeight , adjacentY, newBlockColor, newBlockMaterial, newBlockTransparency
					})
				end
			end
		end
	end
	print(`generation time: {tick() - start}`)
	
	local chunkStart = tick()
	
	local batchSize = 500
	for i = 1, #blocks do
		local blockData = blocks[i]
		BlockUtil(blockData[1], blockData[2], blockData[3], blockData[4], blockData[5], blockData[6])
		if i % batchSize == 0 then 
			task.wait()
		end
	end
	
	print(`completed in {tick() - chunkStart}`)
	--[[
	local water = Instance.new("Part")
	water.BottomSurface = Enum.SurfaceType.Smooth
	water.TopSurface = Enum.SurfaceType.Smooth
	water.Anchored = true
	water.Parent = workspace
	water.Size = Vector3.new(2048, 0, 2048)
	water.Position = Vector3.new(sizeX / 2, 3, sizeY- 5 / 2)
	water.Color = Color3.fromRGB(102, 243, 255)
	water.Transparency = 0.7
	--]]
end

return Generation
