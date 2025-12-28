require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISScrollingListBox"

--=================================================================
--  Generic Structure UI
--  Handles Turbine / Condenser / Furnace / Pump etc.
--=================================================================

TikitownPower_StructUI = ISPanel:derive("TikitownPower_StructUI")

-- Map structType -> where data and part defs live
local STRUCT_META = {
    Turbine = {
        dataField   = "turbines",        -- data.turbines[key]
        keyPrefix   = "Turbine",         -- key = "Turbine"..index
        partDefsKey = "TurbinePartDefs", -- TikitownPower.TurbinePartDefs
    },
    Condenser = {
        dataField   = "condensers",
        keyPrefix   = "Condenser",
        partDefsKey = "CondenserPartDefs",
    },
    Furnace = {
        dataField   = "furnaces",
        keyPrefix   = "Furnace",
        partDefsKey = "FurnacePartDef",
    },
    Pump = {
        dataField   = "pumps",
        keyPrefix   = "Pump",
        partDefsKey = "PumpPartDef",
    },
    -- fallback / catch-all
    Other = {
        dataField   = "structures",
        keyPrefix   = "Struct",
        partDefsKey = "parts",
    },
}

local MANUAL_BY_STRUCT = {
    Turbine   = "TikitownPower.PlantTurbineTechnicalManual",
    Pump      = "TikitownPower.PlantPumpTechnicalManual",
    Furnace   = "TikitownPower.PlantFurnaceTechnicalManual",
    Condenser = "TikitownPower.PlantCondenserTechnicalManual",
}

local REPAIR_RECIPE_BY_STRUCT = {
    Turbine   = "RepairTurbineRotor",          -- from PlantTurbineTechnicalManual
    Pump      = "RepairPumpSeals",             -- from PlantPumpTechnicalManual
    Furnace   = "RepairFurnaceControlSystem",  -- from PlantFurnaceTechnicalManual
    Condenser = "Cond_Store_Antifreeze",           -- from PlantCondTechnicalManual
}

local function hasUnlockedRepairs(player, structType)
    if not player then return false end
    local recipeName = REPAIR_RECIPE_BY_STRUCT[structType]
    if not recipeName then
        -- No mapping → don’t gate this struct type
        return true
    end
    return player:isRecipeKnown(recipeName)
end

--=================================================================
--  Translation Helper
--  Handles Turbine / Condenser / Furnace / Pump etc.
--=================================================================
local function getLocalizedItemLabel(req)
    if req.label then
        return req.label
    end
    if req.type then
        local n = getItemNameFromFullType(req.type)
        if n and n ~= "" then
            return n
        end
    end
    return "Unknown item"
end

-------------------------------------------------------------------
-- SIMPLE TOOLTIP FOR INSTALL / REMOVE
-------------------------------------------------------------------
local function buildSimpleTooltip(needsPart, hasPart, toolsOK, skillOK)
    local t = {}

    -- PART
    if needsPart then
        if hasPart then
            table.insert(t, "<RGB:0,1,0> Required part found </RGB>")
        else
            table.insert(t, "<RGB:1,0,0> Missing required part </RGB>")
        end
    end

    -- BASIC TOOLS
    if toolsOK then
        table.insert(t, "<RGB:0,1,0> Required tools OK </RGB>")
    else
        table.insert(t, "<RGB:1,0,0> Missing required tools </RGB>")
    end

    -- BASIC MECHANICAL SKILL
    if skillOK then
        table.insert(t, "<RGB:0,1,0> Maintenance 7 OK </RGB>")
    else
        table.insert(t, "<RGB:1,0,0> Requires Maintenance 7 </RGB>")
    end

    -- add a blank line at the bottom for padding
    table.insert(t, "")

    return table.concat(t, "\n")
end


-------------------------------------------------------------------
-- REPAIR TOOLTIP (from shared RepairRequirements)
-------------------------------------------------------------------
local function buildRepairTooltip(partID, structType, index)
    local defs = TikitownPower.RepairRequirements or {}
    local def  = defs[partID]

    if not def then
        return "Repair Requirements:\n\nNo repair data for " .. tostring(partID)
    end

    local player = getSpecificPlayer(0)
    if not player then
        return "Repair Requirements:\n\nNo player found"
    end

    local inv = player:getInventory()
    if not inv then
        return "Repair Requirements:\n\nNo inventory found"
    end

    local lines = {}

    table.insert(lines, "Repair Requirements:\n")

    -----------------------------------------------------
    -- ITEMS
    -----------------------------------------------------
    table.insert(lines, "Items:")

    local items = def.items or {}
    for _, req in ipairs(items) do
        local itemType = req.type
        local label    = getLocalizedItemLabel(req)
        local count    = req.count or 1

        local have = 0
        if itemType then
            have = inv:getCountType(itemType)
        end

        local ok    = (have >= count)
        local color = ok and "<RGB:0,1,0>" or "<RGB:1,0,0>"

        table.insert(lines,
            string.format(
                "%s - %s x%d (Have %d) </RGB>",
                color, label, count, have
            )
        )
    end

    -----------------------------------------------------
    -- TOOLS
    -----------------------------------------------------
    table.insert(lines, "\nTools:")

    local tools = def.tools or {}
    for _, tool in ipairs(tools) do
        local toolType = tool and tool.type or nil
        local label    =  getItemNameFromFullType(toolType)

        local item = nil
        if toolType then
            item = inv:FindAndReturn(toolType)
        end

        if not item then
            local handledByTag = false

            if toolType == "Base.Screwdriver" then
                handledByTag = true
                local hasAny = inv:containsTag("Screwdriver")
                if hasAny then
                    table.insert(lines, "<RGB:0,1,0>- Screwdriver </RGB>")
                else
                    table.insert(lines, "<RGB:1,0,0>- Screwdriver required </RGB>")
                end

            elseif toolType == "Base.Wrench" then
                handledByTag = true
                local hasAny = inv:containsTag("Wrench")
                if hasAny then
                    table.insert(lines, "<RGB:0,1,0>- Wrench </RGB>")
                else
                    table.insert(lines, "<RGB:1,0,0>- Wrench required </RGB>")
                end
            end

            if not handledByTag then
                table.insert(lines,
                    string.format("<RGB:1,0,0>- %s </RGB>", label)
                )
            end

        elseif tool.uses and tool.uses > 0 then
            -- drainable / blowtorch style tool
            local needed   = tool.uses or 1
            local usesLeft = 0

            if item.getCurrentUses then
                usesLeft = item:getCurrentUses() or 0
            else
                -- fallback using delta if needed
                local delta   = item.getDelta and (item:getDelta() or 0) or 0
                local perUse  = item.getUseDelta and (item:getUseDelta() or 0) or 0
                if perUse > 0 then
                    usesLeft = math.floor(delta / perUse + 0.0001)
                end
            end

            local ok = (usesLeft >= needed and usesLeft > 0)
            local color = ok and "<RGB:0,1,0>" or "<RGB:1,0,0>"

            table.insert(lines,
                string.format(
                    "%s - %s (%d/%d) </RGB>",
                    color, label, needed, usesLeft
                )
            )

        else
            -- standard non-drainable tool
            table.insert(lines,
                string.format("<RGB:0,1,0> - %s </RGB>", label)
            )
        end
    end

    -----------------------------------------------------
    -- SKILLS
    -----------------------------------------------------
    table.insert(lines, "\nSkills:")

	local reqSkills = def.skills or def.perks or {}
	for perkName, needed in pairs(reqSkills) do
		local perkId = perkName

		-- map friendly names to real perk IDs
		if perkName == "Welding" then
			perkId = "MetalWelding"
		elseif perkName == "Electrical" then
			perkId = "Electricity"
		end

		local perk = Perks[perkId]
		local have = 0
		local displayName = perkName

		if perk then
			have         = player:getPerkLevel(perk)
			displayName  = perk:getName() or perkName   -- localized name
		end

		local ok    = (have >= needed)
		local color = ok and "<RGB:0,1,0>" or "<RGB:1,0,0>"

		table.insert(lines,
			string.format(
				"%s - %s %d </RGB>",
				color, displayName, needed
			)
		)
	end

	----------------------------------------------------------------
    -- REPAIR HISTORY (removable parts only)
    ----------------------------------------------------------------
    if structType and index then
        local meta = STRUCT_META[structType] or STRUCT_META.Other

        -- same key scheme as the server:
        -- rcKey = structType .. ":" .. (keyPrefix..index) .. ":" .. partID
        local structKey = (meta.keyPrefix or structType) .. tostring(index)

        local data       = TikitownPower.getData()
        local rcTable    = data.repairCounts or {}
        local rcKey      = structType .. ":" .. structKey .. ":" .. partID
        local repairCount = rcTable[rcKey] or 0

        if repairCount > 0 then
            table.insert(lines, "")

            local color = "1,1,1"          -- white
            if repairCount >= 3 then
                color = "1,0.8,0.3"       -- amber
            end
            if repairCount >= 5 then
                color = "1,0.3,0.3"       -- red
            end

            table.insert(
                lines,
                string.format("Repaired: <RGB:%s>  %dX </RGB>", color, repairCount)
            )
        end
    end

	
    -- small bottom padding so text isn't hard up against the border
    table.insert(lines, "")

    return table.concat(lines, "\n")
end

-------------------------------------------------------------------
-- SIMPLE HELPERS
-------------------------------------------------------------------
local function playerHasTag(player, tag)
    local inv = player:getInventory()
    local items = inv:getItems()
    for i = 0, items:size()-1 do
        local it = items:get(i)
        if it:hasTag(tag) then
            return true
        end
    end
    return false
end

local function basicToolsOK(player)
    return playerHasTag(player, "Screwdriver") and playerHasTag(player, "Wrench")
end

local function basicMechOK(player)
    return player:getPerkLevel(Perks.Maintenance) >= 7
end

-------------------------------------------------------------------
-- PANEL INITIALISE
-------------------------------------------------------------------
function TikitownPower_StructUI:initialise()
    ISPanel.initialise(self)

    local prettyType = self.structType or "Structure"
    self.titleText = string.format("%s Status Report - %s %s",
        prettyType,
        prettyType,
        tostring(self.index or "?")
    )

    self.list = ISScrollingListBox:new(10, 50, self.width - 20, self.height - 90)
    self.list:initialise()
    self.list:instantiate()
    self.list:setFont(UIFont.Small, 2)
    self.list.itemheight = 25
    self:addChild(self.list)

    self.closeBtn = ISButton:new(self.width/2 - 40, self.height - 35, 80, 25,
        "Close", self, function() self:close() end)
    self.closeBtn:initialise()
    self:addChild(self.closeBtn)

    self.partButtons = {}
end

-------------------------------------------------------------------
-- DRAW HEADER
-------------------------------------------------------------------
function TikitownPower_StructUI:render()
    ISPanel.render(self)
    self:drawRect(0, 0, self.width, 30, 0.7, 0.1, 0.1, 0.1)
    self:drawTextCentre(self.titleText, self.width/2, 8, 1,1,1,1, UIFont.Medium)
end

-------------------------------------------------------------------
-- POPULATE UI FROM MOD DATA
-------------------------------------------------------------------
function TikitownPower_StructUI:populate()
    local meta = STRUCT_META[self.structType] or STRUCT_META.Other

    local data     = TikitownPower.getData()
    local store    = data[meta.dataField] or {}
    local key      = meta.keyPrefix .. tostring(self.index)
    local partData = store[key] or {}

    local partDefs = TikitownPower[meta.partDefsKey] or {}

    local player    = getSpecificPlayer(0)
    local inv       = player:getInventory()
    local hasTools  = basicToolsOK(player)
    local hasMech   = basicMechOK(player)
    local canRepair = hasUnlockedRepairs(player, self.structType)

    self.list:clear()
    for _, btn in ipairs(self.partButtons) do
        self:removeChild(btn)
    end
    self.partButtons = {}

    local y = 0
    for id, def in pairs(partDefs) do
        local val     = partData[id]
        local missing = (val == nil)

        local label = missing
            and string.format("%s (MISSING)", def.label)
            or string.format("%s (%d%%)", def.label, val)

        self.list:addItem(label, {
            id      = id,
            label   = def.label,
            value   = val or 0,
            missing = missing
        })

        local rowY  = 50 + y
        local baseX = self.list:getRight() - 150

        -- For tooltip text when locked
        local manualType = MANUAL_BY_STRUCT[self.structType]
		--print(self.structType)
        local manualName = manualType and getItemNameFromFullType(manualType) or "technical manual"
        local lockedTooltip = "Repairs locked.\nRead " .. tostring(manualName) .. " first."

        ------------------------------------------------------------
        -- INSTALL (if part missing) – gated by manual
        ------------------------------------------------------------
        if missing then
            local button = ISButton:new(baseX + 40, rowY, 80, 20,
                "Install", self,
                function() self:onInstallPart({ id=id, label=def.label }) end)

            button:initialise()
            self:addChild(button)
            table.insert(self.partButtons, button)

            if canRepair then
                -- Required part item
                local partType = def.installItem or ("TikitownPower." .. id)
                local hasPart  = inv:FindAndReturn(partType) ~= nil

                local enabled  = (hasPart and hasTools and hasMech)
                button:setEnable(enabled)

                button:setTooltip(
                    buildSimpleTooltip(true, hasPart, hasTools, hasMech)
                )
            else
                button:setEnable(false)
                button:setTooltip(lockedTooltip)
            end

        ------------------------------------------------------------
        -- REPAIR + REMOVE (if installed) – both gated by manual
        ------------------------------------------------------------
        else
            -- REPAIR
            if val < 100 then
                local repair = ISButton:new(baseX, rowY, 65, 20,
                    "Repair", self,
                    function() self:onRepairPart({ id=id, label=def.label }) end)

                repair:initialise()
                self:addChild(repair)
                table.insert(self.partButtons, repair)

                if canRepair then
                    repair:setEnable(true)
                    repair:setTooltip(
                        buildRepairTooltip(id, self.structType, self.index)
                    )
                else
                    repair:setEnable(false)
                    repair:setTooltip(lockedTooltip)
                end
            end

            -- REMOVE
            if def.removable then
                local remove = ISButton:new(baseX + 80, rowY, 65, 20,
                    "Remove", self,
                    function() self:onRemovePart({ id=id, label=def.label }) end)

                remove:initialise()
                self:addChild(remove)
                table.insert(self.partButtons, remove)

                if canRepair then
                    local enabled = (hasTools and hasMech)
                    remove:setEnable(enabled)

                    remove:setTooltip(
                        buildSimpleTooltip(false, true, hasTools, hasMech)
                    )
                else
                    remove:setEnable(false)
                    remove:setTooltip(lockedTooltip)
                end
            end
        end

        y = y + self.list.itemheight
    end
end


-------------------------------------------------------------------
-- BUTTON CALLBACKS (Timed Actions)
-------------------------------------------------------------------
function TikitownPower_StructUI:onRepairPart(item)
    local player = getSpecificPlayer(0)
    if not player then return end

    ISTimedActionQueue.add(
        TikitownPower_RepairPartAction:new(
            player,
            item.id,        -- partID
            item.label,     -- partLabel
            self.index,     -- Turbine1 / Furnace2 / Pump3 etc
            self.structType, -- "Turbine", "Condenser", "Furnace", "Pump"
            200             -- action time
        )
    )
end




function TikitownPower_StructUI:onRemovePart(item)
    local player = getSpecificPlayer(0)
    if not player then return end

    ISTimedActionQueue.add(
        TikitownPower_RemovePartAction:new(
            player,
            item.id,        -- partID
            item.label,     -- partLabel
            self.index,     -- index (Turbine1, Furnace2, etc.)
            self.structType, -- "Turbine", "Condenser", "Furnace", "Pump"
            100             -- time
        )
    )
end


function TikitownPower_StructUI:onInstallPart(item)
    local player = getSpecificPlayer(0)
    if not player then return end

    ISTimedActionQueue.add(
        TikitownPower_InstallPartAction:new(
            player,
            item.id,
            item.label,
            self.index,
            self.structType, -- "Turbine", "Condenser", "Furnace", "Pump"
            100              -- time
        )
    )
end


-------------------------------------------------------------------
-- CLOSE / OPEN
-------------------------------------------------------------------
function TikitownPower_StructUI:close()
    for _, btn in ipairs(self.partButtons) do
        btn:removeFromUIManager()
    end
    self.partButtons = {}

    self:setVisible(false)
    self:removeFromUIManager()
    TikitownPower_StructUI.instance = nil
end

function TikitownPower.openStructUI(structType, index)
    if TikitownPower_StructUI.instance then
        TikitownPower_StructUI.instance:close()
    end

    local ui = TikitownPower_StructUI:new(200, 200, 360, 400, structType, index)
    ui:initialise()
    ui:addToUIManager()
    ui:populate()
    TikitownPower_StructUI.instance = ui
end

function TikitownPower_StructUI:new(x, y, w, h, structType, index)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self

    o.structType = structType or "Turbine"
    o.index      = index or 1

    o.borderColor     = { r=0.4, g=0.4, b=0.4, a=1 }
    o.backgroundColor = { r=0,   g=0,   b=0,   a=0.8 }

    return o
end
