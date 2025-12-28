require "TimedActions/ISBaseTimedAction"

TikitownPower_InstallPartAction = ISBaseTimedAction:derive("TikitownPower_InstallPartAction")

----------------------------------------------------
-- VALID / START / UPDATE / STOP
----------------------------------------------------

function TikitownPower_InstallPartAction:isValid()
    -- All requirements (items, tools, skills) are checked in the UI tooltip.
    return true
end

function TikitownPower_InstallPartAction:start()
    ISBaseTimedAction.start(self)

    self:setActionAnim("Disassemble")

    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:getEmitter():stopSound(self.sound)
    end
    self.sound = self.character:getEmitter():playSound("Dismantle")

    if self.partLabel then
        self.character:Say("Installing " .. self.partLabel)
    end
end

function TikitownPower_InstallPartAction:update()
    self.character:setMetabolicTarget(Metabolics.HeavyDomestic)
end

function TikitownPower_InstallPartAction:stop()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:getEmitter():stopSound(self.sound)
    end
    ISBaseTimedAction.stop(self)
end

----------------------------------------------------
-- PERFORM
----------------------------------------------------

function TikitownPower_InstallPartAction:perform()
    print("[TikitownPower] InstallPartAction perform")

    sendClientCommand(self.character, "TikitownPower", "InstallPart", {
        part       = self.partID,
        index      = self.index,
        structType = self.structType or "Turbine",  -- safe default
        -- condition comes from the actual item on the server
    })

    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:getEmitter():stopSound(self.sound)
    end

    if TikitownPower_StructUI and TikitownPower_StructUI.instance then
        TikitownPower_StructUI.instance:close()
    elseif TikitownPower_TurbineUI and TikitownPower_TurbineUI.instance then
        TikitownPower_TurbineUI.instance:close()
    end

    ISBaseTimedAction.perform(self)
end


----------------------------------------------------
-- CONSTRUCTOR
----------------------------------------------------

function TikitownPower_InstallPartAction:new(character, partID, label, index, structType, time)
    local o = ISBaseTimedAction.new(self, character)
    o.stopOnWalk = true
    o.stopOnRun  = true
    o.maxTime    = time or 120

    o.partID     = partID
    o.partLabel  = label
    o.index      = index
    o.structType = structType  -- "Turbine", "Condenser", "Furnace", "Pump"
    o.condition  = nil         -- optional override; server defaults to 100/max if nil

    return o
end
