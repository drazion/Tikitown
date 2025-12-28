require "ISUI/ISPanel"
require "ISUI/ISButton"

TikitownPower = TikitownPower or {}

TikitownPowerPowerUI = ISPanel:derive("TikitownPowerPowerUI")
local PUI = TikitownPowerPowerUI


function PUI:new(x, y, w, h)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.moveWithMouse = true
    o.backgroundColor = {r=0, g=0, b=0, a=0.85}
    return o
end


function PUI:initialise()
    ISPanel.initialise(self)

    self.closeButton = ISButton:new(self.width-22, 2, 20, 20, "X", self, PUI.close)
    self:addChild(self.closeButton)

    -- Grid status text label (updated on refresh)
    self.statusLabelY = 50

    -- Button to toggle grid power
    self.toggleButton = ISButton:new(50, 100, self.width-100, 40, "Loading...", self, PUI.onToggle)
    self.toggleButton:initialise()
    self:addChild(self.toggleButton)

    self:refreshStatus()
end


function PUI:refreshStatus()
    local today = math.floor(getGameTime():getWorldAgeHours() / 24)
    local shutDay = tonumber(SandboxVars["ElecShutModifier"]) or 0

    self.isGridOn = (shutDay > today)

    if self.isGridOn then
        self.toggleButton:setTitle("Shut Down Grid")
    else
        self.toggleButton:setTitle("Restore Grid")
    end
end


function PUI:onToggle()
    local player = getSpecificPlayer(0)
    if not player then return end

    local today   = math.floor(getGameTime():getWorldAgeHours() / 24)
    local powerOn = (SandboxVars["ElecShutModifier"] > getGameTime():getWorldAgeHours() / 24)

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


	--self.sound = player:getEmitter():playSound("TikitownPower_GridOn")

    self:close()
end





function PUI:render()
    ISPanel.render(self)

    local status = self.isGridOn and "ON" or "OFF"
    local r, g = self.isGridOn and 0.1 or 0.9, self.isGridOn and 0.9 or 0.1

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
    local x = (getCore():getScreenWidth() - W) / 2
    local y = (getCore():getScreenHeight() - H) / 2

    local panel = PUI:new(x, y, W, H)
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(true)
    TikitownPowerPowerUI.instance = panel
end

