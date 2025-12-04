require "TikitownPower_Parts"

TikitownPower = TikitownPower or {}

TikitownPower.progressedDays = 0
TikitownPower.ElecDays       = 0

-------------------------------------------------
-- STRUCT COLLECTION MAP
-------------------------------------------------

local STRUCT_COLLECTIONS = {
    Turbine   = "turbines",
    Condenser = "condensers",
    Furnace   = "furnaces",
    Pump      = "pumps",
}

---------------------------------------------------------------------
-- REPAIR COUNT HELPERS
---------------------------------------------------------------------

local function getStructRepairTable(struct)
    if not struct.repairCount then
        struct.repairCount = {}
    end
    return struct.repairCount
end

local function getStructRepairCount(struct, partID)
    if struct.repairCount and type(struct.repairCount[partID]) == "number" then
        return struct.repairCount[partID]
    end
    return 0
end

-------------------------------------------------
-- SAVE / MODDATA HELPERS
-------------------------------------------------

-- Canonical getData is defined in TikitownPower_Parts.lua and handles seeding.
-- just use it here and keep a handy save function.
function TikitownPower.saveData()
    ModData.transmit("TikitownPowerGrid")
end

local function getCollection(structType)
    local collName = STRUCT_COLLECTIONS[structType] or "turbines"
    local data     = TikitownPower.getData()
    local coll     = data[collName]

    if type(coll) ~= "table" then
        coll = {}
        data[collName] = coll
    end

    return data, collName, coll
end

local function getPartDef(structType, partID)
    local defs = nil
    if     structType == "Turbine"   then defs = TikitownPower.TurbinePartDefs
    elseif structType == "Condenser" then defs = TikitownPower.CondenserPartDefs
    elseif structType == "Furnace"   then defs = TikitownPower.FurnacePartDef
    elseif structType == "Pump"      then defs = TikitownPower.PumpPartDef
    end

    if defs then
        return defs[partID]
    end
    return nil
end

-------------------------------------------------
-- DAILY WEAR & DESTRUCTION
-------------------------------------------------

local function applyDailyWear(data)
    local activated = data.plantActivated == true
    local running   = data.plantRunning   == true
	local runningWearMultiplier = SandboxVars.TikitownPower.RunningWearMultiplier
	
    -- Per-part daily condition loss
    for structType, collName in pairs(STRUCT_COLLECTIONS) do
        local coll = data[collName]
        if type(coll) == "table" then
            for key, struct in pairs(coll) do
                if type(struct) == "table" then
                    for partID, cond in pairs(struct) do
                        if type(cond) == "number" and cond > 0 then
                            local def      = getPartDef(structType, partID)
                            local wearRate = def and def.wear_rate or 0.5

                            if wearRate > 0 then
                                local delta = 0
                                if not activated then
                                    -- Standby wear, before plant ever turned on
                                    -- ZombRand(n) -> 0..n-1
                                    delta = ZombRand(math.floor(wearRate) + 1)
                                else
                                    -- After plant has been turned on at least once:
                                    -- random between 1 and wear_rate * runningWearMultiplier
                                    local upper = math.floor(wearRate * runningWearMultiplier)
                                    if upper < 1 then upper = 1 end
                                    -- ZombRand(a,b) -> a..b-1
                                    delta = ZombRand(1, upper + 1)
                                end

                                if delta > 0 then
                                    local newCond = cond - delta
                                    if newCond < 0 then newCond = 0 end
                                    struct[partID] = newCond
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- While grid is running, very low removable parts can self-destruct
    if running and SandboxVars.TikitownPower.PartsCanBeDestroyed then
        for structType, collName in pairs(STRUCT_COLLECTIONS) do
            local coll = data[collName]
            if type(coll) == "table" then
                for key, struct in pairs(coll) do
                    if type(struct) == "table" then
                        for partID, cond in pairs(struct) do
                            if type(cond) == "number" and cond > 0 and cond < 30 then
                                local def = getPartDef(structType, partID)
                                if def and def.removable ~= false then
                                    -- 5% daily chance to be destroyed
                                    if ZombRand(100) < 5 then
                                        struct[partID] = nil
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function TikitownPower.maybeDailyDegrade()
    local data = TikitownPower.getData()

    data.lastDegradeDay = data.lastDegradeDay or 0
    local currentDay = math.floor((getGameTime():getWorldAgeHours() / 24) + 0.01)

    if currentDay <= data.lastDegradeDay then
        return
    end
	
	
    local diff = currentDay - data.lastDegradeDay
	local degradeChance = SandboxVars.TikitownPower.DailyDegradeChance
    for _ = 1, diff do
		if ZombRand(10) < degradeChance then
			applyDailyWear(data)
		end
    end

    data.lastDegradeDay = currentDay

    TikitownPower.saveData()
end

-------------------------------------------------
-- HOURLY BREAKDOWN RISK
-------------------------------------------------

local function computeGroupAverage(structType)
    local data     = TikitownPower.getData()
    local collName = STRUCT_COLLECTIONS[structType]
    if not collName then return nil end

    local coll = data[collName]
    if type(coll) ~= "table" then return nil end

    local sum   = 0
    local count = 0

    for _, struct in pairs(coll) do
        if type(struct) == "table" then
            for _, cond in pairs(struct) do
                if type(cond) == "number" and cond > 0 then
                    sum   = sum + cond
                    count = count + 1
                end
            end
        end
    end

    if count == 0 then return nil end
    return sum / count
end

function TikitownPower.autoShutdown(reason)
    local data = TikitownPower.getData()
    data.plantRunning = false

    local today = math.floor((getGameTime():getWorldAgeHours() / 24) + 0.01)
    TikitownPower.modData.shutdownDay = today

    SandboxVars["ElecShutModifier"] = today
    getSandboxOptions():set("ElecShutModifier", today)

    if isServer() then
        sendServerCommand("TikitownPower", "UpdateSandbox", { futureDay = today })
    end

    print("[TikitownPower] Auto shutdown triggered: " .. tostring(reason))

    TikitownPower.saveData()
end

function TikitownPower.hourlyRiskCheck()
    local data = TikitownPower.getData()
    if not data.plantRunning then return end

    -- For each struct group (Turbine / Condenser / Furnace / Pump)
    for _, structType in ipairs({ "Turbine", "Condenser", "Furnace", "Pump" }) do
        local avg = computeGroupAverage(structType)
        if avg and avg < 45 then
            -- Below 45%, start risk
            if avg <= 20 then
                -- Force shutdown at or below 20%
                TikitownPower.autoShutdown("Critical " .. structType .. " damage")
                return
            else
                -- 10% at just under 45, +10% per ~5% drop
                local deficit = 45 - avg
                local steps   = math.floor(deficit / 5) + 1
                local chance  = steps * 10

                if chance < 10 then chance = 10 end
                if chance > 100 then chance = 100 end

                if ZombRand(100) < chance then
                    TikitownPower.autoShutdown("Instability in " .. structType)
                    return
                end
            end
        end
    end
end

-------------------------------------------------
-- SYNC METHOD (SP + MP SAFE)
-------------------------------------------------

local function sendSync(player)
    local data = TikitownPower.getData()
    print("[TikitownPower] sendSync")

    -- sync moddata to all clients
    ModData.transmit("TikitownPowerGrid")

    if isServer() then
        local payload = {
            turbines     = data.turbines,
            condensers   = data.condensers,
            furnaces     = data.furnaces,
            pumps        = data.pumps,
            parts        = data.parts,
            plantRunning = data.plantRunning,
        }

        if player then
            print("[TikitownPower] sendSync -> specific player")
            sendServerCommand(player, "TikitownPower", "SyncTTParts", payload)
        else
            print("[TikitownPower] sendSync -> all players")
            sendServerCommand("TikitownPower", "SyncTTParts", payload)
        end
    end
end

-------------------------------------------------
-- INITIALIZATION
-------------------------------------------------

local function setupModData()
    local data = TikitownPower.getData()
    TikitownPower.modData = data

    if isClient() then
        ModData.request("TikitownPowerGrid")
    end

    data.plantRunning   = data.plantRunning   or false
    data.plantActivated = data.plantActivated or false
    data.lastDegradeDay = data.lastDegradeDay or 0
    TikitownPower.modData.shutdownDay = TikitownPower.modData.shutdownDay or 0

    TikitownPower.calculateDays()
end

-------------------------------------------------
-- ELECTRIC GRID / DAY TICK
-------------------------------------------------

function TikitownPower.calculateDays()
    TikitownPower.progressedDays = math.floor((getGameTime():getWorldAgeHours() / 24) + 0.01)
    TikitownPower.ElecDays       = SandboxVars["ElecShutModifier"] - TikitownPower.progressedDays

    -- Apply daily wear when a new day rolls over
    TikitownPower.maybeDailyDegrade()

    -- Hourly risk checks when running & degraded
    TikitownPower.hourlyRiskCheck()
end

-------------------------------------------------
-- MAIN COMMAND HANDLER
-------------------------------------------------

Events.OnClientCommand.Add(function(modID, commandID, player, args)
    if modID ~= "TikitownPower" then return end

    args = args or {}

    -------------------------------------------------
    -- SHUT DOWN GRID NOW (manual)
    -------------------------------------------------
    if commandID == "ForceShutdown" then
        local today = math.floor((getGameTime():getWorldAgeHours() / 24) + 0.01)

        TikitownPower.modData.shutdownDay = today
        SandboxVars["ElecShutModifier"]   = today
        getSandboxOptions():set("ElecShutModifier", today)

        local data = TikitownPower.getData()
        data.plantRunning = false

        if isServer() then
            sendServerCommand("TikitownPower", "UpdateSandbox", { futureDay = today })
            ModData.transmit("TikitownPowerGrid")
        end

        TikitownPower.saveData()
        return
    end

    -------------------------------------------------
    -- FORCE RESTORE (manual plant ON)
    -------------------------------------------------
    if commandID == "ForceRestore" then
        local futureDay = math.floor((getGameTime():getWorldAgeHours() / 24) + 0.01) + 36500

        TikitownPower.modData.shutdownDay = futureDay
        SandboxVars["ElecShutModifier"]   = futureDay
        getSandboxOptions():set("ElecShutModifier", futureDay)

        local data = TikitownPower.getData()
        data.plantRunning   = true
        data.plantActivated = true  -- track that it has been turned on at least once

        if isServer() then
            sendServerCommand("TikitownPower", "UpdateSandbox", { futureDay = futureDay })
            ModData.transmit("TikitownPowerGrid")
        end

        TikitownPower.saveData()
        return
    end

    -------------------------------------------------
    -- REMOVE PART
    -------------------------------------------------
    if commandID == "RemovePart" then
        print("[TikitownPower] RemovePart")

        local part       = args.part
        local index      = args.index or 1
        local structType = args.structType or "Turbine"

        if not part then
            print("[TikitownPower] RemovePart missing part id")
            return
        end

        local data, collName, coll = getCollection(structType)
        local key    = structType .. tostring(index)
        local struct = coll[key]

        if not struct then
            print(string.format("[TikitownPower] RemovePart no %s entry for key %s", structType, key))
            return
        end

        local condition = struct[part] or 0
        struct[part]    = nil

        -- Force a new collection table so ModData syncs in SP
        local newColl = {}
        for k, v in pairs(coll) do
            newColl[k] = v
        end
        data[collName] = newColl

        TikitownPower.saveData()

        -- Drop the removed part as an item with matching condition
        local itemType = "TikitownPower." .. part
        local invItem  = player:getInventory():AddItem(itemType)

        if invItem and invItem.setCondition then
            invItem:setCondition(condition)
        end

        -- Only try to apply repair count if this part is actually removable
        local def = getPartDef(structType, part)
        local isRemovable = not (def and def.removable == false)

        if invItem and invItem.setHaveBeenRepaired and isRemovable then
            data.repairCounts = data.repairCounts or {}
            local rcKey        = structType .. ":" .. key .. ":" .. part
            local timesRepaired = data.repairCounts[rcKey] or 0
            invItem:setHaveBeenRepaired(timesRepaired)
        end

        player:Say("Removed " .. part .. " (" .. tostring(condition) .. "%)")

        sendSync(player)
        return
    end

    -------------------------------------------------
    -- INSTALL PART
    -------------------------------------------------
    if commandID == "InstallPart" then
        print("[TikitownPower] InstallPart")

        local part       = args.part
        local index      = args.index or 1
        local structType = args.structType or "Turbine"

        if not part then
            print("[TikitownPower] InstallPart missing part id")
            return
        end

        -- Make sure the player actually has the part in their inventory
        local itemType = "TikitownPower." .. part
        local inv      = player:getInventory()
        local item     = inv:FindAndReturn(itemType)

        if not item then
            print("[TikitownPower] InstallPart: player missing item " .. itemType)
            return
        end

        -- Read condition from the physical item
        local condition = 100
        if item.getCondition then
            condition = item:getCondition()
        end

        -- seed repair count from item
        local data = TikitownPower.getData()
        data.repairCounts = data.repairCounts or {}
        local rcKey = structType .. ":" .. structType .. tostring(index) .. ":" .. part
        if item.getHaveBeenRepaired then
            data.repairCounts[rcKey] = item:getHaveBeenRepaired()
        end

        -- Remove the item from inventory now that captured its condition
        inv:Remove(item)

        local _, collName, coll = getCollection(structType)
        local key    = structType .. tostring(index)
        local struct = coll[key]

        if not struct then
            print(string.format("[TikitownPower] InstallPart seeding %s for key %s", structType, key))
            struct    = {}
            coll[key] = struct
        end

        struct[part] = condition

        -- SP sync: create a new collection table so ModData notices the change
        local newColl = {}
        for k, v in pairs(coll) do
            newColl[k] = v
        end
        TikitownPower.getData()[collName] = newColl

        TikitownPower.saveData()

        player:Say("Installed " .. part .. " (" .. tostring(condition) .. "%)")
        sendSync(player)
        return
    end

    -------------------------------------------------
    -- REPAIR PART (DIMINISHING RETURNS)
    -------------------------------------------------
    if commandID == "RepairPart" then
        print("[TikitownPower] RepairPart")

        local partID     = args.part
        local index      = args.index or 1
        local structType = args.structType or "Turbine"

        if not partID then
            print("[TikitownPower] RepairPart missing part id")
            return
        end

        local data, collName, coll = getCollection(structType)
        local key    = structType .. tostring(index)
        local struct = coll[key]

        if not struct then
            struct    = {}
            coll[key] = struct
        end

        -- look up part def (for max condition + removable flag)
        local def      = getPartDef(structType, partID)
        local maxCond  = 100
        if def and def.max then
            maxCond = def.max
        end

        local current = struct[partID] or 0
        if current >= maxCond then
            -- already fully repaired, nothing to do
            return
        end

        -- is this part considered removable? (default = true)
        local isRemovable = true
        if def and def.removable == false then
            isRemovable = false
        end

        -- only keep a persistent repair counter for *removable* parts
        data.repairCounts = data.repairCounts or {}
        local rcKey         = structType .. ":" .. key .. ":" .. partID
        local timesRepaired = 0
        if isRemovable then
            timesRepaired = data.repairCounts[rcKey] or 0
        end

        -- bump counter ONLY for removable parts
        if isRemovable then
            timesRepaired = timesRepaired + 1
            data.repairCounts[rcKey] = timesRepaired
        end

        -- if counter is still 0 (non-removable or never stored), treat as first repair
        if timesRepaired < 1 then
            timesRepaired = 1
        end

        -- approximate skill like GenericFixer
        local maint = 0
        if player and player.getPerkLevel then
            maint = player:getPerkLevel(Perks.Maintenance) or 0
        end

        local factor = 2   -- same idea as GenericBetterFixing

        -- mirror GenericFixer: (factor * 10 * (1/timesRepaired) + min(skill * 5, 25)) / 100
        local percentFixed = (factor * 10 * (1 / timesRepaired) + math.min(maint * 5, 25)) / 100

        local missing = maxCond - current
        local delta   = math.floor(missing * percentFixed + 0.5)
        if delta < 1 then delta = 1 end
        if delta > missing then delta = missing end

        local newCond = current + delta
        if newCond > maxCond then newCond = maxCond end

        struct[partID] = newCond

        -- SP sync: new collection table so ModData notices the change
        local newColl = {}
        for k, v in pairs(coll) do
            newColl[k] = v
        end
        data[collName] = newColl

        TikitownPower.saveData()
        sendSync(player)
        return
    end
end)  -- 

-------------------------------------------------
-- STARTUP
-------------------------------------------------

local function serverStartup()
    if not isServer() then return end

    if TikitownPower.modData.shutdownDay > 0 then
        SandboxVars["ElecShutModifier"] = TikitownPower.modData.shutdownDay
        getSandboxOptions():set("ElecShutModifier", TikitownPower.modData.shutdownDay)
    end

    TikitownPower.calculateDays()
end

Events.OnInitGlobalModData.Add(setupModData)
Events.EveryHours.Add(TikitownPower.calculateDays)
Events.OnServerStarted.Add(serverStartup)
