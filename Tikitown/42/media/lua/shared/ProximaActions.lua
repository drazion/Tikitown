-- media/lua/shared/ProximaActions.lua
local MOD = "TikitownProxima"

local function normalizeType(t)
    if not t then return nil end
    return t:gsub("%.", ":")
end

local function addStatSafe(playerObj, statEnum, amount)
    if not playerObj then return end
    local stats = playerObj:getStats()
    if not stats then return end

    if stats.add then
        stats:add(statEnum, amount)
        return true
    end

    return false
end

function ProximaInjection(food, character, player)
    local playerObj = character or player or getPlayer() or getSpecificPlayer(0)
    if not playerObj or not food then return end

    local itemTypeRaw = food:getFullType()
    local itemType = normalizeType(itemTypeRaw)

    -- Debug once if you need it
    -- print("ProximaInjection", itemTypeRaw, "=>", itemType, "isClient", isClient(), "isServer", isServer())

    local bodyDamage = playerObj:getBodyDamage()
    if not bodyDamage then return end

    if itemType == "Tikitown:ImmunoStasis3" then
        if bodyDamage.isInfected and bodyDamage:isInfected() then
            if bodyDamage.setInfectionMortalityDuration then bodyDamage:setInfectionMortalityDuration(-1) end
            if bodyDamage.setInfectionTime then bodyDamage:setInfectionTime(-1) end
            if bodyDamage.setInfectionLevel then bodyDamage:setInfectionLevel(0) end
        end
        return
    end

    if itemType == "Tikitown:NeuroCline7R" then
        if bodyDamage.AddGeneralHealth then bodyDamage:AddGeneralHealth(170) end
        return
    end

    if itemType == "Tikitown:Endurase6B" then
        
        local ok = addStatSafe(playerObj, CharacterStat.ENDURANCE, 1.0)

        if not ok then
            local stats = playerObj:getStats()
            if stats and stats.remove and CharacterStat and CharacterStat.FATIGUE then
                stats:remove(CharacterStat.FATIGUE, 1.0)
            end
        end

        local parts = bodyDamage:getBodyParts()
        if parts then
            for i = 0, parts:size() - 1 do
                local bp = parts:get(i)
                if bp and bp.setStiffness then bp:setStiffness(0) end
                if bp and bp.setAdditionalPain then bp:setAdditionalPain(0) end
                if bp and bp.setOldWoundPain then bp:setOldWoundPain(0) end
            end
        end
        return
    end
end
