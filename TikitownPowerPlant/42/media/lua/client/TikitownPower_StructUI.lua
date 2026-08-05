require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISScrollingListBox"

--=================================================================
--  Generic Structure UI
--  Handles Turbine / Condenser / Furnace / Pump etc.
--=================================================================

TikitownPower_StructUI = ISPanel:derive("TikitownPower_StructUI")

-- Layout constants (pixels).  All geometry in initialise/onResize derives
-- from these so one change adjusts everything.
local HEADER_H = 30   -- title bar
local DETAIL_H = 70   -- action strip (label + buttons)
local FOOTER_H = 38   -- close button row

-------------------------------------------------------------------
-- DELAYED REFRESH SCHEDULER
-- Action files call TikitownPower_StructUI.scheduleRefresh() after
-- sendClientCommand().  The scheduler waits REFRESH_DELAY ticks
-- (giving the server time to process and update moddata) then calls
-- populate() on the open instance.
--
-- If OnReceiveGlobalModData fires first (server sent a broadcast),
-- that path calls populate() immediately and the tick handler
-- becomes a harmless no-op because the instance may already show
-- fresh data -- populate() is idempotent so a second call is safe.
-------------------------------------------------------------------
local REFRESH_DELAY = 45    -- ~1 second at 45 ticks/sec; raise for slow servers
local _refreshTicks = 0

local function _onRefreshTick()
    _refreshTicks = _refreshTicks - 1
    if _refreshTicks > 0 then return end

    Events.OnTickEvenPaused.Remove(_onRefreshTick)
    _refreshTicks = 0

    if TikitownPower_StructUI and TikitownPower_StructUI.instance then
        TikitownPower_StructUI.instance:populate()
    end
end

function TikitownPower_StructUI.scheduleRefresh(delayTicks)
    -- De-register first so repeated calls reset the countdown rather
    -- than stacking multiple handlers.
    Events.OnTickEvenPaused.Remove(_onRefreshTick)
    _refreshTicks = delayTicks or REFRESH_DELAY
    Events.OnTickEvenPaused.Add(_onRefreshTick)
end

-- Map structType -> where data and part defs live
local STRUCT_META = {
    Turbine = {
        dataField   = "turbines",
        keyPrefix   = "Turbine",
        partDefsKey = "TurbinePartDefs",
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
    Turbine   = "RepairTurbineRotor",
    Pump      = "RepairPumpSeals",
    Furnace   = "RepairFurnaceControlSystem",
    Condenser = "Cond_Store_Antifreeze",
}

local function hasUnlockedRepairs(player, structType)
    if not player then return false end
    local recipeName = REPAIR_RECIPE_BY_STRUCT[structType]
    if not recipeName then return true end
    return player:isRecipeKnown(recipeName)
end

--=================================================================
--  Translation Helper
--=================================================================
local function getLocalizedItemLabel(req)
    if req.label then return req.label end
    if req.type then
        local n = getItemNameFromFullType(req.type)
        if n and n ~= "" then return n end
    end
    return "Unknown item"
end

-------------------------------------------------------------------
-- SIMPLE TOOLTIP FOR INSTALL / REMOVE
-------------------------------------------------------------------
local function buildSimpleTooltip(needsPart, hasPart, toolsOK, skillOK)
    local t = {}

    if needsPart then
        if hasPart then
            table.insert(t, "<RGB:0,1,0> Required part found </RGB>")
        else
            table.insert(t, "<RGB:1,0,0> Missing required part </RGB>")
        end
    end

    if toolsOK then
        table.insert(t, "<RGB:0,1,0> Required tools OK </RGB>")
    else
        table.insert(t, "<RGB:1,0,0> Missing required tools </RGB>")
    end

    if skillOK then
        table.insert(t, "<RGB:0,1,0> Maintenance 7 OK </RGB>")
    else
        table.insert(t, "<RGB:1,0,0> Requires Maintenance 7 </RGB>")
    end

    table.insert(t, "")
    return table.concat(t, "\n")
end

-------------------------------------------------------------------
-- REPAIR TOOLTIP
-------------------------------------------------------------------
local function buildRepairTooltip(partID, structType, index)
    local defs = TikitownPower.RepairRequirements or {}
    local def  = defs[partID]

    if not def then
        return "Repair Requirements:\n\nNo repair data for " .. tostring(partID)
    end

    local player = getSpecificPlayer(0)
    if not player then return "Repair Requirements:\n\nNo player found" end

    local inv = player:getInventory()
    if not inv then return "Repair Requirements:\n\nNo inventory found" end

    local lines = {}
    table.insert(lines, "Repair Requirements:\n")

    -- ITEMS
    table.insert(lines, "Items:")
    local items = def.items or {}
    for _, req in ipairs(items) do
        local itemType = req.type
        local label    = getLocalizedItemLabel(req)
        local count    = req.count or 1
        local have     = itemType and inv:getCountType(itemType) or 0
        local ok       = (have >= count)
        local color    = ok and "<RGB:0,1,0>" or "<RGB:1,0,0>"
        table.insert(lines, string.format("%s - %s x%d (Have %d) </RGB>", color, label, count, have))
    end

    -- TOOLS
    table.insert(lines, "\nTools:")
    local tools = def.tools or {}
    for _, tool in ipairs(tools) do
        local toolType = tool and tool.type or nil
        local label    = getItemNameFromFullType(toolType)
        local item     = toolType and inv:FindAndReturn(toolType) or nil

        if not item then
            local handledByTag = false

            if toolType == "Base.Screwdriver" then
                handledByTag = true
                if inv:containsTag(ItemTag.SCREWDRIVER) then
                    table.insert(lines, "<RGB:0,1,0>- Screwdriver </RGB>")
                else
                    table.insert(lines, "<RGB:1,0,0>- Screwdriver required </RGB>")
                end
            elseif toolType == "Base.Wrench" then
                handledByTag = true
                if inv:containsTag(ItemTag.WRENCH) then
                    table.insert(lines, "<RGB:0,1,0>- Wrench </RGB>")
                else
                    table.insert(lines, "<RGB:1,0,0>- Wrench required </RGB>")
                end
            end

            if not handledByTag then
                table.insert(lines, string.format("<RGB:1,0,0>- %s </RGB>", label))
            end

        elseif tool.uses and tool.uses > 0 then
            local needed   = tool.uses or 1
            local usesLeft = 0

            if item.getCurrentUses then
                usesLeft = item:getCurrentUses() or 0
            else
                local delta  = item.getDelta and (item:getDelta() or 0) or 0
                local perUse = item.getUseDelta and (item:getUseDelta() or 0) or 0
                if perUse > 0 then usesLeft = math.floor(delta / perUse + 0.0001) end
            end

            local ok    = (usesLeft >= needed and usesLeft > 0)
            local color = ok and "<RGB:0,1,0>" or "<RGB:1,0,0>"
            table.insert(lines, string.format("%s - %s (%d/%d) </RGB>", color, label, needed, usesLeft))
        else
            table.insert(lines, string.format("<RGB:0,1,0> - %s </RGB>", label))
        end
    end

    -- SKILLS
    table.insert(lines, "\nSkills:")
    local reqSkills = def.skills or def.perks or {}
    for perkName, needed in pairs(reqSkills) do
        local perkId = perkName
        if perkName == "Welding"    then perkId = "MetalWelding" end
        if perkName == "Electrical" then perkId = "Electricity"  end

        local perk        = Perks[perkId]
        local have        = 0
        local displayName = perkName

        if perk then
            have        = player:getPerkLevel(perk)
            displayName = perk:getName() or perkName
        end

        local ok    = (have >= needed)
        local color = ok and "<RGB:0,1,0>" or "<RGB:1,0,0>"
        table.insert(lines, string.format("%s - %s %d </RGB>", color, displayName, needed))
    end

    -- REPAIR HISTORY
    if structType and index then
        local meta     = STRUCT_META[structType] or STRUCT_META.Other
        local structKey = (meta.keyPrefix or structType) .. tostring(index)
        local data      = TikitownPower.getData()
        local rcTable   = data.repairCounts or {}
        local rcKey     = structType .. ":" .. structKey .. ":" .. partID
        local repairCount = rcTable[rcKey] or 0

        if repairCount > 0 then
            table.insert(lines, "")
            local color = "1,1,1"
            if repairCount >= 3 then color = "1,0.8,0.3" end
            if repairCount >= 5 then color = "1,0.3,0.3" end
            table.insert(lines, string.format("Repaired: <RGB:%s>  %dX </RGB>", color, repairCount))
        end
    end

    table.insert(lines, "")
    return table.concat(lines, "\n")
end

-------------------------------------------------------------------
-- SIMPLE HELPERS
-------------------------------------------------------------------
local function playerHasTag(player, tag)
    return player:getInventory():containsTag(tag)
end

local function basicToolsOK(player)
    return playerHasTag(player, ItemTag.SCREWDRIVER) and playerHasTag(player, ItemTag.WRENCH)
end

local function basicMechOK(player)
    return player:getPerkLevel(Perks.Maintenance) >= 7
end

-------------------------------------------------------------------
-- INTERNAL LAYOUT HELPERS
-- Centralise all height arithmetic so onResize and initialise
-- can never drift out of sync.
-------------------------------------------------------------------

-- Height available for the scrolling list
local function _listH(self)
    return math.max(self.height - HEADER_H - 10 - DETAIL_H - FOOTER_H, 30)
end

-- Y coordinate at which the action strip begins
local function _stripTop(self)
    return HEADER_H + 5 + _listH(self) + 5
end

-------------------------------------------------------------------
-- PANEL CONSTRUCTOR
-------------------------------------------------------------------
function TikitownPower_StructUI:new(x, y, w, h, structType, index)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self

    o.structType      = structType or "Turbine"
    o.index           = index or 1
    o.moveWithMouse   = true
    o.resizable       = true
    o.minimumWidth    = 320
    o.minimumHeight   = 350
    o.borderColor     = { r=0.4, g=0.4, b=0.4, a=1 }
    o.backgroundColor = { r=0,   g=0,   b=0,   a=0.8 }

    return o
end

-------------------------------------------------------------------
-- PANEL INITIALISE
-------------------------------------------------------------------
function TikitownPower_StructUI:initialise()
    ISPanel.initialise(self)

    local prettyType = self.structType or "Structure"
    self.titleText = string.format("%s Status Report - %s %s",
        prettyType, prettyType, tostring(self.index or "?"))

    -- Scrolling list: fills the space between the header and the action strip
    self.list = ISScrollingListBox:new(10, HEADER_H + 5, self.width - 20, _listH(self))
    self.list:initialise()
    self.list:instantiate()
    self.list:setFont(UIFont.Small, 2)
    self.list.itemheight = 25
    self:addChild(self.list)

    -- Hook list clicks so the action strip refreshes when the selection changes.
    -- We wrap the original handler rather than replace it so ISScrollingListBox
    -- still updates self.selected before our code runs.
    local baseMouseDown = self.list.onMouseDown
    self.list.onMouseDown = function(listSelf, x, y)
        if baseMouseDown then baseMouseDown(listSelf, x, y) end
        self:updateDetailPanel()
    end

    -- Action strip buttons.  They live at fixed coordinates relative to the
    -- panel (not the list) so they are never affected by list scrolling.
    -- updateDetailPanel() shows/hides/enables them based on the selection.
    local stripTop = _stripTop(self)
    local btnY     = stripTop + 28

    self.repairBtn = ISButton:new(10, btnY, 90, 25, "Repair", self,
        function() self:doRepair() end)
    self.repairBtn:initialise()
    self.repairBtn:setVisible(false)
    self:addChild(self.repairBtn)

    self.installBtn = ISButton:new(110, btnY, 90, 25, "Install", self,
        function() self:doInstall() end)
    self.installBtn:initialise()
    self.installBtn:setVisible(false)
    self:addChild(self.installBtn)

    self.removeBtn = ISButton:new(210, btnY, 90, 25, "Remove", self,
        function() self:doRemove() end)
    self.removeBtn:initialise()
    self.removeBtn:setVisible(false)
    self:addChild(self.removeBtn)

    -- Close button
    self.closeBtn = ISButton:new(
        math.floor(self.width / 2) - 40,
        self.height - FOOTER_H + 6,
        80, 25, "Close", self, function() self:close() end)
    self.closeBtn:initialise()
    self:addChild(self.closeBtn)

    -- Kept for backward compatibility with any external code that reads it
    self.partButtons = {}
end

-------------------------------------------------------------------
-- RESIZE HANDLER
-- Re-positions every child whose coordinates depend on panel size.
-------------------------------------------------------------------
function TikitownPower_StructUI:onResize()
    ISPanel.onResize(self)

    if self.list then
        self.list:setWidth(self.width - 20)
        self.list:setHeight(_listH(self))
    end

    local stripTop = _stripTop(self)
    local btnY     = stripTop + 28

    if self.repairBtn  then self.repairBtn:setY(btnY)  end
    if self.installBtn then self.installBtn:setY(btnY) end
    if self.removeBtn  then self.removeBtn:setY(btnY)  end

    if self.closeBtn then
        self.closeBtn:setX(math.floor(self.width / 2) - 40)
        self.closeBtn:setY(self.height - FOOTER_H + 6)
    end
end

-------------------------------------------------------------------
-- MOUSE HANDLERS FOR RESIZE
-- ISPanel's moveWithMouse=true unconditionally starts a drag on any
-- onMouseDown, so we intercept clicks in the resize zone first and
-- handle them ourselves.  Clicks outside the zone fall through to
-- the normal ISPanel drag logic.
-------------------------------------------------------------------
local RESIZE_ZONE = 16   -- hotspot size in pixels (bottom-right corner)

function TikitownPower_StructUI:onMouseDown(x, y)
    if x >= self.width - RESIZE_ZONE and y >= self.height - RESIZE_ZONE then
        self.isResizing = true
        
        return
    end
    ISPanel.onMouseDown(self, x, y)
end

function TikitownPower_StructUI:onMouseMove(dx, dy)
    if self.isResizing then
        local newW = math.max(self.minimumWidth  or 100, self.width  + dx)
        local newH = math.max(self.minimumHeight or 100, self.height + dy)
        self:setWidth(newW)
        self:setHeight(newH)
        self:onResize()
        return
    end
    ISPanel.onMouseMove(self, dx, dy)
end

function TikitownPower_StructUI:onMouseMoveOutside(dx, dy)
    if self.isResizing then
        local newW = math.max(self.minimumWidth  or 100, self.width  + dx)
        local newH = math.max(self.minimumHeight or 100, self.height + dy)
        self:setWidth(newW)
        self:setHeight(newH)
        self:onResize()
        return
    end
    ISPanel.onMouseMoveOutside(self, dx, dy)
end

function TikitownPower_StructUI:onMouseUp(x, y)
    self.isResizing = false
    ISPanel.onMouseUp(self, x, y)
end

-------------------------------------------------------------------
-- DRAW HEADER + ACTION STRIP CHROME
-------------------------------------------------------------------
function TikitownPower_StructUI:render()
    ISPanel.render(self)

    -- Title bar
    self:drawRect(0, 0, self.width, HEADER_H, 0.7, 0.1, 0.1, 0.1)
    self:drawTextCentre(self.titleText, self.width / 2, 8, 1, 1, 1, 1, UIFont.Medium)

    -- Divider above action strip
    local stripTop = _stripTop(self)
    self:drawRect(0, stripTop - 2, self.width, 1, 0.8, 0.4, 0.4, 0.4)

    -- Selected-part label / prompt
    local sel  = self.list and self.list.selected
    local item = sel and self.list.items and self.list.items[sel] and self.list.items[sel].item

    if item then
        self:drawText(item.label, 15, stripTop + 6, 1, 1, 1, 1, UIFont.Small)
    else
        self:drawText("Select a part to view actions", 15, stripTop + 6, 0.55, 0.55, 0.55, 1, UIFont.Small)
    end

    -- Resize grip: three dots along a diagonal in the bottom-right corner.
    local gx = self.width  - 13
    local gy = self.height - 13
    local gc = 0.60   -- brightness; bump toward 1.0 if hard to see
    for i = 0, 2 do
        local o = i * 4
        self:drawRect(gx + o, gy + o, 3, 3, 0.85, gc, gc, gc)
    end
end

-------------------------------------------------------------------
-- POPULATE UI FROM MOD DATA
-- Only builds the list rows now.  Button placement is handled by
-- updateDetailPanel() and onResize() instead.
-------------------------------------------------------------------
function TikitownPower_StructUI:populate()
    local meta = STRUCT_META[self.structType] or STRUCT_META.Other

    -- Read directly from ModData rather than through TikitownPower.getData(),
    
    local data     = ModData.getOrCreate("TikitownPowerGrid")
    local store    = data[meta.dataField] or {}
    local key      = meta.keyPrefix .. tostring(self.index)
    local partData = store[key] or {}
    local partDefs = TikitownPower[meta.partDefsKey] or {}

    -- Remember which part was selected so can restore it after the
    -- list is rebuilt.
    local savedId
    local prevSel = self.list and self.list.selected
    if prevSel and self.list.items and self.list.items[prevSel] then
        local prevItem = self.list.items[prevSel].item
        savedId = prevItem and prevItem.id
    end

    self.list:clear()

    -- Safety: remove any leftover floating buttons from old code paths
    for _, btn in ipairs(self.partButtons) do
        self:removeChild(btn)
    end
    self.partButtons = {}

    for id, def in pairs(partDefs) do
        local val     = partData[id]
        local missing = (val == nil)

        local label = missing
            and string.format("%s (MISSING)", def.label)
            or  string.format("%s (%d%%)",    def.label, val)

        self.list:addItem(label, {
            id      = id,
            label   = def.label,
            value   = val or 0,
            missing = missing,
        })
    end

    -- Restore the previous selection by matching part id.
    if savedId then
        for i, row in ipairs(self.list.items) do
            if row.item and row.item.id == savedId then
                self.list.selected = i
                break
            end
        end
    end

    -- Refresh buttons to reflect the (possibly updated) values
    self:updateDetailPanel()
end

-------------------------------------------------------------------
-- ACTION STRIP REFRESH
-- Called whenever the list selection changes.  Shows, hides, and
-- enables the three action buttons to match the selected part.
-------------------------------------------------------------------
function TikitownPower_StructUI:updateDetailPanel()
    -- Always start hidden
    self.repairBtn:setVisible(false)
    self.installBtn:setVisible(false)
    self.removeBtn:setVisible(false)

    local sel  = self.list and self.list.selected
    local item = sel and self.list.items and self.list.items[sel] and self.list.items[sel].item
    if not item then return end

    local player = getSpecificPlayer(0)
    if not player then return end

    local inv       = player:getInventory()
    local hasTools  = basicToolsOK(player)
    local hasMech   = basicMechOK(player)
    local canRepair = hasUnlockedRepairs(player, self.structType)

    local meta     = STRUCT_META[self.structType] or STRUCT_META.Other
    local partDefs = TikitownPower[meta.partDefsKey] or {}
    local def      = partDefs[item.id]

    local manualType    = MANUAL_BY_STRUCT[self.structType]
    local manualName    = manualType and getItemNameFromFullType(manualType) or "technical manual"
    local lockedTooltip = "Repairs locked.\nRead " .. tostring(manualName) .. " first."

    if item.missing then
        -- INSTALL
        self.installBtn:setVisible(true)
        if canRepair then
            local partType = def and def.installItem or ("TikitownPower." .. item.id)
            local hasPart  = inv:FindAndReturn(partType) ~= nil
            self.installBtn:setEnable(hasPart and hasTools and hasMech)
            self.installBtn:setTooltip(buildSimpleTooltip(true, hasPart, hasTools, hasMech))
        else
            self.installBtn:setEnable(false)
            self.installBtn:setTooltip(lockedTooltip)
        end

    else
        -- REPAIR (only shown when part is degraded)
        if item.value < 100 then
            self.repairBtn:setVisible(true)
            if canRepair then
                self.repairBtn:setEnable(true)
                self.repairBtn:setTooltip(buildRepairTooltip(item.id, self.structType, self.index))
            else
                self.repairBtn:setEnable(false)
                self.repairBtn:setTooltip(lockedTooltip)
            end
        end

        -- REMOVE (only on removable parts)
        if def and def.removable then
            self.removeBtn:setVisible(true)
            if canRepair then
                self.removeBtn:setEnable(hasTools and hasMech)
                self.removeBtn:setTooltip(buildSimpleTooltip(false, true, hasTools, hasMech))
            else
                self.removeBtn:setEnable(false)
                self.removeBtn:setTooltip(lockedTooltip)
            end
        end
    end
end

-------------------------------------------------------------------
-- ACTION STRIP DISPATCH
-- Thin wrappers that read the current selection and hand off to
-- the existing timed-action callbacks below.
-------------------------------------------------------------------
function TikitownPower_StructUI:doRepair()
    local sel  = self.list and self.list.selected
    local item = sel and self.list.items and self.list.items[sel] and self.list.items[sel].item
    if item then self:onRepairPart(item) end
end

function TikitownPower_StructUI:doInstall()
    local sel  = self.list and self.list.selected
    local item = sel and self.list.items and self.list.items[sel] and self.list.items[sel].item
    if item then self:onInstallPart(item) end
end

function TikitownPower_StructUI:doRemove()
    local sel  = self.list and self.list.selected
    local item = sel and self.list.items and self.list.items[sel] and self.list.items[sel].item
    if item then self:onRemovePart(item) end
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
            item.id,
            item.label,
            self.index,
            self.structType,
            200
        )
    )
end

function TikitownPower_StructUI:onRemovePart(item)
    local player = getSpecificPlayer(0)
    if not player then return end

    ISTimedActionQueue.add(
        TikitownPower_RemovePartAction:new(
            player,
            item.id,
            item.label,
            self.index,
            self.structType,
            100
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
            self.structType,
            100
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

    local W = 360
    local H = 460
    local x = math.floor((getCore():getScreenWidth()  - W) / 2)
    local y = math.floor((getCore():getScreenHeight() - H) / 2)

    local ui = TikitownPower_StructUI:new(x, y, W, H, structType, index)
    ui:initialise()
    ui:addToUIManager()
    ui:populate()
    TikitownPower_StructUI.instance = ui
end