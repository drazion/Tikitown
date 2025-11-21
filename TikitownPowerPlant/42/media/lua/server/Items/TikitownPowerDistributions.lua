require "Items/SuburbsDistributions"
require "Items/ProceduralDistributions"
require "Items/ItemPicker"
require "Items/Distributions"

TikitownItemsDistribution = TikitownItemsDistribution or {}

SuburbsDistributions.tikitownpowerstorage = {

    -- Shelving with mixed plant supplies and some generic electrical/workshop stuff
    metal_shelves = {
        procedural = true,
        procList = {
            { name = "tikitownpowerstorageShelves", min = 1, max = 2, weightChance = 70 },

            -- Vanilla-style support stuff
            { name = "Electrician",     min = 0, max = 1, weightChance = 20 },  -- cables, fuse-y stuff
            { name = "ToolStoreMisc",   min = 0, max = 1, weightChance = 10 },  -- misc workshop bits
			{ name = "tikitownpowerBooks", min = 0, max = 1, weightChance = 30 },
        }
    },

    -- Crates with parts, fluids, and general workshop crates
    crate = {
        procedural = true,
        procList = {
            { name = "tikitownpowerRepairMats",        min = 1, max = 1, weightChance = 50 },
            { name = "tikitownpowerstorageFluidCrates",min = 1, max = 1, weightChance = 40 },
            { name = "tikitownpowerstorageFurnaceCrates", min = 1, max = 1, weightChance = 35 },
            { name = "tikitownpowerstoragePumpCrates",    min = 1, max = 1, weightChance = 35 },
            { name = "tikitownpowerstorageTurbineCrates", min = 1, max = 1, weightChance = 35 },

            -- Vanilla crate sets that fit an industrial power plant
            { name = "CrateTools",       min = 0, max = 1, weightChance = 30 },
            { name = "CrateMetalwork",   min = 0, max = 1, weightChance = 25 },
            { name = "CrateMechanics",   min = 0, max = 1, weightChance = 25 },
            { name = "CrateElectronics", min = 0, max = 1, weightChance = 20 },
            { name = "CratePropane",     min = 0, max = 1, weightChance = 5  },
        }
    },

    -- Tool cabinets: heavy on tools, mix in vanilla sets
    toolcabinet = {
        procedural = true,
        procList = {
            { name = "tikitownpowerTools", min = 0, max = 2, weightChance = 60 },

            -- Vanilla tool-heavy lists
            { name = "ToolStoreTools",    min = 0, max = 2, weightChance = 40 },
            { name = "GarageMechanics",   min = 0, max = 1, weightChance = 25 },
        }
    },
}

SuburbsDistributions.tikipowerplant = {

    -- General industrial shelving
    metal_shelves = {
        procedural = true,
        procList = {
            { name = "tikitownpowerstorageShelves", min = 1, max = 2, weightChance = 60 },
            { name = "Electrician",                 min = 0, max = 1, weightChance = 25 },
            { name = "ToolStoreMisc",               min = 0, max = 1, weightChance = 15 },
			{ name = "tikitownpowerBooks", min = 0, max = 99, weightChance = 30 },
        }
    },

    -- Crates around the plant floor
    cardboardbox = {
        procedural = true,
        procList = {
            -- Still favor your custom crates so plant parts actually show up
            { name = "tikitownpowerRepairMats",         min = 1, max = 1, weightChance = 45 },
            { name = "tikitownpowerstorageFluidCrates", min = 1, max = 1, weightChance = 35 },
            { name = "tikitownpowerstorageFurnaceCrates", min = 1, max = 1, weightChance = 30 },
            { name = "tikitownpowerstoragePumpCrates",    min = 1, max = 1, weightChance = 30 },
            { name = "tikitownpowerstorageTurbineCrates", min = 1, max = 1, weightChance = 30 },
			{ name = "tikitownpowerBooks", min = 0, max = 4, weightChance = 30 },
			
            -- Vanilla crates to blend it into the broader loot ecosystem
            { name = "CrateTools",       min = 0, max = 1, weightChance = 30 },
            { name = "CrateMetalwork",   min = 0, max = 1, weightChance = 25 },
            { name = "CrateMechanics",   min = 0, max = 1, weightChance = 25 },
            { name = "CrateElectronics", min = 0, max = 1, weightChance = 15 },
            { name = "CratePropane",     min = 0, max = 1, weightChance = 5  },
        }
    },

    -- Tool cabinets in the main plant
    toolcabinet = {
        procedural = true,
        procList = {
            { name = "tikitownpowerTools", min = 0, max = 2, weightChance = 55 },
            { name = "ToolStoreTools",     min = 0, max = 2, weightChance = 45 },
            { name = "GarageMechanics",    min = 0, max = 1, weightChance = 20 },
        }
    },
}

------------------------------------------------------------
--  PLANT OFFICE (where manuals live)
------------------------------------------------------------
SuburbsDistributions.ttp_office = {

    -- Desks: manuals plus normal office / mag clutter
    desk = {
        procedural = true,
        procList = {
            { name = "tikitownpowerBooks", min = 0, max = 99, weightChance = 30 },

            -- Vanilla “office” and general reading
            { name = "OfficeDesk",        min = 0, max = 1, weightChance = 40 },
            { name = "MagazineRackMixed", min = 0, max = 1, weightChance = 30 },
        }
    },

    -- Office shelves: more likely to hold multiple books
    shelves = {
        procedural = true,
        procList = {
            { name = "tikitownpowerBooks", min = 0, max = 1, weightChance = 40 },
            { name = "BookstoreBooks",     min = 0, max = 2, weightChance = 40 },
            { name = "ToolStoreBooks",     min = 0, max = 1, weightChance = 20 },
        }
    },

    -- Filing cabinets: some manuals, some office junk
    filingcabinet = {
        procedural = true,
        procList = {
            { name = "tikitownpowerBooks", min = 0, max = 99, weightChance = 25 },
            { name = "OfficeDesk",         min = 0, max = 2, weightChance = 55 },
            { name = "MagazineRackMixed",  min = 0, max = 1, weightChance = 20 },
        }
    },
}
