TikitownPower = TikitownPower or {}

-- --------- Flat, single-value system parts (non-turbine) ----------
TikitownPower.parts = {
    -- Power Delivery System
    DeliveryInverterCoils   	= { label = "Inverter Coils",		max = 100, removable = true, wear_rate = 5, rep_anim="Disassemble", rep_sound="Dismantle" },
    DeliveryTransformerLinks 	= { label = "Transformer Links",    max = 100, removable = true, wear_rate = 5, rep_anim="Disassemble", rep_sound="Dismantle" },
    DeliveryBreakerArray   		= { label = "Breaker Array",        max = 100, removable = false, wear_rate = 5, rep_anim="Disassemble", rep_sound="Dismantle" },    
}

-- --------- Turbine part DEFINITIONS (labels/max) ----------
TikitownPower.TurbinePartDefs = {
    TurbineRotor         		= { label = "Rotor",         		max = 100, removable = true, wear_rate = 1, rep_anim="Blowtorch", rep_sound="Blowtorch" },
    TurbineStator       		= { label = "Stator",          		max = 100, removable = true, wear_rate = 5, rep_anim="Disassemble", rep_sound="Dismantle" },
    TurbineCasing        		= { label = "Casing",          		max = 100, removable = false, wear_rate = 5, rep_anim="Blowtorch", rep_sound="Blowtorch"  },
    TurbineControlSystem 		= { label = "Control System",  		max = 100, removable = true, wear_rate = 5, rep_anim="Disassemble", rep_sound="Dismantle" },
    TurbineLubeSystem    		= { label = "Lubrication System", 	max = 100, removable = false, wear_rate = 2, rep_anim="refuelgascan", rep_sound="GetWaterFromDispenserCeramic" },
    TurbineCoolSystem    		= { label = "Cooling System",  		max = 100, removable = false, wear_rate = 2, rep_anim="refuelgascan", rep_sound="GetWaterFromDispenserCeramic" },
}

TikitownPower.CondenserPartDefs = {
	 -- Condenser
    CondChamber             = { label = "Condenser Chamber",      max = 100, removable = false, wear_rate = 5, rep_anim="Blowtorch", rep_sound="Blowtorch"},
    CondWaterCircuits       = { label = "Cooling Water Circuits", max = 100, removable = false, wear_rate = 5, rep_anim="Disassemble", rep_sound="Dismantle" },
    CondWetAirPumps         = { label = "Wet Air Pumps",          max = 100, removable = false, wear_rate = 4, rep_anim="refuelgascan", rep_sound="GetWaterFromDispenserCeramic" },
    CondHotWell             = { label = "Hot Well",               max = 100, removable = false, wear_rate = 3, rep_anim="Blowtorch", rep_sound="Blowtorch" },
}

TikitownPower.FurnacePartDef = {
	 -- Coal Furnace
    FurnFurnace             = { label = "Coal Furnace",           max = 100, removable = false, wear_rate = 5, rep_anim="Blowtorch", rep_sound="Blowtorch" },
    FurnWaterWalls          = { label = "Water Walls",            max = 100, removable = false, wear_rate = 5, rep_anim="Blowtorch", rep_sound="Blowtorch" },
    FurnSuperHeater         = { label = "Superheater",            max = 100, removable = false, wear_rate = 4, rep_anim="Blowtorch", rep_sound="Blowtorch" },
    FurnReHeater            = { label = "Reheater",               max = 100, removable = false, wear_rate = 4, rep_anim="Disassemble", rep_sound="Dismantle" },
    FurnEcon                = { label = "Economizer",             max = 100, removable = false, wear_rate = 2, rep_anim="Blowtorch", rep_sound="Blowtorch" },
    FurnPreheat             = { label = "Air Preheater",          max = 100, removable = false, wear_rate = 2, rep_anim="Blowtorch", rep_sound="Blowtorch" },
    FurnControl             = { label = "Furnace Control System", max = 100, removable = true, wear_rate = 5, rep_anim="Disassemble", rep_sound="Dismantle" },
}

TikitownPower.PumpPartDef = {
	-- Pumps
    PumpImpeller            = { label = "Pump Impeller",          max = 100, removable = true, wear_rate = 1, rep_anim="Blowtorch", rep_sound="Blowtorch" },
    PumpShaft               = { label = "Pump Shaft",             max = 100, removable = false, wear_rate = 5, rep_anim="Blowtorch", rep_sound="Blowtorch" },
    PumpHousing             = { label = "Pump Housing",           max = 100, removable = false, wear_rate = 5, rep_anim="Blowtorch", rep_sound="Blowtorch" },
    PumpSeals               = { label = "Pump Seals",             max = 100, removable = true, wear_rate = 1, rep_anim="Disassemble", rep_sound="Dismantle" },
    PumpSuction             = { label = "Pump Suction Nozzle",    max = 100, removable = true, wear_rate = 2, rep_anim="Blowtorch", rep_sound="Blowtorch" },
    PumpDisch               = { label = "Pump Discharge Nozzle",  max = 100, removable = true, wear_rate = 2, rep_anim="Blowtorch", rep_sound="Blowtorch" },
    PumpCheckValve          = { label = "Pump Check Valve",       max = 100, removable = true, wear_rate = 1, rep_anim="Blowtorch", rep_sound="Blowtorch" },
}

-- Default template for three turbines (just keys here; values are seeded in getData)
local TurbineTemplate = {
    TurbineRotor = true, TurbineStator = true, 
    TurbineCasing = true, TurbineControlSystem = true,
    TurbineLubeSystem = true, TurbineCoolSystem = true,
}

local CondenserTemplate = {
	CondChamber = true, CondWaterCircuits = true, CondWetAirPumps = true, CondHotWell = true,
}

local FurnaceTemplate = {
	FurnFurnace = true, FurnWaterWalls = true, FurnSuperHeater = true, FurnReHeater = true, FurnEcon = true, FurnPreheat = true, FurnControl = true,
}

local PumpTemplate = {
	PumpImpeller = true, PumpShaft = true, PumpHousing = true, PumpSeals = true, PumpSuction = true, PumpDisch = true, PumpCheckValve = true,
}

local function isTableEmpty(tbl)
    if type(tbl) ~= "table" then
        return true
    end
    for _ in pairs(tbl) do
        return false -- found something, not empty
    end
    return true -- saw nothing
end

local seedLow = 30
local seedHigh = 71

local function seedTurbine()
    local t = {}
    for partID, _ in pairs(TurbineTemplate) do
        -- seed each part health 30..70 on first creation
        t[partID] = ZombRand(seedLow, seedHigh)
    end
    return t
end

local function seedCondenser()
	local c = {}
	for partID, _ in pairs (CondenserTemplate) do
		c[partID] = ZombRand(seedLow,seedHigh)
	end
	return c
end

local function seedFurnace()
	local c = {}
	for partID, _ in pairs (FurnaceTemplate) do
		c[partID] = ZombRand(seedLow,seedHigh)
	end
	return c
end

local function seedPump()
	local c = {}
	for partID, _ in pairs (PumpTemplate) do
		c[partID] = ZombRand(seedLow,seedHigh)
	end
	return c
end

-- Return a single struct the UI expects:
-- {
--   parts    = { DeliveryInverterCoils=100, ... },
--   turbines = {
--       Turbine1 = { TurbineRotor=88, ... },
--       Turbine2 = { ... },
--       Turbine3 = { ... },
--   }
-- }
function TikitownPower.getData()
    -- be defensive: ModData table must exist and give a table back
    local data = ModData and ModData.getOrCreate and ModData.getOrCreate("TikitownPowerGrid") or nil
    if type(data) ~= "table" then
        data = {}               -- never return nil up the stack
    end
	
	
    -- normalize sub-tables before any pairs()
    if type(data.parts)    ~= "table" then data.parts    = {} end
    -- Ensure data.turbines is always a table
	if type(data.turbines) ~= "table" then data.turbines = {} end
	if type(data.condensers) ~= "table" then data.condensers = {} end
	if type(data.furnaces) ~= "table" then data.furnaces = {} end
	if type(data.pumps) ~= "table" then data.pumps = {} end
	
	if type(data.repairCounts) ~= "table" then
        data.repairCounts = {}
    end
	
	-- Populate Furnaces
	local furnacesEmpty = isTableEmpty(data.furnaces)
	if furnacesEmpty then
		-- First-time seeding
		data.furnaces.Furnace1 = seedFurnace()
		data.furnaces.Furnace2 = seedFurnace()
	else
		-- Just make sure the two furnaces exist; do NOT repopulate missing parts
		data.furnaces.Furnace1 = data.furnaces.Furnace1 or seedFurnace()
		data.furnaces.Furnace2 = data.furnaces.Furnace2 or seedFurnace()
	end

	
	--Populate Condensers
	local condensersEmpty = isTableEmpty(data.condensers)
	if condensersEmpty then
		data.condensers.Condenser1 = seedCondenser()
		data.condensers.Condenser2 = seedCondenser()
	else
		data.condensers.Condenser1 = data.condensers.Condenser1 or seedCondenser()
		data.condensers.Condenser2 = data.condensers.Condenser2 or seedCondenser()
	end
	
	--Populate Turbines
	local turbinesEmpty = isTableEmpty(data.turbines)
	if turbinesEmpty then
		data.turbines.Turbine1 = seedTurbine()
		data.turbines.Turbine2 = seedTurbine()
		data.turbines.Turbine3 = seedTurbine()
		data.turbines.Turbine4 = seedTurbine()
	else
		-- ensure each turbine exists
		data.turbines.Turbine1 = data.turbines.Turbine1 or seedTurbine()
		data.turbines.Turbine2 = data.turbines.Turbine2 or seedTurbine()
		data.turbines.Turbine3 = data.turbines.Turbine3 or seedTurbine()
		data.turbines.Turbine4 = data.turbines.Turbine4 or seedTurbine()
	end
	
	--Populate Pumps
	local pumpsEmpty = isTableEmpty(data.pumps)
	if pumpsEmpty then
		data.pumps.Pump1 = seedPump()
		data.pumps.Pump2 = seedPump()
		data.pumps.Pump3 = seedPump()
		data.pumps.Pump4 = seedPump()
	else
		-- ensure each turbine exists
		data.pumps.Pump1 = data.pumps.Pump1 or seedPump()
		data.pumps.Pump2 = data.pumps.Pump2 or seedPump()
		data.pumps.Pump3 = data.pumps.Pump3 or seedPump()
		data.pumps.Pump4 = data.pumps.Pump4 or seedPump()
	end
		
    -- single-value parts: fill in defaults
    for id, def in pairs(TikitownPower.parts) do
        if data.parts[id] == nil then
            data.parts[id] = def.max or 100
        end
    end

	--print("GD A", type(ModData), ModData and type(ModData.getOrCreate))
	--print("GD B", type(data))
	
    -- keep ModData in sync (SP-friendly)
    ModData.transmit("TikitownPowerGrid")

    return data
end

TikitownPower.RepairRequirements = {

    ----------------------------------------------------------------
    -- TURBINE PARTS
    ----------------------------------------------------------------

    -- ROTOR  (matches RepairTurbineRotor craftRecipe)
    TurbineRotor = {
        -- SkillRequired = Mechanics:7;Electricity:7
        skills = { Mechanics = 7, Electricity = 7 },
        items = {
            { type = "TikitownPower.TurbineBlades",    count = 2 },
            { type = "Base.AluminumScrap",            count = 4 },
            { type = "Base.SteelBar",                 count = 2 },
            { type = "Base.MetalBar",                 count = 2 },
            { type = "Base.FiberglassTape",           count = 1 },
            { type = "TikitownPower.IndustrialGrease",count = 1 },
        },
        tools = {
            -- item 3 [Base.BlowTorch] mode:keep flags[Prop1]
            { type = "Base.BlowTorch",   uses = 3 },
            -- item 1 tags[WeldingMask]
            { type = "Base.WeldingMask" },
        },
        anim = "BlowTorch",
    },

    -- STATOR (matches RepairTurbineStator)
    TurbineStator = {
        -- SkillRequired = Mechanics:7;Electricity:7
        skills = { Mechanics = 7, Electricity = 7 },
        items = {
            { type = "Base.SteelBar",         count = 2 },
            { type = "Base.MetalBar",         count = 2 },
            { type = "Base.ElectricWire",     count = 4 },
            { type = "Base.ElectronicsScrap", count = 4 },
        },
        tools = {
            -- Wrench, Screwdriver, Pliers via tags
            { type = "Base.Wrench"      },
            { type = "Base.Screwdriver" },
            { type = "Base.Pliers"      },
        },
        anim = "Loot",
    },

    -- CASING 
    TurbineCasing = {
        skills = { Maintenance = 7, MetalWelding = 7 },
        items = {
            { type = "Base.SheetMetal",      count = 4 },
            { type = "Base.SmallSheetMetal", count = 8 },
            { type = "Base.MetalBar",        count = 4 },
        },
        tools = {
            { type = "Base.WeldingMask" },
            { type = "Base.BlowTorch",   uses = 3 },
        },
        anim = "BlowTorch",
    },

    -- CONTROL SYSTEM (matches RepairTurbineControlSystem)
    TurbineControlSystem = {
        -- SkillRequired = Electricity:6;Maintenance:3
        skills = { Electricity = 6, Maintenance = 3 },
        items = {
            { type = "Base.ElectricWire",     count = 4 },
            { type = "Base.ElectronicsScrap", count = 4 },
        },
        tools = {
            { type = "Base.Wrench"      },
            { type = "Base.Screwdriver" },
            { type = "Base.Pliers"      },
        },
        anim = "Loot",
    },

    -- LUBRICATION SYSTEM 
    TurbineLubeSystem = {
        skills = { Maintenance = 3 },
        items = {
            { type = "TikitownPower.IndustrialOil", count = 1 },
        },
        tools = {
            { type = "Base.Funnel" },
            { type = "Base.Wrench" },
        },
        anim = "Loot",
    },

    -- COOLING SYSTEM 
    TurbineCoolSystem = {
        skills = { Maintenance = 3 },
        items = {
            { type = "TikitownPower.IndustrialAntifreeze", count = 1 },
        },
        tools = {
            { type = "Base.Funnel" },
            { type = "Base.Wrench" },
        },
        anim = "Loot",
    },

    ----------------------------------------------------------------
    -- CONDENSER PARTS (no repair recipes in txt yet, left as is)
    ----------------------------------------------------------------

    CondChamber = {
        skills = { Maintenance = 3, MetalWelding = 7 },
        items = {
            { type = "Base.SheetMetal",      count = 4 },
            { type = "Base.SmallSheetMetal", count = 2 },
        },
        tools = {
            { type = "Base.WeldingMask" },
            { type = "Base.BlowTorch", uses = 3 },
        },
        anim = "BlowTorch",
    },

    CondWaterCircuits = {
        skills = { Maintenance = 3, MetalWelding = 7 },
        items = {
            { type = "Base.MetalPipe", count = 4 },
        },
        tools = {
            { type = "Base.WeldingMask" },
            { type = "Base.BlowTorch", uses = 3 },
        },
        anim = "BlowTorch",
    },

    CondWetAirPumps = {
        skills = { Maintenance = 3 },
        items = {
           { type = "TikitownPower.IndustrialOil", count = 1 },
        },
        tools = {
           { type = "Base.Funnel" },
           { type = "Base.Wrench" },
        },
        anim = "Loot",
    },

    CondHotWell = {
        skills = { Maintenance = 3, MetalWelding = 7 },
        items = {
           { type = "Base.MetalPipe",      count = 2 },
           { type = "Base.SheetMetal",     count = 4 },
           { type = "Base.SmallSheetMetal",count = 4 },
        },
        tools = {
           { type = "Base.WeldingMask" },
           { type = "Base.BlowTorch", uses = 2 },
        },
        anim = "Loot",
    },

    ----------------------------------------------------------------
    -- FURNACE PARTS
    ----------------------------------------------------------------

    -- Furnace shell, etc. still custom since there are no RepairFurn* recipes
    FurnFurnace = {
        skills = { Maintenance = 3, MetalWelding = 7 },
        items = {
           { type = "Base.SheetMetal",      count = 6 },
           { type = "Base.SmallSheetMetal", count = 4 },
        },
        tools = {
           { type = "Base.WeldingMask" },
           { type = "Base.BlowTorch", uses = 2 },
        },
        anim = "BlowTorch",
    },

    FurnWaterWalls = {
        skills = { Maintenance = 3, MetalWelding = 7 },
        items = {
           { type = "Base.SheetMetal",      count = 2 },
           { type = "Base.SmallSheetMetal", count = 2 },
           { type = "Base.MetalPipe",       count = 6 },
        },
        tools = {
           { type = "Base.WeldingMask" },
           { type = "Base.BlowTorch", uses = 2 },
        },
        anim = "BlowTorch",
    },

    FurnSuperHeater = {
        skills = { Maintenance = 3, MetalWelding = 7 },
        items = {
           { type = "Base.SmallSheetMetal", count = 2 },
           { type = "Base.MetalPipe",       count = 6 },
        },
        tools = {
           { type = "Base.WeldingMask" },
           { type = "Base.BlowTorch", uses = 2 },
        },
        anim = "BlowTorch",
    },

    FurnReHeater = {
        skills = { Maintenance = 3, Electricity = 5 },
        items = {
           { type = "Base.ElectronicsScrap", count = 2 },
           { type = "Base.ElectricWire",     count = 6 },
        },
        tools = {
            { type = "Base.Screwdriver" },
            { type = "Base.Wrench"      },
            { type = "Base.Pliers"      },
        },
        anim = "BlowTorch",
    },

    FurnEcon = {
        skills = { Maintenance = 3, Electricity = 4, MetalWelding = 4 },
        items = {
           { type = "Base.ScrapMetal",          count = 4 },
           { type = "Base.ElectricWire",        count = 4 },
           { type = "Base.ElectronicsScrap",    count = 2 },
           { type = "TikitownPower.IndustrialFilter", count = 2 },
        },
        tools = {
            { type = "Base.WeldingMask" },
            { type = "Base.BlowTorch", uses = 2 },
        },
        anim = "BlowTorch",
    },

    FurnPreheat = {
        skills = { Maintenance = 3, MetalWelding = 5 },
        items = {
            { type = "Base.MetalPipe",      count = 6 },
            { type = "Base.SheetMetal",     count = 2 },
            { type = "Base.SmallSheetMetal",count = 2 },
        },
        tools = {
            { type = "Base.WeldingMask" },
            { type = "Base.BlowTorch", uses = 2 },
        },
        anim = "BlowTorch",
    },

    -- FURNACE CONTROL SYSTEM (matches RepairFurnaceControlSystem)
    FurnControl = {
        -- SkillRequired = Electricity:6;Maintenance:3
        skills = { Electricity = 6, Maintenance = 3 },
        items = {
            { type = "Base.ElectricWire",     count = 4 },
            { type = "Base.ElectronicsScrap", count = 4 },
        },
        tools = {
            { type = "Base.Screwdriver" },
            { type = "Base.Wrench"      },
            { type = "Base.Pliers"      },
        },
        anim = "Loot",
    },

    ----------------------------------------------------------------
    -- PUMP PARTS
    ----------------------------------------------------------------

    -- Pump Impeller (matches RepairPumpImpeller)
    PumpImpeller = {
        -- SkillRequired = MetalWelding:5;Maintenance:3
        skills = { MetalWelding = 5, Maintenance = 3 },
        items = {
            { type = "TikitownPower.PumpBlades", count = 1 },
            { type = "TikitownPower.PumpSeals",  count = 1 },
            { type = "Base.SmallSheetMetal",     count = 1 },
        },
        tools = {
            { type = "Base.BlowTorch" },
            { type = "Base.WeldingMask" },
        },
        anim = "Loot",
    },

    -- Pump Shaft (no repair recipe in txt, keep custom)
    PumpShaft = {
        skills = { Maintenance = 3, MetalWelding = 5 },
        items = {
            { type = "Base.ScrapMetal",       count = 4 },
            { type = "Base.SheetMetal",       count = 2 },
            { type = "Base.SmallSheetMetal",  count = 2 },
            { type = "TikitownPower.PumpSeals", count = 2 },
        },
        tools = {
            { type = "Base.WeldingMask" },
            { type = "Base.BlowTorch", uses = 2 },
        },
        anim = "BlowTorch",
    },

    -- Pump Housing (no repair recipe in txt, keep custom)
    PumpHousing = {
        skills = { Maintenance = 3, MetalWelding = 5 },
        items = {
            { type = "Base.ScrapMetal",       count = 4 },
            { type = "Base.SheetMetal",       count = 4 },
            { type = "Base.SmallSheetMetal",  count = 2 },
        },
        tools = {
            { type = "Base.WeldingMask" },
            { type = "Base.BlowTorch", uses = 2 },
        },
        anim = "BlowTorch",
    },

    -- Pump Seals (matches RepairPumpSeals)
    PumpSeals = {
        -- SkillRequired = Maintenance:1
        skills = { Maintenance = 1 },
        items = {
            { type = "Base.TirePiece",                 count = 2 },
            { type = "TikitownPower.IndustrialGrease", count = 1 },
        },
        tools = {
            { type = "Base.Wrench" },
        },
        anim = "Loot",
    },

    -- Pump Suction Nozzle (matches RepairPumpSuction)
    PumpSuction = {
        -- SkillRequired = MetalWelding:3;Maintenance:3
        skills = { MetalWelding = 3, Maintenance = 3 },
        items = {
            { type = "TikitownPower.PumpBlades", count = 1 },
            { type = "TikitownPower.PumpSeals",  count = 1 },
            { type = "Base.ScrapMetal",         count = 4 },
            { type = "Base.SmallSheetMetal",    count = 2 },
            { type = "Base.SheetMetal",         count = 1 },
        },
        tools = {
            { type = "Base.BlowTorch" },
            { type = "Base.WeldingMask" },
        },
        anim = "BlowTorch",
    },

    -- Pump Discharge Nozzle (matches RepairPumpDisch)
    PumpDisch = {
        -- SkillRequired = MetalWelding:3;Maintenance:3
        skills = { MetalWelding = 3, Maintenance = 3 },
        items = {
            { type = "TikitownPower.PumpBlades", count = 1 },
            { type = "TikitownPower.PumpSeals",  count = 1 },
            { type = "Base.ScrapMetal",         count = 4 },
            { type = "Base.SmallSheetMetal",    count = 2 },
            { type = "Base.SheetMetal",         count = 1 },
        },
        tools = {
            { type = "Base.BlowTorch" },
            { type = "Base.WeldingMask" },
        },
        anim = "BlowTorch",
    },

    -- Pump Check Valve (matches RepairPumpCheckValve)
    PumpCheckValve = {
        -- SkillRequired = MetalWelding:3;Maintenance:3
        skills = { MetalWelding = 3, Maintenance = 3 },
        items = {
            { type = "TikitownPower.PumpSeals",  count = 1 },
            { type = "Base.ScrapMetal",         count = 4 },
            { type = "Base.SmallSheetMetal",    count = 2 },
        },
        tools = {
            { type = "Base.BlowTorch" },
            { type = "Base.WeldingMask" },
        },
        anim = "BlowTorch",
    },
}


