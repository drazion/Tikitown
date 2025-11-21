local CommonCardRate = SandboxVars.Tikitown.CollectionBaseballZombieCommon
local RareCardRate = SandboxVars.Tikitown.CollectionBaseballZombieRare
local c1 = "Tikitown.Baseball_Card_01"
local c2 = "Tikitown.Baseball_Card_02"
local c3 = "Tikitown.Baseball_Card_03"
local c4 = "Tikitown.Baseball_Card_04"
local c5 = "Tikitown.Baseball_Card_05"
local c6 = "Tikitown.Baseball_Card_06"
local c7 = "Tikitown.Baseball_Card_07"
local c8 = "Tikitown.Baseball_Card_08"
local c9 = "Tikitown.Baseball_Card_09"
local c10 = "Tikitown.Baseball_Card_10"
local r1 = "Tikitown.Baseball_Card_11"
local c11 = "Tikitown.Baseball_Card_12"
local c12 = "Tikitown.Baseball_Card_13"
local r2 = "Tikitown.Baseball_Card_14"
local c13 = "Tikitown.Baseball_Card_15"
local c14 = "Tikitown.Baseball_Card_16"
local c15 = "Tikitown.Baseball_Card_17"
local c16 = "Tikitown.Baseball_Card_18"
local c17 = "Tikitown.Baseball_Card_19"
local r3 = "Tikitown.Baseball_Card_20"
local r4 = "Tikitown.Baseball_Card_21"
local c18 = "Tikitown.Baseball_Card_22"
local c19 = "Tikitown.Baseball_Card_23"
local c20 = "Tikitown.Baseball_Card_24"
local c21 = "Tikitown.Baseball_Card_25"
local c22 = "Tikitown.Baseball_Card_26"
local c23 = "Tikitown.Baseball_Card_27"
local c24 = "Tikitown.Baseball_Card_28"
local c25 = "Tikitown.Baseball_Card_29"
local c26 = "Tikitown.Baseball_Card_30"
local c27 = "Tikitown.Baseball_Card_31"
local c28 = "Tikitown.Baseball_Card_32"
local c29 = "Tikitown.Baseball_Card_33"
local c30 = "Tikitown.Baseball_Card_34"
local c31 = "Tikitown.Baseball_Card_35"
local c21 = "Tikitown.Baseball_Card_36"


local common_cards = {
c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20, c21
}

local rare_cards = {
r1, r2, r3, r4
}

local function rollForZombieLoot(zombie)
--print("Rolling for Baseball Cards")

	local CommonCardChance = 500 -- 500/100,000 = 5/1,000 = 0.5% which is roughly 1 adv scrap every 200 zombies killed
	local RareCardChance = 100 -- 0.1% drop chance, 1 in 1000
	local spawnedCard = false
	local zombiePockets = zombie:getInventory()
	
	CommonDropChance = math.ceil(CommonCardRate * CommonCardChance)
	RareDropChance = math.ceil(RareCardRate * RareCardChance)
	
	local CardRoll = ZombRand(1000)
	
	--print("Common Roll: " .. CardRoll .. " v. " .. CommonDropChance)
	--print("Rare Roll: " .. CardRoll .. " v. " .. RareDropChance)
	
	if RareDropChance >= CardRoll then
		local rdmIdx = ZombRand(4)+1
		--print(rdmIdx)
		zombiePockets:AddItem(rare_cards[rdmIdx])
		spawnedCard = true
	end
	
	if not spawnedCard and CommonDropChance >= CardRoll then -- roll for common card
		local rdmIdx = ZombRand(20)+1
		--print(rdmIdx)
		zombiePockets:AddItem(common_cards[rdmIdx])
	end
end

local function updateSandboxValues()
	CommonCardRate = SandboxVars.Tikitown.CollectionBaseballZombieCommon
	RareCardRate = SandboxVars.Tikitown.CollectionBaseballZombieRare
end

if SandboxVars.Tikitown.CollectionBaseball then
	Events.OnZombieDead.Add(rollForZombieLoot)
	Events.OnGameStart.Add(updateSandboxValues)
end


local function removeItemCheck(table, target)
	print("Tikitown Torch Check")
	for index, value in ipairs(table) do
		if string.find(value, target) then
			table[index] = nil
			print("Index:", index, "Value:", value)
			print("Removed item at index:", index)
		end
	end
end

--if SandboxVars.Tikitown.Tikitorch then
--	Events.OnGameStart.Add(removeItemCheck(ProceduralDistributions["list"]["CrateTools"].items, "Tikitorch"))
--	Events.OnGameStart.Add(removeItemCheck(ProceduralDistributions["list"]["GigamartFarming"].items, "Tikitorch"))
--	else
--	print("Tikitorch Sandbox is true")
--end