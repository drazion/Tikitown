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
