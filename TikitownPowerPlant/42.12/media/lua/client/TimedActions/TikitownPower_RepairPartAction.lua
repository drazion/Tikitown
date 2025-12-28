require "TimedActions/ISBaseTimedAction"

TikitownPower_RepairPartAction = ISBaseTimedAction:derive("TikitownPower_RepairPartAction")

----------------------------------------------------
-- REPAIR REQUIREMENTS PER PART
-- Single source of truth lives in TikitownPower_Parts.lua
----------------------------------------------------

local RepairDefs = TikitownPower and TikitownPower.RepairRequirements or {}

----------------------------------------------------
-- SMALL HELPERS
----------------------------------------------------

-- Look up the shared part definition (for rep_anim / rep_sound)
local function getPartDef(partID)
    if not TikitownPower then return nil end

    if TikitownPower.TurbinePartDefs and TikitownPower.TurbinePartDefs[partID] then
        return TikitownPower.TurbinePartDefs[partID]
    end
    if TikitownPower.CondenserPartDefs and TikitownPower.CondenserPartDefs[partID] then
        return TikitownPower.CondenserPartDefs[partID]
    end
    if TikitownPower.FurnacePartDef and TikitownPower.FurnacePartDef[partID] then
        return TikitownPower.FurnacePartDef[partID]
    end
    if TikitownPower.PumpPartDef and TikitownPower.PumpPartDef[partID] then
        return TikitownPower.PumpPartDef[partID]
    end
    if TikitownPower.parts and TikitownPower.parts[partID] then
        return TikitownPower.parts[partID]
    end

    return nil
end

local SKILL_MAP = {
    Maintenance  = Perks.Maintenance,
    MetalWelding = Perks.MetalWelding,
    Electricity  = Perks.Electricity,
}

----------------------------------------------------
-- TRANSLATED DISPLAY NAMES FOR ITEMS/TOOLS
----------------------------------------------------
local function getItemDisplayName(fullType)
    if not fullType then
        return "Unknown item"
    end

    -- Try default translation key: ItemName_Module.Type
    if getTextOrNull then
        local key = "ItemName_" .. fullType
        local txt = getTextOrNull(key)
        if txt and txt ~= "" then
            return txt
        end
    end

    -- Fallback: strip module prefix "Base." -> "Something"
    local dotPos = string.find(fullType, "%.")
    if dotPos then
        return string.sub(fullType, dotPos + 1)
    end

    return fullType
end



local function findItem(inv, fullType)
    local items = inv:getItems()
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it:getFullType() == fullType then
            return it
        end
    end
    return nil
end

-- KEY: find *any* tool of this type with enough current uses
local function findToolWithUses(inv, fullType, neededUses)
    local items = inv:getItems()
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it:getFullType() == fullType then
            if not neededUses or neededUses <= 0 then
                return it
            end
            if it.getCurrentUses then
                local usesLeft = it:getCurrentUses()
                if usesLeft >= neededUses then
                    return it
                end
            end
        end
    end
    return nil
end

local function countItem(inv, fullType)
    local items = inv:getItems()
    local c = 0
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it:getFullType() == fullType then
            c = c + 1
        end
    end
    return c
end

local function hasItems(inv, fullType, count)
    return countItem(inv, fullType) >= count
end

----------------------------------------------------
-- REQUIREMENT CHECK
----------------------------------------------------

local function checkRequirements(character, partID)
    local def = RepairDefs[partID]
    if not def then
        -- no special definition, allow repair
        return true, nil
    end

    local inv = character:getInventory()

    ------------------------------------------------
    -- SKILLS
    ------------------------------------------------
    if def.skills then
        for humanName, needed in pairs(def.skills) do
            local perk = SKILL_MAP[humanName]
            if perk and character:getPerkLevel(perk) < needed then
                local skillLabel = humanName
                return false, skillLabel .. " " .. tostring(needed) .. " required"
            end
        end
    end

    ------------------------------------------------
    -- MATERIAL ITEMS
    ------------------------------------------------
    if def.items then
        for _, req in ipairs(def.items) do
            local count    = req.count or 1
            local fullType = req.type
            local label    = req.label

            -- If label not provided, use translation or sane fallback
            if not label or label == "" then
                label = getItemDisplayName(fullType)
            end

            if not hasItems(inv, fullType, count) then
                -- This is where the crash was happening before when label == nil
                return false, "Missing " .. tostring(count) .. "x " .. tostring(label)
            end
        end
    end

    ------------------------------------------------
    -- TOOLS (not consumed except drainables like BlowTorch)
    ------------------------------------------------
    if def.tools then
        for _, tool in ipairs(def.tools) do
            local fullType = tool.type
            local label    = tool.label

            if not label or label == "" then
                label = getItemDisplayName(fullType)
            end

            if fullType == "Base.BlowTorch" and tool.uses and tool.uses > 0 then
                -- Find ANY blowtorch with enough uses
                local torch = findToolWithUses(inv, fullType, tool.uses)
                if not torch then
                    return false,
                        label .. " needs at least " .. tostring(tool.uses) .. " uses left"
                end
            else
                local it = findItem(inv, fullType)
                if not it then
                    return false, "Missing tool " .. label
                end
            end
        end
    end

    return true, nil
end


----------------------------------------------------
-- MATERIAL / TOOL CONSUMPTION
----------------------------------------------------

local function consumeMaterials(character, partID)
    local def = RepairDefs[partID]
    if not def then return end

    local inv = character:getInventory()

    ------------------------------------------------
    -- 1) Consume material items only
    ------------------------------------------------
    if def.items then
        for _, req in ipairs(def.items) do
            local remaining = req.count or 0
            if remaining > 0 then
                -- remove items one by one so only consume the exact amount
                local items = inv:getItems()
                for i = items:size() - 1, 0, -1 do
                    local it = items:get(i)
                    if it:getFullType() == req.type then
                        inv:Remove(it)
                        remaining = remaining - 1
                        if remaining <= 0 then
                            break
                        end
                    end
                end
            end
        end
    end

    ------------------------------------------------
    -- 2) Use drainable tools, do not remove them
    --    Any tool entry with "uses = N" is treated
    --    as a drainable item
    ------------------------------------------------
    if def.tools then
        for _, tool in ipairs(def.tools) do
            if tool.uses and tool.uses > 0 then
                local titem
                if tool.type == "Base.BlowTorch" then
                    -- NEW: drain from a torch that actually has enough uses
                    titem = findToolWithUses(inv, tool.type, tool.uses)
                else
                    titem = findItem(inv, tool.type)
                end

                -- DrainableComboItem has a Use() method
                if titem and titem.Use then
                    for i = 1, tool.uses do
                        titem:Use()
                    end
                end
            end
        end
    end
end

----------------------------------------------------
-- TIMED ACTION IMPLEMENTATION
----------------------------------------------------

function TikitownPower_RepairPartAction:isValid()
    local ok, reason = checkRequirements(self.character, self.partID)
    if not ok and reason then
        self.character:Say(reason)
    end
    return ok
end

function TikitownPower_RepairPartAction:waitToStart()
    return false
end

function TikitownPower_RepairPartAction:start()
    ISBaseTimedAction.start(self)

    -- remember what the player was holding / wearing
    self.oldPrimary = self.character:getPrimaryHandItem()
    self.oldMask    = self.character:getWornItem("Mask")

    local animName  = "Loot"
    local soundName = nil

    -- Prefer per-part animation/sound from the partDef
    local partDef = self.partDef or getPartDef(self.partID)
    self.partDef  = partDef

    if partDef then
        -- rep_anim drives the action animation
        if partDef.rep_anim then
            local ra = string.lower(partDef.rep_anim)
            if ra == "blowtorch" then
                animName = "BlowTorch"
            elseif ra == "dismantle" then
                animName = "Dismantle"
            else
                animName = partDef.rep_anim
            end
        end

        -- rep_sound drives the sound event
        if partDef.rep_sound then
            local rs = string.lower(partDef.rep_sound)
            if rs == "blowtorch" then
                soundName = "BlowTorch"
            elseif rs == "dismantle" then
                soundName = "Dismantle"
            else
                soundName = partDef.rep_sound
            end
        end
    end

    -- Fall back to RepairRequirements.anim if partDef didn't specify
    if animName == "Loot" and self.def and self.def.anim then
        animName = self.def.anim
    end
    if not soundName then
        if animName == "BlowTorch" then
            soundName = "BlowTorch"
        elseif animName == "Dismantle" then
            soundName = "Dismantle"
        end
    end

    ------------------------------------------------
    -- Equip tools only for blowtorch-type repairs
    ------------------------------------------------
    if animName == "BlowTorch" then
        if self.torch then
            self.character:setPrimaryHandItem(self.torch)
        end
        if self.mask then
            self.character:setWornItem("Mask", self.mask)
        end
        self.character:reportEvent("EventBlowTorch")
    end

    self:setActionAnim(animName)

    -- start sound (if have one)
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:getEmitter():stopSound(self.sound)
    end
    if soundName then
        self.sound = self.character:getEmitter():playSound(soundName)
    else
        self.sound = nil
    end
end

function TikitownPower_RepairPartAction:stop()
    -- stop welding sound if it’s still going
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:getEmitter():stopSound(self.sound)
    end

    -- restore whatever the player was holding before
    if self.oldPrimary or self.oldSecondary then
        self.character:setPrimaryHandItem(self.oldPrimary)
        self.character:setWornItem("Mask", self.oldMask)
    end

    ISBaseTimedAction.stop(self)
end

function TikitownPower_RepairPartAction:update()
    self.character:setMetabolicTarget(Metabolics.HeavyDomestic)
end

function TikitownPower_RepairPartAction:perform()
    -- stop welding sound if it’s still going
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:getEmitter():stopSound(self.sound)
    end

    -- restore previous hand items
    if self.oldPrimary or self.oldSecondary then
        self.character:setPrimaryHandItem(self.oldPrimary)
        self.character:setWornItem("Mask", self.oldMask)
    end

    -- consume materials and drainable tool uses
    consumeMaterials(self.character, self.partID)

    ------------------------------------------------
    -- NEW: if this repair uses "refuelgascan"
    -- animation, give an empty industrial can back
    ------------------------------------------------
    local partDef = self.partDef or getPartDef(self.partID)
    if partDef and partDef.rep_anim then
        local ra = string.lower(partDef.rep_anim)
        if ra == "refuelgascan" then
            self.character:getInventory():AddItem("TikitownPower.EmptyIndustrialCan")
        end
    end
    ------------------------------------------------

    -- tell the server to set this part to 100% condition
    sendClientCommand(self.character, "TikitownPower", "RepairPart", {
        part            = self.partID,
        index           = self.index,
        structType      = self.structType or "Turbine",
        targetCondition = 100,
    })

    ISBaseTimedAction.perform(self)

    -- Close Struct UI so it can be reopened with fresh data
    if TikitownPower_StructUI and TikitownPower_StructUI.instance then
        TikitownPower_StructUI.instance:close()
    end
end


----------------------------------------------------
-- CONSTRUCTOR
----------------------------------------------------

function TikitownPower_RepairPartAction:new(character, partID, partLabel, index, structType, time)
    local o = ISBaseTimedAction.new(self, character)
    o.stopOnWalk = true
    o.stopOnRun  = true
    o.maxTime    = time or 200

    o.partID     = partID
    o.partLabel  = partLabel
    o.index      = index
    o.structType = structType  -- "Turbine", "Condenser", "Furnace", "Pump"

    -- link to shared repair requirements (materials/skills/tools)
    o.def = TikitownPower and TikitownPower.RepairRequirements
            and TikitownPower.RepairRequirements[partID] or nil

    -- link to shared part definition (anim/sound, wear_rate, etc.)
    o.partDef = getPartDef(partID)

    -- cache tools and old hand items for welding
    local inv = character:getInventory()
    o.torch = nil
    o.mask  = nil

    if o.def and o.def.tools then
        for _, tool in ipairs(o.def.tools) do
            if tool.type == "Base.BlowTorch" then
                if tool.uses and tool.uses > 0 then
                    -- use the same selection logic as the requirement check
                    o.torch = findToolWithUses(inv, "Base.BlowTorch", tool.uses)
                else
                    o.torch = inv:FindAndReturn("Base.BlowTorch")
                end
            elseif tool.type == "Base.WeldingMask" then
                o.mask = inv:FindAndReturn("Base.WeldingMask")
            end
        end
    end

    o.oldPrimary   = nil
    o.oldSecondary = nil
    o.oldMask      = nil
    o.sound        = nil

    return o
end
