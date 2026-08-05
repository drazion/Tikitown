require "ISUI/ISPanel"
require "ISUI/ISButton"

TikitownPower = TikitownPower or {}

TikitownPowerPowerUI = ISPanel:derive("TikitownPowerPowerUI")
local PUI = TikitownPowerPowerUI

local RESIZE_ZONE = 16   -- pixel hotspot in bottom-right corner for resize

-------------------------------------------------
-- Small helpers that wrap existing state

local function isStaff(player)
    if not player or not player.getAccessLevel then return false end
    local lvl = tostring(player:getAccessLevel() or ""):lower()
    return (lvl == "admin" or lvl == "moderator" or lvl == "overseer" or lvl == "gm")
end

local function isAdminOrDebug(player)
    if isClient() or isServer() then
        return isStaff(player)
    end
    if isDebugEnabled and isDebugEnabled() then return true end
    return isStaff(player)
end

-------------------------------------------------

local function getProgressedDays()
    if TikitownPower.progressedDays and type(TikitownPower.progressedDays) == "number" then
        return TikitownPower.progressedDays
    end
    return math.floor((getGameTime():getWorldAgeHours() / 24) + 0.01)
end

local function getElecShutDay()
    -- SandboxVars.ElecShutModifier is the primary source, but it may lag
    -- if changed by external admin tools that only update the Java option
    -- without writing back to the Lua table.  modData.shutdownDay is
    -- explicitly maintained by our ForceShutdown / ForceRestore commands.
    -- Taking the larger of the two avoids false "power off" readings when
    -- either source is stale.
    local sandboxDay = tonumber(SandboxVars and SandboxVars.ElecShutModifier) or 0
    local md         = ModData.getOrCreate("TikitownPowerGrid")
    local storedDay  = tonumber(md and md.shutdownDay) or 0
    return math.max(sandboxDay, storedDay)
end

local function getModData()
    -- Read directly from ModData rather than TikitownPower.modData, which is
    -- a reference cached at init time and may lag behind changes made during
    -- the current session (same issue fixed in StructUI's populate()).
    return ModData.getOrCreate("TikitownPowerGrid")
end

local function isPlantRunning()
    return getModData().plantRunning == true
end

local function isPlantActivated()
    return getModData().plantActivated == true
end

-------------------------------------------------
-- UI
-------------------------------------------------

function PUI:new(x, y, w, h)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.moveWithMouse   = true
    o.resizable       = true
    o.minimumWidth    = 300
    o.minimumHeight   = 160
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.85 }
    return o
end

function PUI:initialise()
    ISPanel.initialise(self)

    self.closeButton = ISButton:new(self.width - 22, 2, 20, 20, "X", self, PUI.close)
    self:addChild(self.closeButton)

    self.statusLabelY = 50

    self.toggleButton = ISButton:new(50, 100, self.width - 100, 40, "Loading...", self, PUI.onToggle)
    self.toggleButton:initialise()
    self:addChild(self.toggleButton)

    self.toggleLocked = false

    self:refreshStatus()
end

-------------------------------------------------
-- RESIZE HANDLERS
-- Same pattern as StructUI: intercept onMouseDown in the resize zone
-- so moveWithMouse does not steal the event.
-------------------------------------------------

function PUI:onResize()
    ISPanel.onResize(self)

    if self.toggleButton then
        self.toggleButton:setWidth(self.width - 100)
    end
    if self.closeButton then
        self.closeButton:setX(self.width - 22)
    end
end

function PUI:onMouseDown(x, y)
    if x >= self.width - RESIZE_ZONE and y >= self.height - RESIZE_ZONE then
        self.isResizing = true
        return
    end
    ISPanel.onMouseDown(self, x, y)
end

function PUI:onMouseMove(dx, dy)
    if self.isResizing then
        self:setWidth( math.max(self.minimumWidth,  self.width  + dx))
        self:setHeight(math.max(self.minimumHeight, self.height + dy))
        self:onResize()
        return
    end
    ISPanel.onMouseMove(self, dx, dy)
end

function PUI:onMouseMoveOutside(dx, dy)
    if self.isResizing then
        self:setWidth( math.max(self.minimumWidth,  self.width  + dx))
        self:setHeight(math.max(self.minimumHeight, self.height + dy))
        self:onResize()
        return
    end
    ISPanel.onMouseMoveOutside(self, dx, dy)
end

function PUI:onMouseUp(x, y)
    self.isResizing = false
    ISPanel.onMouseUp(self, x, y)
end

-------------------------------------------------
-- STATUS LOGIC
-------------------------------------------------

function PUI:refreshStatus()
    local progressedDays = getProgressedDays() + 1
    local elecShutDay    = getElecShutDay()
    local plantActive    = isPlantActivated()
    local vanillaGridOn  = (progressedDays < elecShutDay)

    if self.repairAllButton then
        self.repairAllButton:setVisible(isAdminOrDebug(getSpecificPlayer(0)))
    end

    self.toggleLocked = false
    self.toggleButton:setEnable(true)

    -- If the plant has never been activated AND the vanilla Louisville grid
    -- is still scheduled to be running, lock out the controls entirely.
    if (not plantActive) and vanillaGridOn then
        self.isGridOn     = true
        self.toggleLocked = true
        self.toggleButton:setEnable(false)
        self.toggleButton:setTitle(" Global Power is Active ")
        return
    end

    -- Power is on if EITHER the plant is running OR the vanilla grid is active
    -- (e.g. an admin pushed ElecShutModifier into the future directly without
    -- going through ForceRestore, so plantRunning may still be false).
    self.isGridOn = isPlantRunning() or vanillaGridOn

    if self.isGridOn then
        self.toggleButton:setTitle("Shut Down Grid")
    else
        self.toggleButton:setTitle("Restore Grid")
    end
end

-------------------------------------------------
-- TOGGLE
-------------------------------------------------

function PUI:onToggle()
    local player = getSpecificPlayer(0)
    if not player then return end

    if self.toggleLocked then
        player:Say("The global grid is still active. Plant controls are offline.")
        return
    end

    -- Use self.isGridOn (set from isPlantRunning) rather than recomputing
    -- from ElecShutModifier, which may have been pushed far into the future
    -- by ForceRestore and would give the wrong command.
    if self.isGridOn then
        player:Say("Grid shutdown engaged.")
        sendClientCommand(player, "TikitownPower", "ForceShutdown", {})
    else
        player:Say("Grid restored temporarily.")
        sendClientCommand(player, "TikitownPower", "ForceRestore", {})
    end

    self:close()
end

function PUI:onRepairAllParts()
    local player = getSpecificPlayer(0)
    if not player then return end

    if not isAdminOrDebug(player) then
        player:Say("Admin/debug only.")
        return
    end

    sendClientCommand(player, "TikitownPower", "RepairAllParts", {})
    self:refreshStatus()
end

-------------------------------------------------
-- RENDER
-------------------------------------------------

function PUI:render()
    ISPanel.render(self)

    local status = self.isGridOn and "ON" or "OFF"
    local r, g   = self.isGridOn and 0.1 or 0.9, self.isGridOn and 0.9 or 0.1

    self:drawText("Power Grid Status: " .. status, 50, self.statusLabelY, r, g, 0.1, 1, UIFont.Large)

    -- Resize grip
    local gx = self.width  - 13
    local gy = self.height - 13
    local gc = 0.60
    for i = 0, 2 do
        local o = i * 4
        self:drawRect(gx + o, gy + o, 3, 3, 0.85, gc, gc, gc)
    end
end

-------------------------------------------------
-- CLOSE / OPEN
-------------------------------------------------

function PUI:close()
    self:removeFromUIManager()
    TikitownPowerPowerUI.instance = nil
end

function TikitownPower.openPowerUI()
    if TikitownPowerPowerUI.instance then
        TikitownPowerPowerUI.instance:bringToTop()
        return
    end

    local W, H = 350, 200
    local x    = math.floor((getCore():getScreenWidth()  - W) / 2)
    local y    = math.floor((getCore():getScreenHeight() - H) / 2)

    local panel = PUI:new(x, y, W, H)
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(true)
    TikitownPowerPowerUI.instance = panel
end