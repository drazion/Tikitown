local function SpawnJennPlushie(square)
    if not square then return end

    local x, y, z = square:getX(), square:getY(), square:getZ()

    -- Only our target coordinates
    if (x == 6760 and y == 7356 and z == 0) or
       (x == 6760 and y == 7358 and z == 0) then
		
		
		local key = x .. "_" .. y .. "_" .. z
		local md = ModData.getOrCreate("JennPlushieData")
		

		if not md[key] then
			square:AddWorldInventoryItem("Tikitown.Jenntacles_Plush", 0.5, 0.5, 0.3)
			md[key] = true  -- permanently record this spot as "done"
			ModData.transmit("JennPlushieData") -- important for MP sync
		end
	end
end
Events.LoadGridsquare.Add(SpawnJennPlushie)
