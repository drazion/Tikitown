require("recipecode");
require "TimedActions/ISBaseTimedAction"

--Old B41 Recipes
--Converted VCR and Lasertag Gun Recipes to B42
--Need to handle map creation still
local isSpawned = false
local argX = 0
local argY = 0
local argZ = 0
local TreasureLocations = {}

function Recipe.OnGiveXP.DismantleLaserTagGun(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.Electricity, 15+(player:getPerkLevel(Perks.Electricity)*2));
end

function Recipe.OnGiveXP.DismantleLaserTagBattery(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.Electricity, 1)
end

function Recipe.OnGiveXP.ConvertLaserTagBattery(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.Electricity, 5)
end

function Recipe.OnCreate.DismantleLaserTagGun(items, result, player)
	for i=1,items:size() do
		local rdm = ZombRand(5)
		local item = items:get(i-1)
		if item:getType() == "Tikitown.LaserTag_Gun" then
			player:getInventory():AddItem("Base.Screws", rdm)
		end
		break
	end
end

function Recipe.OnCreate.DismantleDrazVCR(items, result, player)
	for i=1,items:size() do
		local rdm = ZombRand(5)
		local item = items:get(i-1)
		player:getInventory():AddItem("Base.Screws", rdm)
		break
	end
end

function Recipe.OnCreate.ConvertLaserTagBattery(items, result, player)
	for i=1,items:size() do
		local item = items:get(i-1)
		if item:getType() == "Base.Battery" then
			player:getInventory():AddItem("Tikitown.TikitownBattery", 20)
		end
		break
	end
end

function Recipe.OnCreate.DismantleLaserTagBattery(items, result, player)
	for i=1,items:size() do
		local item = items:get(i-1)
		if item:getType() == "Base.TikitownBattery" then
			player:getInventory():AddItem("Base.Battery", 1)
		end
		break
	end
end
	

function Recipe.OnCreate.DismantleLaserTagCartridge(items, result, player)
	for i=1,items:size() do
		local rdm = ZombRand(5)
		local item = items:get(i-1)
		player:getInventory():AddItem("Base.Screws", rdm)
		break
	end
end

function Recipe.OnCreate.DismantleLaserLaserTagHarness(items, result, player)
	for i=1,items:size() do
		local rdm = ZombRand(5)
		local rdm2 = ZombRand(5)
		local item = items:get(i-1)
		player:getInventory():AddItem("Base.Battery", rdm2)
		break
	end
end


CraftRecipeCode = CraftRecipeCode or {};
CraftRecipeCode.GenerateTreasure = {}

function CraftRecipeCode.GenerateTreasure.GenerateLgBoxLoot(craftRecipeData, character)
	print("Opening a Large Box")
	local result = craftRecipeData:getAllCreatedItems():get(0)
	--print(result)
	local baseitem = nil
	local perkitem1 = nil
	local perkitem2 = nil
	local perkitem3 = nil
	local perkitem4 = nil
	
	local baseitmRoll = ZombRand(25)
	local perkitmRoll1 = ZombRand(20)
	local perkitmRoll2 = ZombRand(30)
	local perkitmRoll3 = ZombRand(40)
	local perkitmRoll4 = ZombRand(50)
	
	if(baseitmRoll == 1) then
		baseitem = instanceItem("Base.GuitarAcoustic")
	elseif(baseitmRoll == 2) then
		baseitem = instanceItem("Base.BarBell")
	elseif(baseitmRoll == 3) then
		baseitem = instanceItem("Base.BaseballBat")
	elseif(baseitmRoll == 4) then
		baseitem = instanceItem("Base.Crowbar")
	elseif(baseitmRoll == 5) then
		baseitem = instanceItem("Base.BaseballBat_Metal")
	elseif(baseitmRoll == 6) then
		baseitem = instanceItem("Base.Sword")
	elseif(baseitmRoll == 7) then
		baseitem = instanceItem("Base.AntibioticsBox")
	elseif(baseitmRoll == 8) then
		baseitem = instanceItem("Base.AdhesiveBandageBo")
	elseif(baseitmRoll == 9) then
		baseitem = instanceItem("Base.BatteryBox")
	elseif(baseitmRoll == 10) then
		baseitem = instanceItem("Base.GuitarElectricRed")
	elseif(baseitmRoll == 11) then
		baseitem = instanceItem("Base.FishingRod")
	elseif(baseitmRoll == 12) then
		baseitem = instanceItem("Base.Golfclub")
	elseif(baseitmRoll == 13) then
		baseitem = instanceItem("Base.HockeyStick")
	elseif(baseitmRoll == 14) then
		baseitem = instanceItem("Base.Keytar")
	elseif(baseitmRoll == 15) then
		baseitem = instanceItem("Base.LaCrosseStick")
	elseif(baseitmRoll == 16) then
		baseitem = instanceItem("Base.Axe_Old")
	elseif(baseitmRoll == 17) then
		baseitem = instanceItem("Base.Bag_BigHikingBag")
	elseif(baseitmRoll == 18) then
		baseitem = instanceItem("Base.Bag_NormalHikingBag")
	elseif(baseitmRoll == 19) then
		baseitem = instanceItem("Base.PickAxe")
	elseif(baseitmRoll == 20) then
		pbaseitem = instanceItem("Base.CarBatteryCharger")
	elseif(baseitmRoll == 21) then
		baseitem = instanceItem("Base.GardenSaw")
	elseif(baseitmRoll == 22) then
		baseitem = instanceItem("Base.WoodAxe")
	elseif(baseitmRoll == 23) then
		baseitem = instanceItem("Base.Pot")
	elseif(baseitmRoll == 24) then
		baseitem = instanceItem("Base.Shovel")
	elseif(baseitmRoll == 25) then
		baseitem = instanceItem("Base.Shovel2")			
	end
	character:getInventory():AddItem(baseitem)
	
	--print(perkitmRoll1)
	--Check if we get perk item from first pool
	if(perkitmRoll1 == 1) then
		perkitem1 = instanceItem("Base.ClubHammer")
	elseif(perkitmRoll1 == 2) then
		perkitem1 = instanceItem("Base.Jack")
	elseif(perkitmRoll1 == 3) then
		perkitem1 = instanceItem("Base.LugWrench")
	elseif(perkitmRoll1 == 4) then
		perkitem1 = instanceItem("Base.Screwdriver")
	elseif(perkitmRoll1 == 5) then
		perkitem1 = instanceItem("Base.AlarmClock2")
	elseif(perkitmRoll1 == 6) then
		perkitem1 = instanceItem("Base.Bleach")
	elseif(perkitmRoll1 == 7) then
		perkitem1 = instanceItem("Base.DishCloth")
	elseif(perkitmRoll1 == 8) then
		perkitem1 = instanceItem("Base.Sponge")
	elseif(perkitmRoll1 == 9) then
		perkitem1 = instanceItem("Base.Soap")
	elseif(perkitmRoll1 == 10) then
		perkitem1 = instanceItem("Base.BluePen")
	end
	
	if perkitem1 ~= nil then
		character:getInventory():AddItem(perkitem1)
	end
	
	if(perkitmRoll2 == 1) then
		perkitem2 = instanceItem("Base.Cornflour")
	elseif(perkitmRoll2 == 2) then
		perkitem2 = instanceItem("Base.Cereal")
	elseif(perkitmRoll2 == 3) then
		perkitem2 = instanceItem("Base.Chocolate")
	elseif(perkitmRoll2 == 4) then
		perkitem2 = instanceItem("Base.Ramen")
	elseif(perkitmRoll2 == 5) then
		perkitem2 = instanceItem("Base.CandyFruitSlices")
	elseif(perkitmRoll2 == 6) then
		perkitem2 = instanceItem("Base.CandyCorn")
	elseif(perkitmRoll2 == 7) then
		perkitem2 = instanceItem("Base.CandyPackage")
	elseif(perkitmRoll2 == 8) then
		perkitem2 = instanceItem("Base.CookieChocolateChip")
	elseif(perkitmRoll2 == 9) then
		perkitem2 = instanceItem("Base.DriedBlackBeans")
	elseif(perkitmRoll2 == 10) then
		perkitem2 = instanceItem("Base.DriedChickpeas")
	end
	
	if perkitem2 ~= nil then
		character:getInventory():AddItem(perkitem2)
	end
	
	if(perkitmRoll3 == 1) then
		perkitem3 = instanceItem("Base.Bandage")
	elseif(perkitmRoll3 == 2) then
		perkitem3 = instanceItem("Base.BookCarpentry1")
	elseif(perkitmRoll3 == 3) then
		perkitem3 = instanceItem("Base.BookCarpentry2")
	elseif(perkitmRoll3 == 4) then
		perkitem3 = instanceItem("Base.BookCarpentry3")
	elseif(perkitmRoll3 == 5) then
		perkitem3 = instanceItem("Base.BookCarpentry4")
	elseif(perkitmRoll3 == 6) then
		perkitem3 = instanceItem("Base.BookCarpentry5")
	elseif(perkitmRoll3 == 7) then
		perkitem3 = instanceItem("Base.BookCooking1")
	elseif(perkitmRoll3 == 8) then
		perkitem3 = instanceItem("Base.BookCooking2")
	elseif(perkitmRoll3 == 9) then
		perkitem3 = instanceItem("Base.BookCooking3")
	elseif(perkitmRoll3 == 10) then
		perkitem3 = instanceItem("Base.BookCooking4")
	end
	
	if perkitem3 ~= nil then
		character:getInventory():AddItem(perkitem3)
	end
	
	if(perkitmRoll4 == 1) then
		perkitem4 = instanceItem("Base.HottieZ")
	elseif(perkitmRoll4 == 2) then
		perkitem4 = instanceItem("Base.MagazineWordsearch1")
	elseif(perkitmRoll4 == 3) then
		perkitem4 = instanceItem("Base.MagazineWordsearch2")
	elseif(perkitmRoll4 == 4) then
		perkitem4 = instanceItem("Base.Katana")
	elseif(perkitmRoll4 == 5) then
		perkitem4 = instanceItem("Base.Battery")
	elseif(perkitmRoll4 == 6) then
		perkitem4 = instanceItem("Base.Sledgehammer")
	elseif(perkitmRoll4 == 7) then
		perkitem4 = instanceItem("Base.Katana_Broken")
	elseif(perkitmRoll4 == 8) then
		perkitem4 = instanceItem("Base.Headphones")
	elseif(perkitmRoll4 == 9) then
		perkitem4 = instanceItem("Base.HomeAlarm")
	elseif(perkitmRoll4 == 10) then
		perkitem4 = instanceItem("Base.Speaker")
	end
	
	if perkitem4 ~= nil then
		character:getInventory():AddItem(perkitem4)
	end
end

function CraftRecipeCode.GenerateTreasure.GenerateMdBoxLoot(craftRecipeData, character)
	local baseitmRoll = ZombRand(25)
	local perkitmRoll1 = ZombRand(20)
	local perkitmRoll2 = ZombRand(40)
	
	local baseitem = nil
	local perkitem1 = nil
	local perkitem2 = nil

	
	if(baseitmRoll == 1) then
		baseitem = instanceItem("Base.Revolver_CapGun")
	elseif(baseitmRoll == 2) then
		baseitem = instanceItem("Base.Multitool")
	elseif(baseitmRoll == 3) then
		baseitem = instanceItem("Base.ModernBrake2")
	elseif(baseitmRoll == 4) then
		baseitem = instanceItem("Base.ModernBrake3")
	elseif(baseitmRoll == 5) then
		baseitem = instanceItem("Base.ModernSuspension1")
	elseif(baseitmRoll == 6) then
		baseitem = instanceItem("Base.ModernSuspension2")
	elseif(baseitmRoll == 7) then
		baseitem = instanceItem("Base.ModernSuspension3")
	elseif(baseitmRoll == 8) then
		baseitem = instanceItem("Base.CordlessPhone")
	elseif(baseitmRoll == 9) then
		baseitem = instanceItem("Base.BorisBadger")
	elseif(baseitmRoll == 10) then
		baseitem = instanceItem("Base.JacquesBeaver")
	elseif(baseitmRoll == 11) then
		baseitem = instanceItem("Base.BackgammonBoard")
	elseif(baseitmRoll == 12) then
		baseitem = instanceItem("Base.Bell")
	elseif(baseitmRoll == 13) then
		baseitem = instanceItem("Base.CheckerBoard")
	elseif(baseitmRoll == 14) then
		baseitem = instanceItem("Base.Torch")
	elseif(baseitmRoll == 15) then
		baseitem = instanceItem("Base.BallPeenHammer")
	elseif(baseitmRoll == 16) then
		baseitem = instanceItem("Base.ClubHammer")
	elseif(baseitmRoll == 17) then
		baseitem = instanceItem("Base.HandAxe")
	elseif(baseitmRoll == 18) then
		baseitem = instanceItem("Base.Charcoal")
	elseif(baseitmRoll == 19) then
		baseitem = instanceItem("Base.Wrench")
	elseif(baseitmRoll == 20) then
		baseitem = instanceItem("Base.CampingTentKit")
	elseif(baseitmRoll == 21) then
		baseitem = instanceItem("Base.WalkieTalkie3")
	elseif(baseitmRoll == 22) then
		baseitem = instanceItem("Base.WalkieTalkie2")
	elseif(baseitmRoll == 23) then
		baseitem = instanceItem("Base.WhiskeyFull")
	elseif(baseitmRoll == 24) then
		baseitem = instanceItem("Base.Coldpack")
	elseif(baseitmRoll == 25) then
		baseitem = instanceItem("Base.CameraExpensive")			
	--break
	end
	character:getInventory():AddItem(baseitem)
	
	if(perkitmRoll1 == 1) then
		perkitem1 = instanceItem("Base.MetalworkingChisel", 1)
	elseif(perkitmRoll1 == 2) then
		perkitem1 = instanceItem("Base.BarbedWire", 1)
	elseif(perkitmRoll1 == 3) then
		perkitem1 = instanceItem("Base.NailsBox", 1)
	elseif(perkitmRoll1 == 4) then
		pperkitem1 = instanceItem("Base.PaperclipBox", 1)
	elseif(perkitmRoll1 == 5) then
		perkitem1 = instanceItem("Base.Screws", 1)
	elseif(perkitmRoll1 == 6) then
		perkitem1 = instanceItem("Base.Handle", 1)
	elseif(perkitmRoll1 == 7) then
		perkitem1 = instanceItem("Base.Tarp", 1)
	elseif(perkitmRoll1 == 8) then
		perkitem1 = instanceItem("Base.WeldingRods", 1)
	elseif(perkitmRoll1 == 9) then
		perkitem1 = instanceItem("Base.ShortBat", 1)
	elseif(perkitmRoll1 == 10) then
		perkitem1 = instanceItem("Base.MetalworkingPunch", 1)
	end
	if perkitem1 ~= nil then
		character:getInventory():AddItem(perkitem1)
	end
		
	if(perkitmRoll2 == 1) then
		perkitem2 = instanceItem("Base.FluffyfootBunny")
	elseif(perkitmRoll2 == 2) then
		perkitem2 = instanceItem("Base.TrapCage")
	elseif(perkitmRoll2 == 3) then
		perkitem2 = instanceItem("Base.TrapBox")
	elseif(perkitmRoll2 == 4) then
		perkitem2 = instanceItem("Base.SleepingBag_RedPlaid_Packed")
	elseif(perkitmRoll2 == 5) then
		perkitem2 = instanceItem("Base.SleepingBag_Green_Packed")
	elseif(perkitmRoll2 == 6) then
		perkitem2 = instanceItem("Base.TentYellow_Packed")
	elseif(perkitmRoll2 == 7) then
		perkitem2 = instanceItem("Base.CampingTentKit2_Packed")
	elseif(perkitmRoll2 == 8) then
		perkitem2 = instanceItem("Base.SpiffoBig")
	elseif(perkitmRoll2 == 9) then
		perkitem2 = instanceItem("Base.WaterPurificationTablets")
	elseif(perkitmRoll2 == 10) then
		perkitem2 = instanceItem("Base.VideoGame")
	end
	if perkitem2 ~= nil then
		character:getInventory():AddItem(perkitem2)
	end
end

function CraftRecipeCode.GenerateTreasure.GenerateSmBoxLoot(craftRecipeData, character)
	local baseitmRoll = ZombRand(25)
	local perkitmRoll1 = ZombRand(20)
	local perkitmRoll2 = ZombRand(40)
	local perkitmRoll3 = ZombRand(40)
	
	local baseitem = nil
	local perkitem1 = nil
	local perkitem2 = nil
	
	if(baseitmRoll == 1) then
		baseitem = instanceItem("Base.BookCarpentry1")
	elseif(baseitmRoll == 2) then
		baseitem = instanceItem("Base.BookCarpentry2")
	elseif(baseitmRoll == 3) then
		baseitem = instanceItem("Base.BookCarpentry3")
	elseif(baseitmRoll == 4) then
		baseitem = instanceItem("Base.BookCarpentry4")
	elseif(baseitmRoll == 5) then
		baseitem = instanceItem("Base.BookCarpentry5")
	elseif(baseitmRoll == 6) then
		baseitem = instanceItem("Base.BookCooking1")
	elseif(baseitmRoll == 7) then
		baseitem = instanceItem("Base.BookCooking2")
	elseif(baseitmRoll == 8) then
		baseitem = instanceItem("Base.BookCooking3")
	elseif(baseitmRoll == 9) then
		baseitem = instanceItem("Base.BookCooking4")
	elseif(baseitmRoll == 10) then
		baseitem = instanceItem("Base.BookCooking5")
	elseif(baseitmRoll == 11) then
		baseitem = instanceItem("Base.BookElectrician1")
	elseif(baseitmRoll == 12) then
		baseitem = instanceItem("Base.BookElectrician2")
	elseif(baseitmRoll == 13) then
		baseitem = instanceItem("Base.BookElectrician3")
	elseif(baseitmRoll == 14) then
		baseitem = instanceItem("Base.BookElectrician4")
	elseif(baseitmRoll == 15) then
		baseitem = instanceItem("Base.BookElectrician5")
	elseif(baseitmRoll == 16) then
		baseitem = instanceItem("Base.BookFarming1")
	elseif(baseitmRoll == 17) then
		baseitem = instanceItem("Base.BookFarming2")
	elseif(baseitmRoll == 18) then
		baseitem = instanceItem("Base.BookFarming3")
	elseif(baseitmRoll == 19) then
		baseitem = instanceItem("Base.BookFarming4")
	elseif(baseitmRoll == 20) then
		baseitem = instanceItem("Base.BookFarming5")
	elseif(baseitmRoll == 21) then
		baseitem = instanceItem("Base.BookFirstAid1")
	elseif(baseitmRoll == 22) then
		baseitem = instanceItem("Base.BookFirstAid2")
	elseif(baseitmRoll == 23) then
		baseitem = instanceItem("Base.BookFirstAid3")
	elseif(baseitmRoll == 24) then
		baseitem = instanceItem("Base.BookFirstAid4")
	elseif(baseitmRoll == 25) then
		baseitem = instanceItem("Base.BookFirstAid5")			
	--break
	end
	
	if(perkitmRoll1 == 1) then
		perkitem1 = instanceItem("Base.BookFishing1")
	elseif(perkitmRoll1 == 2) then
		perkitem1 = instanceItem("Base.BookFishing2")
	elseif(perkitmRoll1 == 3) then
		perkitem1 = instanceItem("Base.BookFishing3")
	elseif(perkitmRoll1 == 4) then
		perkitem1 = instanceItem("Base.BookFishing4")
	elseif(perkitmRoll1 == 5) then
		perkitem1 = instanceItem("Base.BookFishing5")
	elseif(perkitmRoll1 == 6) then
		perkitem1 = instanceItem("Base.BookForaging1")
	elseif(perkitmRoll1 == 7) then
		perkitem1 = instanceItem("Base.BookForaging2")
	elseif(perkitmRoll1 == 8) then
		perkitem1 = instanceItem("Base.BookForaging3")
	elseif(perkitmRoll1 == 9) then
		perkitem1 = instanceItem("Base.BookForaging4")
	elseif(perkitmRoll1 == 10) then
		perkitem1 = instanceItem("Base.BookForaging5")
	end
	if perkitem1 ~= nil then
		character:getInventory():AddItem(perkitem1)
	end
	
	if(perkitmRoll2 == 1) then
		perkitem2 = instanceItem("Base.BookMechanic1")
	elseif(perkitmRoll2 == 2) then
		perkitem2 = instanceItem("Base.BookMechanic2")
	elseif(perkitmRoll2 == 3) then
		perkitem2 = instanceItem("Base.BookMechanic3")
	elseif(perkitmRoll2 == 4) then
		perkitem2 = instanceItem("Base.BookMechanic4")
	elseif(perkitmRoll2 == 5) then
		perkitem2 = instanceItem("Base.BookMechanic5")
	elseif(perkitmRoll2 == 6) then
		perkitem2 = instanceItem("Base.BookMetalWelding1")
	elseif(perkitmRoll2 == 7) then
		perkitem2 = instanceItem("Base.BookMetalWelding2")
	elseif(perkitmRoll2 == 8) then
		perkitem2 = instanceItem("Base.BookMetalWelding3")
	elseif(perkitmRoll2 == 9) then
		perkitem2 = instanceItem("Base.BookMetalWelding4")
	elseif(perkitmRoll2 == 10) then
		perkitem2 = instanceItem("Base.BookMetalWelding5")
	end
	if perkitem2 ~= nil then
		character:getInventory():AddItem(perkitem2)
	end
	
	if(perkitmRoll3 == 1) then
		perkitem3 = instanceItem("Base.BookTailoring1")
	elseif(perkitmRoll3 == 2) then
		perkitem3 = instanceItem("Base.BookTailoring2")
	elseif(perkitmRoll3 == 3) then
		perkitem3 = instanceItem("Base.BookTailoring3")
	elseif(perkitmRoll3 == 4) then
		perkitem3 = instanceItem("Base.BookTailoring4")
	elseif(perkitmRoll3 == 5) then
		perkitem3 = instanceItem("Base.BookTailoring5")
	elseif(perkitmRoll3 == 6) then
		perkitem3 = instanceItem("Base.BookTrapping1")
	elseif(perkitmRoll3 == 7) then
		perkitem3 = instanceItem("Base.BookTrapping2")
	elseif(perkitmRoll3 == 8) then
		perkitem3 = instanceItem("Base.BookTrapping3")
	elseif(perkitmRoll3 == 9) then
		perkitem3 = instanceItem("Base.BookTrapping4")
	elseif(perkitmRoll3 == 10) then
		perkitem3 = instanceItem("Base.BookTrapping5")
	end
	if perkitem3 ~= nil then
		character:getInventory():AddItem(perkitem3)
	end
end

local TikitownTraceCards = {}

TikitownTraceCards.x = 7782
TikitownTraceCards.y = 7399
TikitownTraceCards.z = 0
TikitownTraceCards.item = "Tikitown.Titanium_Baseball_Bat"
TikitownTraceCards.eventRegistered = false

local function Tikitown_SpawnDuffelWithBat(square)
    if not square then return end

    local worldBag = square:AddWorldInventoryItem("Base.Bag_DuffelBag", 0.5, 0.5, 0)
    if not worldBag then return end

    local bagItem = worldBag
    if worldBag.getItem ~= nil then
        bagItem = worldBag:getItem()
    end
    if not bagItem then return end

    local bagContainer = nil
    if bagItem.getItemContainer ~= nil then
        bagContainer = bagItem:getItemContainer()
    elseif bagItem.getInventory ~= nil then
        bagContainer = bagItem:getInventory()
    end
    if not bagContainer then return end

    bagContainer:AddItem(TikitownTraceCards.item)
end

function TikitownTraceCards.ensureEventRegistered()
    if TikitownTraceCards.eventRegistered then return end
    Events.LoadGridsquare.Add(TikitownTraceCards.onLoadGridsquare)
    TikitownTraceCards.eventRegistered = true
end

function TikitownTraceCards.removeEvent()
    if not TikitownTraceCards.eventRegistered then return end
    Events.LoadGridsquare.Remove(TikitownTraceCards.onLoadGridsquare)
    TikitownTraceCards.eventRegistered = false
end

function TikitownTraceCards.onLoadGridsquare(square)
    if not square then return end

    local player = getPlayer()
    if not player then return end

    local md = player:getModData()
    if not md.TikitownTraceCardsDone then return end
    if md.TikitownTraceCardsBatSpawned then
        TikitownTraceCards.removeEvent()
        return
    end

    if square:getX() ~= TikitownTraceCards.x then return end
    if square:getY() ~= TikitownTraceCards.y then return end
    if square:getZ() ~= TikitownTraceCards.z then return end

    Tikitown_SpawnDuffelWithBat(square)
    md.TikitownTraceCardsBatSpawned = true
    TikitownTraceCards.removeEvent()
end

local function TikitownTraceCards_OnGameStart()
    local player = getPlayer()
    if not player then return end

    local md = player:getModData()
    if md.TikitownTraceCardsDone and not md.TikitownTraceCardsBatSpawned then
        TikitownTraceCards.ensureEventRegistered()
    end
end

Events.OnGameStart.Add(TikitownTraceCards_OnGameStart)

function CraftRecipeCode.GenerateTreasure.TraceCardsOnBox(_craftProcessor)
    local player = getPlayer()
    if not player then return end

    local md = player:getModData()

    if md.TikitownTraceCardsBatSpawned then
        return
    end

    md.TikitownTraceCardsDone = true

    local cell = getWorld():getCell()
    local sq = cell and cell:getGridSquare(TikitownTraceCards.x, TikitownTraceCards.y, TikitownTraceCards.z) or nil

    if sq then
        Tikitown_SpawnDuffelWithBat(sq)
        md.TikitownTraceCardsBatSpawned = true
    else
        TikitownTraceCards.ensureEventRegistered()
    end
end

TikitownDismantleBattery = Recipe.OnGiveXP.DismantleLaserTagBattery
TikitownConvertBattery = Recipe.OnGiveXP.ConvertBatteries