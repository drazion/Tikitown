require "Items/ProceduralDistributions"

TikitownItemsDistribution = TikitownItemsDistribution or {}

function TikitownItemsDistribution.onInitGlobalModData(isNewGame)
	
	local cardSpawnBaseCommon = SandboxVars.Tikitown.CollectionBaseballCommon
	local cardSpawnBaseRare = SandboxVars.Tikitown.CollectionBaseballRare
	
	local cardSpawnZedCommon = SandboxVars.Tikitown.CollectionBaseballZombieCommon
	local cardSpawnZedRare = SandboxVars.Tikitown.CollectionBaseballZombieRare
	
	local torchSpawnRate = SandboxVars.Tikitown.TikitorchSpawnRate
	local boxSpawnRate = 50
		
	--Cards Spawns
	if SandboxVars.Tikitown.CollectionBaseball then
		TikitownItemsDistribution.TikitownCardSpawn(cardSpawnBaseCommon, cardSpawnBaseRare, cardSpawnZedCommon, cardSpawnZedRare)
		--print("Cards Spawning")
	end
	
	if SandboxVars.Tikitown.Tikitorch then
		TikitownItemsDistribution.TikitownTorchSpawn(torchSpawnRate)
		print("Torches Spawning")
	end
	
	if SandboxVars.Tikitown.PostOfficeOverride then
		TikitownItemsDistribution.TikitownBoxSpawn(boxSpawnRate)
		print("Boxes Spawning")
	end
end

Events.OnInitGlobalModData.Add(TikitownItemsDistribution.onInitGlobalModData)