require "TimedActions/ISBaseTimedAction"

TikitownPower_RemovePartAction = ISBaseTimedAction:derive("TikitownPower_RemovePartAction")

----------------------------------------------------
-- VALID / START / UPDATE / STOP
----------------------------------------------------

function TikitownPower_RemovePartAction:isValid()
    -- Requirements are already checked in the UI / tooltip layer.
    return true
end

function TikitownPower_RemovePartAction:start()
    ISBaseTimedAction.start(self)

    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:getEmitter():stopSound(self.sound)
    end
    self.sound = self.character:getEmitter():playSound("Dismantle")

    self:setActionAnim("Disassemble")

    if self.partLabel then
        self.character:Say("Removing " .. self.partLabel)
    end
end

function TikitownPower_RemovePartAction:update()
    self.character:setMetabolicTarget(Metabolics.HeavyDomestic)
end

function TikitownPower_RemovePartAction:stop()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:getEmitter():stopSound(self.sound)
    end
    ISBaseTimedAction.stop(self)
end

----------------------------------------------------
-- PERFORM
----------------------------------------------------

function TikitownPower_RemovePartAction:perform()
    print("[TikitownPower] RemovePartAction perform")

    sendClientCommand(self.character, "TikitownPower", "RemovePart", {
        part       = self.partID,
        index      = self.index,
        structType = self.structType or "Turbine",
    })

    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:getEmitter():stopSound(self.sound)
    end

    -- Close whichever struct UI is open so it can be reopened with fresh data
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

function TikitownPower_RemovePartAction:new(character, partID, partLabel, index, structType, time)
    local o = ISBaseTimedAction.new(self, character)
    o.stopOnWalk = true
    o.stopOnRun  = true
    o.maxTime    = time or 120

    o.partID     = partID
    o.partLabel  = partLabel
    o.index      = index
    o.structType = structType  -- "Turbine", "Condenser", "Furnace", "Pump", etc.

    return o
end
