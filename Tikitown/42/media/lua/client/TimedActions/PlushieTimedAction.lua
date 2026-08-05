ISOpenPlushCan = ISBaseTimedAction:derive("ISOpenPlushCan")

function ISOpenPlushCan:isValid()
    return self.character
        and self.item
        and self.character:getInventory():contains(self.item)
end

function ISOpenPlushCan:start()
    self.item:setJobType(getText("ContextMenu_OpenPlushCan"))
    self.item:setJobDelta(0.0)

    self:setActionAnim("Loot")
    self:setOverrideHandModels(self.item, nil)

    -- Fire a one–shot world sound from the player square
    local square = self.character:getCurrentSquare()
    if square then
        square:playSound("OpenCannedFood")
    end
end

function ISOpenPlushCan:update()
    self.item:setJobDelta(self:getJobDelta())
end

function ISOpenPlushCan:stop()
    -- No need to stop the sound; it is a short one–shot
    self.item:setJobDelta(0.0)
    ISBaseTimedAction.stop(self)
end

function ISOpenPlushCan:perform()
    self.item:setJobDelta(0.0)

    local inv = self.character:getInventory()

    -- remove the can
    inv:Remove(self.item)

    -- pick a random plush from the pool
    local pool = PocketPaws_PlushCan.RewardItems
    if #pool > 0 then
        local index = ZombRand(#pool) + 1      -- 1..#pool
        local rewardType = pool[index]
        inv:AddItem(rewardType)
    end

    -- give an empty can if you want
    inv:AddItem("Base.TinCanEmpty")

    ISBaseTimedAction.perform(self)
end

function ISOpenPlushCan:new(character, item, time)
    local o = ISBaseTimedAction:new(character)
    setmetatable(o, self)
    self.__index = self

    o.character = character
    o.item = item
    o.stopOnWalk = true
    o.stopOnRun  = true
    o.maxTime    = time or 60

    return o
end
