--=============================================================
-- TikitownPower_Tooltips.lua
-- Properly inject condition bar for TikitownPower.Rotor
--=============================================================

-- Wait for ISToolTipInv to exist
local function addRotorConditionHook()
    if not ISToolTipInv or not ISToolTipInv.render then
        print("[TikitownPower] ISToolTipInv not ready.")
        return
    end

    -- Keep original render function
    local originalRender = ISToolTipInv.render

    function ISToolTipInv:render()
        -- Run vanilla draw first
        originalRender(self)

        -- Validate item
        local item = self.item
        if not item or item:getFullType() ~= "TikitownPower.Rotor" then
            return
        end

        local cond, condMax = item:getCondition(), item:getConditionMax()
		if condMax and condMax > 0 then
			local pct = cond / condMax

			-- make space for condition bar + bottom padding
			local barHeight = 6
			local bottomOffset = 14
			local extraPadding = 10  -- space under the bar
			self:setHeight(self.height + barHeight + extraPadding)

			local barWidth = self.width - 10
			local barX = 5
			local barY = self.height - (barHeight + extraPadding + 4)

			self:drawRect(barX, barY, barWidth, barHeight, 0.3, 0, 0, 0)

			local r, g, b = 0, 1, 0
			if pct < 0.3 then r, g, b = 1, 0, 0
			elseif pct < 0.6 then r, g, b = 1, 0.6, 0
			elseif pct < 0.9 then r, g, b = 1, 1, 0
			end

			self:drawRect(barX + 1, barY + 1, (barWidth - 2) * pct, barHeight - 2, 1, r, g, b)
		end


    end

    print("[TikitownPower] Rotor tooltip condition hook active.")
end

Events.OnGameStart.Add(addRotorConditionHook)
