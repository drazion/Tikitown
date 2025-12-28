require "Items/ProceduralDistributions"

local function preDistributionMerge()

    -- Turbine parts crates: decent chance of any turbine part
    ProceduralDistributions.list.tikitownpowerstorageTurbineCrates = {
        rolls = 3,
        items = {
            "TikitownPower.TurbineRotor",          3,  
            "TikitownPower.TurbineControlSystem",  3,
            "TikitownPower.TurbineBlades",         5,  
            "TikitownPower.TurbineStator",         3,
        },
        junk = {
            rolls = 1,
            items = {}
        }
    }

    -- Pump parts crates
    ProceduralDistributions.list.tikitownpowerstoragePumpCrates = {
        rolls = 3,
        items = {
            "TikitownPower.PumpBlades",     4,
            "TikitownPower.PumpCheckValve", 3,
            "TikitownPower.PumpDisch",      3,
            "TikitownPower.PumpSuction",    3,
            "TikitownPower.PumpImpeller",   4,
            "TikitownPower.PumpSeals",      5, 
        },
        junk = {
            rolls = 1,
            items = {}
        }
    }

    -- Furnace control crates (single key part)
    ProceduralDistributions.list.tikitownpowerstorageFurnaceCrates = {
        rolls = 2,
        items = {
            "TikitownPower.FurnControl", 4,
        },
        junk = {
            rolls = 1,
            items = {}
        }
    }

    -- Fluids crates
    ProceduralDistributions.list.tikitownpowerstorageFluidCrates = {
        rolls = 3,
        items = {
            "TikitownPower.IndustrialGrease",     4,
            "TikitownPower.IndustrialOil",        4,
            "TikitownPower.IndustrialAntifreeze", 3,
        },
        junk = {
            rolls = 1,
            items = {}
        }
    }

    -- Repair materials: general workshop stuff
    ProceduralDistributions.list.tikitownpowerRepairMats = {
        rolls = 4,
        items = {
            "TikitownPower.EmptyIndustrialCan",  2,
            "Base.ElectricWire",                 4,
            "Base.ElectronicsScrap",            4,
            "Base.Screws",                      4,
            "Base.SmallSheetMetal",             3,
            "Base.AluminumScrap",               2,
            "Base.SteelBar",                    2,
            "Base.MetalBar",                    2,
            "Base.FiberglassTape",              1,
            "Base.TirePiece",                   1,
        },
        junk = {
            rolls = 1,
            items = {}
        }
    }

    -- Tools: core mechanical & welding tools
    ProceduralDistributions.list.tikitownpowerTools = {
        rolls = 3,
        items = {
            -- Core mechanic tools
            "Base.Wrench",          4,
            "Base.Screwdriver",     5,
            "Base.Pliers",          3,
            "Base.PipeWrench",      3,
            "Base.Hammer",          3,
            "Base.Crowbar",         2,

            -- Cutting / general workshop
            "Base.Saw",             2,
            "Base.BallPeenHammer",  1,  

            -- Metalworking
            "Base.BlowTorch",       2,
            "Base.WeldingMask",     2,
            "Base.PropaneTank",     1,
        },
        junk = {
            rolls = 1,
            items = {}
        }
    }

    -- General shelves in the power plant
    ProceduralDistributions.list.tikitownpowerstorageShelves = {
        rolls = 3,
        items = {
            "Base.ElectricWire",     4,
            "Base.ElectronicsScrap", 4,
            "Base.Screws",           4,
            "Base.AluminumScrap",    3,
            "Base.SteelBar",         2,
            "Base.MetalBar",         2,
            "Base.FiberglassTape",   2,
        },
        junk = {
            rolls = 1,
            items = {}
        }
    }

    ProceduralDistributions.list.tikitownpowerBooks = {
        rolls = 3,
        items = {
            "TikitownPower.PlantFurnaceTechnicalManual",   10,
            "TikitownPower.PlantPumpTechnicalManual",      10,
            "TikitownPower.PlantCondenserTechnicalManual", 10,
            "TikitownPower.PlantTurbineTechnicalManual",   10,
        },
        junk = {
            rolls = 1,
            items = {}
        }
    }

    ----------------------------------------------------------------
    -- Add Shop Floor Survivalist mags to some vanilla lists
    ----------------------------------------------------------------
    local function addMag(listName, fullType, weight)
        local dist = ProceduralDistributions.list[listName]
        if not dist or not dist.items then
            return
        end
        table.insert(dist.items, fullType)
        table.insert(dist.items, weight)
    end

    -- Vol. 1
    addMag("CampingStoreBooks",  "TikitownPower.ShopFloorSurvivalist",  2)
    addMag("MagazineRackMixed",  "TikitownPower.ShopFloorSurvivalist",  1)
    addMag("GarageMechanics",    "TikitownPower.ShopFloorSurvivalist",  1)
    addMag("BookstoreBooks",     "TikitownPower.ShopFloorSurvivalist",  1)

    -- Vol. 2
    addMag("CampingStoreBooks",  "TikitownPower.ShopFloorSurvivalist2", 2)
    addMag("MagazineRackMixed",  "TikitownPower.ShopFloorSurvivalist2", 1)
    addMag("GarageMechanics",    "TikitownPower.ShopFloorSurvivalist2", 1)
    addMag("BookstoreBooks",     "TikitownPower.ShopFloorSurvivalist2", 1)

    -- Vol. 3
    addMag("CampingStoreBooks",  "TikitownPower.ShopFloorSurvivalist3", 2)
    addMag("MagazineRackMixed",  "TikitownPower.ShopFloorSurvivalist3", 1)
    addMag("GarageMechanics",    "TikitownPower.ShopFloorSurvivalist3", 1)
    addMag("BookstoreBooks",     "TikitownPower.ShopFloorSurvivalist3", 1)
end

Events.OnPreDistributionMerge.Add(preDistributionMerge)
