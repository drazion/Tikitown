--=============================================================
-- TikitownPower_Tooltips.lua
-- Properly inject condition bar for TikitownPower.Rotor
--=============================================================

local function addRotorConditionHook()
    -- Make sure ISToolTipInv exists and has a render method
    if not ISToolTipInv or not ISToolTipInv.render then
        print("[TikitownPower] ISToolTipInv not ready.")
        return
    end

    -- Keep original render function
    local originalRender = ISToolTipInv.render

    function ISToolTipInv:render()
        -- Let vanilla (and other mods) draw first
        originalRender(self)

        -- Make sure we actually have an item
        local item = self.item
        if not item then
            return
        end

        -- Some tooltips use non-InventoryItem objects; ignore those
        if not instanceof(item, "InventoryItem") then
            return
        end

        -- Make sure the methods we need actually exist
        if not item.getFullType or not item.getCondition or not item.getConditionMax then
            return
        end

        -- Only handle our rotor item
        if item:getFullType() ~= "TikitownPower.Rotor" then
            return
        end

        local condMax = item:getConditionMax()
        if not condMax or condMax <= 0 then
            return
        end

        local cond = item:getCondition() or 0
        local pct = cond / condMax

        local baseHeight = self.height

        local barHeight = 6
        local bottomOffset = 14      
        local extraPadding = 10      -- space under the bar

        -- Set final height just once per render using the base height
        self:setHeight(baseHeight + barHeight + extraPadding)

        local barWidth = self.width - 10
        local barX = 5
        local barY = baseHeight - 4  -- draw just under vanilla content

        -- Background of the bar
        self:drawRect(barX, barY, barWidth, barHeight, 0.3, 0, 0, 0)

        -- Choose bar color by condition %
        local r, g, b = 0, 1, 0
        if pct < 0.3 then
            r, g, b = 1, 0, 0
        elseif pct < 0.6 then
            r, g, b = 1, 0.6, 0
        elseif pct < 0.9 then
            r, g, b = 1, 1, 0
        end

        -- Foreground bar
        local fillWidth = (barWidth - 2) * pct
        if fillWidth < 0 then fillWidth = 0 end

        self:drawRect(barX + 1, barY + 1, fillWidth, barHeight - 2, 1, r, g, b)
    end

    print("[TikitownPower] Rotor tooltip condition hook active.")
end

Events.OnGameStart.Add(addRotorConditionHook)
