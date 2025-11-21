require "TikitownPower_Parts"
require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISScrollingListBox"

TikitownPower  = TikitownPower or {}
TikitownPowerUI = ISPanel:derive("TikitownPowerUI")
local UI = TikitownPowerUI  

function TikitownPowerUI:new(x, y, w, h)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.moveWithMouse = true
    o.resizable = true
    o.minimumWidth  = 350
    o.minimumHeight = 400
    return o
end

function UI:initialise()
    ISPanel.initialise(self)

    -- Close
    self.closeButton = ISButton:new(self.width-22, 2, 20, 20, "X", self, UI.close)
    self:addChild(self.closeButton)

    -- Default tab
    self.activeTab = "delivery"

    -- Tabs
    local tabs = {
        { id="delivery",   label="Delivery"   },
        { id="turbines",   label="Turbines"   },
        { id="condensers", label="Condensers" },
        { id="furnaces",   label="Furnaces"   },
        { id="pumps",      label="Pumps"      },
    }
    local x = 10
    for _, t in ipairs(tabs) do
        local btn = ISButton:new(x, 50, 75, 20, t.label, self, function(panelSelf)
            panelSelf.activeTab = t.id
            panelSelf:refreshList()
        end)
        self:addChild(btn)
        x = x + 78
    end

    -- List
    self.partsList = ISScrollingListBox:new(10, 75, self.width - 20, self.height - 85)
    self.partsList:initialise()
    self.partsList:instantiate()
    self.partsList.itemheight = 28
    self.partsList.font = UIFont.Small
    self.partsList.doDrawItem = function(list, y, row, alt)
    -- Protect against nils
    if not row then return y end
    local data = row.item or {}        -- row.item might be nil on header rows
    local text = row.text or ""

    -- Header row?
    if data.isHeader then
        -- Color the header by avg health if provided
        local avg = tonumber(data.avg) or 0
        local r,g,b = 1,1,1
        if avg >= 75 then      r,g,b = 0.7, 1.0, 0.7
        elseif avg >= 35 then  r,g,b = 1.0, 1.0, 0.6
        else                   r,g,b = 1.0, 0.7, 0.7
        end

        -- Draw a subtle bar behind header (visual grouping)
        list:drawRect(6, y+3, list.width-12, list.itemheight-6, 0.25, 0,0,0)
        list:drawText(text, 12, y+6, r,g,b,1, UIFont.Medium)
        return y + list.itemheight
    end

    -- Normal part row (with progress bar)
    local value = tonumber(data.value) or 0
    local max   = tonumber(data.max)   or 100
    local ratio = (max > 0) and math.min(math.max(value/max, 0), 1) or 0

    -- color by ratio
    local r,g,b
    if ratio >= 0.75 then        r,g,b = 0.1, 0.8, 0.1
    elseif ratio >= 0.35 then    r,g,b = 0.9, 0.9, 0.1
    else                         r,g,b = 0.9, 0.2, 0.2
    end

    -- label
    list:drawText(text, 10, y+6, 1,1,1,1, UIFont.Small)

    -- progress bar
    local barX = list.width * 0.45
    local barY = y + 6
    local barW = list.width * 0.45
    local barH = 14
    list:drawRect(barX, barY, barW, barH, 0.40, 0,0,0)           -- background
    list:drawRect(barX, barY, barW * ratio, barH, 0.80, r,g,b)   -- fill

    return y + list.itemheight
end

    self:addChild(self.partsList)

    -- First paint from local data
    self:syncParts(TikitownPower.getData())
end

function UI:syncParts(data)
    if type(data) ~= "table" then return end
    self.data     = (type(data.parts)    == "table") and data.parts    or {}
    self.turbines = (type(data.turbines) == "table") and data.turbines or {}
	self.condensers = (type(data.condensers) == "table") and data.condensers or {}
	self.furnaces = (type(data.furnaces) == "table") and data.furnaces or {}
	self.pumps = (type(data.pumps) == "table") and data.pumps or {}
    self:refreshList()
end

function UI:onResize()
    ISPanel.onResize(self)

    if self.partsList then
        self.partsList:setWidth(self.width - 24)
        self.partsList:setHeight(self.height - 85) -- was -65
    end

    if self.closeButton then
        self.closeButton:setX(self.width - 22)
    end
end


function UI:close()
    self:removeFromUIManager()
    TikitownPowerUI.instance = nil
end

function UI:render()
    ISPanel.render(self)
    self:drawText("Power Plant Systems", 12, 10, 1,1,1,1, UIFont.Title)
end

function TikitownPower.openUI()
    if TikitownPowerUI.instance then
        TikitownPowerUI.instance:bringToTop()
        return
    end
    local baseW, baseH = 480, 600
    local x = (getCore():getScreenWidth()  - baseW) / 2
    local y = (getCore():getScreenHeight() - baseH) / 2

    local ui = TikitownPowerUI:new(x, y, baseW, baseH)
    ui:initialise()
    ui:addToUIManager()
    ui:setVisible(true)
    TikitownPowerUI.instance = ui

    ui:syncParts(TikitownPower.getData())
    sendClientCommand(getSpecificPlayer(0), "TikitownPower", "RequestParts", {})
end

function UI:refreshList()
    if not self.partsList then return end
    self.partsList:clear()

   if self.activeTab == "turbines" then
    for turbineName, turbData in pairs(self.turbines or {}) do
        -- compute average
        local sum, n = 0, 0
        for _, v in pairs(turbData) do
            if type(v) == "number" then sum = sum + v; n = n + 1 end
        end
        local avg = (n > 0) and math.floor(sum / n) or 0

        -- header row
        self.partsList:addItem(("== %s =="):format(turbineName), { isHeader = true, avg = avg })

        -- part rows
        for partID, value in pairs(turbData) do
            -- turbine part defs first, then fallback to general parts 
            local def = TikitownPower.TurbinePartDefs and TikitownPower.TurbinePartDefs[partID]
                       or TikitownPower.parts[partID]
            if def then
                self.partsList:addItem(def.label, { id = partID, value = value, max = def.max or 100 })
            end
        end
    end
    return
		elseif self.activeTab == "condensers" then 
			for condenserName, condenserData in pairs(self.condensers or {}) do
			-- compute average
			local sum, n = 0, 0
			for _, v in pairs(condenserData) do
				if type(v) == "number" then sum = sum + v; n = n + 1 end
			end
			local avg = (n > 0) and math.floor(sum / n) or 0

			-- header row: pass a table {isHeader=true, avg=avg}
			self.partsList:addItem(("== %s =="):format(condenserName), { isHeader = true, avg = avg })

			-- part rows
			for partID, value in pairs(condenserData) do
				-- turbine part defs first, then fallback to general parts 
				local def = TikitownPower.CondenserPartDefs and TikitownPower.CondenserPartDefs[partID]
						   or TikitownPower.parts[partID]
				if def then
					self.partsList:addItem(def.label, { id = partID, value = value, max = def.max or 100 })
				end
			end
		end
	return
		elseif self.activeTab == "furnaces" then 
			for furnaceName, furnaceData in pairs(self.furnaces or {}) do
			-- compute average
			local sum, n = 0, 0
			for _, v in pairs(furnaceData) do
				if type(v) == "number" then sum = sum + v; n = n + 1 end
			end
			local avg = (n > 0) and math.floor(sum / n) or 0

			-- header row: NOTE pass a table {isHeader=true, avg=avg}
			self.partsList:addItem(("== %s =="):format(furnaceName), { isHeader = true, avg = avg })

			-- part rows
			for partID, value in pairs(furnaceData) do
				-- turbine part defs first, then fallback to general parts 
				local def = TikitownPower.FurnacePartDef and TikitownPower.FurnacePartDef[partID]
						   or TikitownPower.parts[partID]
				if def then
					self.partsList:addItem(def.label, { id = partID, value = value, max = def.max or 100 })
				end
			end
		end
	return
	elseif self.activeTab == "pumps" then
		for pumpName, pumpData in pairs(self.pumps or {}) do
			-- compute average
			local sum, n = 0, 0
			for _, v in pairs(pumpData) do
				if type(v) == "number" then sum = sum + v; n = n + 1 end
			end
			local avg = (n > 0) and math.floor(sum / n) or 0

			-- header row: NOTE pass a table {isHeader=true, avg=avg}
			self.partsList:addItem(("== %s =="):format(pumpName), { isHeader = true, avg = avg })

			-- part rows
			for partID, value in pairs(pumpData) do
				-- turbine part defs first, then fallback to general parts 
				local def = TikitownPower.PumpPartDef and TikitownPower.PumpPartDef[partID]
						   or TikitownPower.parts[partID]
				if def then
					self.partsList:addItem(def.label, { id = partID, value = value, max = def.max or 100 })
				end
			end
		end
	return
	end

    local categoryLookup = {
        delivery = {"DeliveryInverterCoils","DeliveryTransformerLinks","DeliveryBreakerArray"},
        --condensers = {"CondChamber","CondWaterCircuits","CondWetAirPumps","CondHotWell"},
        --furnaces = {"FurnFurnace","FurnWaterWalls","FurnSuperHeater","FurnReHeater","FurnEcon","FurnPreheat","FurnControl"},
        --pumps = {"PumpImpeller","PumpShaft","PumpHousing","PumpSeals","PumpSuction","PumpDisch","PumpCheckValve"},
    }

    local list = categoryLookup[self.activeTab]
    if list then
        for _, id in ipairs(list) do
            local value = self.data[id]
            local def   = TikitownPower.parts[id]
            if value and def then
                self.partsList:addItem(def.label, { id = id, value = value, max = def.max })
            end
        end
    end
end
