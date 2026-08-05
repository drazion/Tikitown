require 'NPCs/ZombiesZoneDefinition'

if SandboxVars.Tikitown.HistoricalOutfits then

	table.insert(ZombiesZoneDefinition.Default,{name = "TikitownPirate", chance = .05});
	table.insert(ZombiesZoneDefinition.Default,{name = "TikitownVietnamWar", chance = .05});
	table.insert(ZombiesZoneDefinition.Default,{name = "TikitownWWII", chance = .05});
	table.insert(ZombiesZoneDefinition.Default,{name = "TikitownWWI", chance = .05});
	table.insert(ZombiesZoneDefinition.Default,{name = "TikitownSAWar", chance = .05});
	table.insert(ZombiesZoneDefinition.Default,{name = "TikitownCWUS", chance = .05});
	table.insert(ZombiesZoneDefinition.Default,{name = "TikitownCWCS", chance = .05});
	table.insert(ZombiesZoneDefinition.Default,{name = "TikitownTwelveWarUS", chance = .05});
	table.insert(ZombiesZoneDefinition.Default,{name = "TikitownRevWarUS", chance = .05});
end

ZombiesZoneDefinition.TEP_Zeds = {
	TEPZombie = {
		name="TEPZombie",
		chance=65,
	},
	Student = {
		name="Student",
		chance=20,
	},
	Varsity = {
		name="Varsity",
		chance=15,
	},
}

ZombiesZoneDefinition.BSSOPolice = { 	--Name of a custom zone on the map
	BSSOSheriffOutfit = {				-- A reference name
		name="BSSOSheriffOutfit",		-- name of the outfit in Clothing.XML
		chance=1,						-- chance to spawn
		gender="male", 					-- male only
		Items = {
			{ "Base.Key1", 50 },  -- 50% chance to spawn with a key
			{ "Base.KeyRing", 30 }, -- 30% chance to spawn with a keyring
		},
	},
	BSSOBlackOutfit = {
		name="BSSOBlackOutfit",
		chance=17,
		Items = {
			{ "Base.Key1", 50 },  -- 50% chance to spawn with a key
			{ "Base.KeyRing", 30 }, -- 30% chance to spawn with a keyring
		},
	},
	BSSOGrayOutfit = {
		name="BSSOGrayOutfit",
		chance=17,
		Items = {
			{ "Base.Key1", 50 },  -- 50% chance to spawn with a key
			{ "Base.KeyRing", 30 }, -- 30% chance to spawn with a keyring
		},
	},
	Police = {
		name="Police",
		chance=20,
	},
	
	PoliceState = {
		name="PoliceState",
		chance=10,
	},
	
	Detective = {
		name="Detective",
		chance=15,
	},
	
	OfficeWorkerSkirt = {
	name="OfficeWorkerSkirt",
	chance=10,
	gender="female",
	},
	
	OfficeWorker = {
		name="OfficeWorker",
		chance=5,
		gender="male",
		beardStyles="null:80",
	},
	
	Agent = {
		name="Agent",
		chance=5,
	},
}

