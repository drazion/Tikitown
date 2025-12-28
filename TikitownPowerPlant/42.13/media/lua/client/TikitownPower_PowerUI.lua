require "ISUI/ISPanel"
require "ISUI/ISButton"

TikitownPower = TikitownPower or {}

TikitownPowerPowerUI = ISPanel:derive("TikitownPowerPowerUI")
local PUI = TikitownPowerPowerUI

-------------------------------------------------
-- Small helpers that wrap existing state
-------------------------------------------------

local function getProgressedDays()
    if TikitownPower.progressedDays and type(TikitownPower.progressedDays) == "number" then
        return TikitownPower.progressedDays
    end
    return math.floor((getGameTime():getWorldAgeHours() / 24) + 0.01)
end

local function getElecShutDay()
    return tonumber(SandboxVars and SandboxVars.ElecShutModifier or SandboxVars["ElecShutModifier"]) or 0
end

local function getModData()
    -- setupModData seeds TikitownPower.modData on both SP and MP
    if TikitownPower.modData then
        return TikitownPower.modData
    end
    -- Fallback if ever call getData clientside
    if TikitownPower.getData then
        return TikitownPower.getData()
    end
    return {}
end

local function isPlantActivated()
    local data = getModData()
    return data.plantActivated == true
end

-------------------------------------------------
-- UI
-------------------------------------------------

function PUI:new(x, y, w, h)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.moveWithMouse = true
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

function PUI:refreshStatus()
    local progressedDays = getProgressedDays()
    local elecShutDay    = getElecShutDay()
    local plantActive    = isPlantActivated()

    -- What vanilla/global says about the grid right now
    local gridOnBySandbox = (elecShutDay == -1) or (progressedDays < elecShutDay)
	print(gridOnBySandbox)

    self.toggleLocked = false
    self.toggleButton:setEnable(true)

    -- Before the plant has ever been activated, if the global power is still on,
    -- do not let the player use this UI to flip anything.
    if (not plantActive) and (progressedDays < elecShutDay) then
        self.isGridOn     = true       -- effectively on from Louisville/global
        self.toggleLocked = true
        self.toggleButton:setEnable(false)
        self.toggleButton:setTitle(" Louisville Power Plant is providing global power ")
    else
        -- Normal behavior once plant has been activated or after shutoff day
        self.isGridOn = gridOnBySandbox

        if self.isGridOn then
            self.toggleButton:setTitle("Shut Down Grid")
        else
            self.toggleButton:setTitle("Restore Grid")
        end
    end
end

function PUI:onToggle()
    local player = getSpecificPlayer(0)
    if not player then return end

    -- Respect the lock check
    if self.toggleLocked then
        player:Say("The global grid is still active. Plant controls are offline.")
        return
    end

    local progressedDays = getProgressedDays()
    local elecShutDay    = getElecShutDay()
    local powerOn        = (elecShutDay == -1) or (progressedDays < elecShutDay)

    if self.isGridOn then
        player:Say("Grid shutdown engaged.")
    else
        player:Say("Grid restored temporarily.")
    end

    if powerOn then
        sendClientCommand(player, "TikitownPower", "ForceShutdown", {})
    else
        sendClientCommand(player, "TikitownPower", "ForceRestore", {})
    end

    self:close()
end

function PUI:render()
    ISPanel.render(self)

    local status = self.isGridOn and "ON" or "OFF"
    local r, g   = self.isGridOn and 0.1 or 0.9, self.isGridOn and 0.9 or 0.1

    self:drawText("Power Grid Status: " .. status, 50, self.statusLabelY, r, g, 0.1, 1, UIFont.Large)
end

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
    local x    = (getCore():getScreenWidth() - W) / 2
    local y    = (getCore():getScreenHeight() - H) / 2

    local panel = PUI:new(x, y, W, H)
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(true)
    TikitownPowerPowerUI.instance = panel
end
