
local function overlayPNG(mapUI, x, y, scale, layerName, tex, alpha)
	local texture = getTexture(tex)
	if not texture then return end
	local mapAPI = mapUI.javaObject:getAPIv1()
	local styleAPI = mapAPI:getStyleAPI()
	local layer = styleAPI:newTextureLayer(layerName)
	local MINZ = 0
	layer:setMinZoom(MINZ)
	layer:addFill(MINZ, 255, 255, 255, (alpha or 1.0) * 255)
	layer:addTexture(MINZ, tex)
	layer:setBoundsInSquares(x, y, x + texture:getWidth() * scale, y + texture:getHeight() * scale)
end

LootMaps.Init.TikitownLootableMap = function(mapUI)
	local mapAPI = mapUI.javaObject:getAPIv1()
	MapUtils.initDirectoryMapData(mapUI, 'media/maps/Tikitown')
	MapUtils.initDefaultStyleV1(mapUI)
	--replaceWaterStyle(mapUI)
	mapAPI:setBoundsInSquares(6600, 6900, 7800, 7800)
	overlayPNG(mapUI, 6615, 6950, 0.4, "badge", "media/textures/worldMap/TikitownBadge.png")
	overlayPNG(mapUI, 7550, 7600, 0.4, "legend", "media/textures/worldMap/Legend.png")
	MapUtils.overlayPaper(mapUI)
	-- This is the only map with different x/y scales
--	overlayPNG2(mapUI, 20*300-2, 17*300-69, 0.385, 0.455, "media/ui/LootableMaps/riversidemap.png", 0.5)
end

LootMaps.Init.Tikitown_quest1_map1 = function(mapUI)
	-- Your custom initialization for PZAZ_hitlist1
	local mapAPI = mapUI.javaObject:getAPIv1()
	MapUtils.initDirectoryMapData(mapUI, 'media/maps/Muldraugh, KY')
	mapAPI:setBoundsInSquares(10540, 9240, 12990, 10480)
	overlayPNG(mapUI, 10524, 9222, 1.0, "lootMapPNG", "media/ui/LootableMaps/Tikitown_Quest_Map_1.png", 1.0)
end

LootMaps.Init.Tikitown_quest1_map2 = function(mapUI)
	-- Your custom initialization for PZAZ_hitlist1
	local mapAPI = mapUI.javaObject:getAPIv1()
	MapUtils.initDirectoryMapData(mapUI, 'media/maps/Muldraugh, KY')
	mapAPI:setBoundsInSquares(10540, 9240, 12990, 10480)
	overlayPNG(mapUI, 10524, 9222, 1.0, "lootMapPNG", "media/ui/LootableMaps/Tikitown_Quest_Map_2.png", 1.0)
end

LootMaps.Init.Tikitown_quest1_map3 = function(mapUI)
	-- Your custom initialization for PZAZ_hitlist1
	local mapAPI = mapUI.javaObject:getAPIv1()
	MapUtils.initDirectoryMapData(mapUI, 'media/maps/Muldraugh, KY')
	mapAPI:setBoundsInSquares(10540, 9240, 12990, 10480)
	overlayPNG(mapUI, 10524, 9222, 1.0, "lootMapPNG", "media/ui/LootableMaps/Tikitown_Quest_Map_3.png", 1.0)
end

LootMaps.Init.Tikitown_quest1_map4 = function(mapUI)
	-- Your custom initialization for PZAZ_hitlist1
	local mapAPI = mapUI.javaObject:getAPIv1()
	MapUtils.initDirectoryMapData(mapUI, 'media/maps/Muldraugh, KY')
	mapAPI:setBoundsInSquares(10540, 9240, 12990, 10480)
	overlayPNG(mapUI, 10524, 9222, 1.0, "lootMapPNG", "media/ui/LootableMaps/Tikitown_Quest_Map_4.png", 1.0)
end