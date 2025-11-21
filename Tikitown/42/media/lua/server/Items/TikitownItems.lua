require "Items/ProceduralDistributions"

TikitownItemsDistribution = TikitownItemsDistribution or {}

function TikitownItemsDistribution.onInitGlobalModData(isNewGame)
	
	local cardSpawnBaseCommon = SandboxVars.Tikitown.CollectionBaseballCommon
	local cardSpawnBaseRare = SandboxVars.Tikitown.CollectionBaseballRare
	
	local cardSpawnZedCommon = SandboxVars.Tikitown.CollectionBaseballZombieCommon
	local cardSpawnZedRare = SandboxVars.Tikitown.CollectionBaseballZombieRare
		
	--Cards Spawns
	if SandboxVars.Tikitown.CollectionBaseball then
		TikitownItemsDistribution.TikitownCardSpawn(cardSpawnBaseCommon, cardSpawnBaseRare, cardSpawnZedCommon, cardSpawnZedRare)
		--print("Cards Spawning")
	end
	
end

Events.OnInitGlobalModData.Add(TikitownItemsDistribution.onInitGlobalModData)