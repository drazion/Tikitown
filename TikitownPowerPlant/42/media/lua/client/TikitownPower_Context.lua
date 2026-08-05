require "TikitownPower_UI"
require "TikitownPower_StructUI"

local PLANT_TILES = {
    ["tikitown_power_plant_02_112"] = true,
    ["tikitown_power_plant_02_113"] = true,
    ["tikitown_power_plant_02_114"] = true,
    ["tikitown_power_plant_02_115"] = true,
    ["tikitown_power_plant_02_116"] = true,
    ["tikitown_power_plant_02_117"] = true,
}

local POWER_TILES = {
    ["tikitown_power_plant_02_27"] = true,
    ["tikitown_power_plant_02_28"] = true,
    ["tikitown_power_plant_02_29"] = true,
    ["tikitown_power_plant_02_30"] = true,
}

local TURBINE_TILES = {
    ["tikitown_power_plant_02_136"] = true,
    ["tikitown_power_plant_02_137"] = true,
    ["tikitown_power_plant_02_138"] = true,
    ["tikitown_power_plant_02_139"] = true,
}

local CONDENSER_TILES = {
    ["tikitown_power_plant_02_140"] = true,
    ["tikitown_power_plant_02_141"] = true,
}

local FURNACE_TILES = {
    ["tikitown_power_plant_02_142"] = true,
    ["tikitown_power_plant_02_143"] = true,
}

local PUMP_TILES = {
    ["tikitown_power_plant_02_144"] = true,
    ["tikitown_power_plant_02_145"] = true,
    ["tikitown_power_plant_02_146"] = true,
    ["tikitown_power_plant_02_147"] = true,
}

local function isPlantTile(obj)
    local spr = obj and obj:getSprite()
    return spr and PLANT_TILES[spr:getName()] == true
end

local function isPowerTile(obj)
    local spr = obj and obj:getSprite()
    return spr and POWER_TILES[spr:getName()] == true
end

local function isTurbineTile(obj)
    local spr = obj and obj:getSprite()
    return spr and TURBINE_TILES[spr:getName()] == true
end

local function isCondenserTile(obj)
    local spr = obj and obj:getSprite()
    return spr and CONDENSER_TILES[spr:getName()] == true
end

local function isFurnaceTile(obj)
    local spr = obj and obj:getSprite()
    return spr and FURNACE_TILES[spr:getName()] == true
end

local function isPumpTile(obj)
    local spr = obj and obj:getSprite()
    return spr and PUMP_TILES[spr:getName()] == true
end

----------------------------------------
-- RIGHT CLICK MENUS
----------------------------------------
local function addMenu(playerIndex, context, worldobjects)
    local player = getSpecificPlayer(playerIndex)

    for _, obj in ipairs(worldobjects) do
        if not instanceof(obj, "IsoObject") then
            -- skip non-objects

        elseif isPowerTile(obj) then
            context:addOption("Power Grid Control", obj, function()
                TikitownPower.openPowerUI()
            end)
            return

        else
            local spriteName = obj:getSprite() and obj:getSprite():getName() or ""

            -- Turbine tiles -> Turbine struct UI
            if isTurbineTile(obj) then
                local index = 1
                if spriteName == "tikitown_power_plant_02_137" then
                    index = 2
                elseif spriteName == "tikitown_power_plant_02_138" then
                    index = 3
                elseif spriteName == "tikitown_power_plant_02_139" then
                    index = 4
                end

                context:addOption("Turbine Status Report", obj, function()
                    TikitownPower.openStructUI("Turbine", index)
                end)
                return
            end

            -- Condenser tiles -> Condenser struct UI
            if isCondenserTile(obj) then
                local index = 1
                if spriteName == "tikitown_power_plant_02_141" then
                    index = 2
                end

                context:addOption("Condenser Status Report", obj, function()
                    TikitownPower.openStructUI("Condenser", index)
                end)
                return
            end

            -- Furnace tiles -> Furnace struct UI
            if isFurnaceTile(obj) then
                local index = 1
                if spriteName == "tikitown_power_plant_02_143" then
                    index = 2
                end

                context:addOption("Furnace Status Report", obj, function()
                    TikitownPower.openStructUI("Furnace", index)
                end)
                return
            end

            -- Pump tiles -> Pump struct UI
            if isPumpTile(obj) then
                local index = 1
                if spriteName == "tikitown_power_plant_02_145" then
                    index = 2
                elseif spriteName == "tikitown_power_plant_02_146" then
                    index = 3
                elseif spriteName == "tikitown_power_plant_02_147" then
                    index = 4
                end

                context:addOption("Pump Status Report", obj, function()
                    TikitownPower.openStructUI("Pump", index)
                end)
                return
            end

            -- General plant tile -> overview UI
            if isPlantTile(obj) then
                context:addOption("Inspect Power Systems", nil, TikitownPower.openUI)
                return
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(addMenu)

----------------------------------------
-- SYNC HANDLER
-- Fires when ModData.transmit("TikitownPowerGrid") is called server-side.
-- Merges the transmitted payload into local moddata and ensures
-- TikitownPower.modData (the reference getData() returns) points at the
-- same object, so populate() always reads fresh values.
----------------------------------------
Events.OnReceiveGlobalModData.Add(function(id, data)
    if id ~= "TikitownPowerGrid" then return end

    print("[TikitownPower] OnReceiveGlobalModData")

    local md = ModData.getOrCreate("TikitownPowerGrid")

    if data.turbines   ~= nil then md.turbines   = data.turbines   end
    if data.condensers ~= nil then md.condensers = data.condensers end
    if data.furnaces   ~= nil then md.furnaces   = data.furnaces   end
    if data.pumps      ~= nil then md.pumps      = data.pumps      end
    if data.parts      ~= nil then md.parts      = data.parts      end

    -- Keep TikitownPower.modData pointing at the same object so that
    -- getData() (which returns modData) sees the merged values.
    TikitownPower.modData = md

    if TikitownPower_StructUI and TikitownPower_StructUI.instance then
        print("[TikitownPower] Refreshing StructUI")
        TikitownPower_StructUI.instance:populate()
    end

    if TikitownPowerUI and TikitownPowerUI.instance then
        print("[TikitownPower] Refreshing PowerUI")
        TikitownPowerUI.instance:syncParts(md)
    end

    if TikitownPowerPowerUI and TikitownPowerPowerUI.instance then
        print("[TikitownPower] Refreshing PowerGridUI")
        TikitownPowerPowerUI.instance:refreshStatus()
    end
end)