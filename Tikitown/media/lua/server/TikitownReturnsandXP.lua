require("recipecode");
require "TimedActions/ISBaseTimedAction"

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

function Recipe.OnCreate.ConvertToLSTikitorch(items, result, player)
	for i=1,items:size() do
		local item = items:get(i-1)
		result:setUsedDelta(ZombRand(100)/100);
		result:setCondition(item:getCondition());
		result:setFavorite(item:isFavorite());
		player:setSecondaryHandItem(result);
		break
	end
end

function Recipe.OnCreate.ConvertToWPTikitorch(items, result, player)
	for i=1,items:size() do
		local item = items:get(i-1)
		result:setUsedDelta(item:getUsedDelta());
		result:setCondition(item:getCondition());
		result:setFavorite(item:isFavorite());
		player:setSecondaryHandItem(result);
		break
	end
end

function Recipe.OnCreate.LightTikitorch(items, result, player)
    for i=0,items:size() do
        local item = items:get(i)       
		result:setUsedDelta(item:getUsedDelta());
		result:setCondition(item:getCondition());
		result:setFavorite(item:isFavorite());
		if player:getPrimaryHandItem() == player:getSecondaryHandItem() then
			player:setPrimaryHandItem(nil)
		end
		player:setSecondaryHandItem(result);
		result:setActivated(true); --ensure the candle emits light upon creation
    end
end

function Recipe.OnCreate.ExtinguishTikitorch(items, result, player)
    for i=0,items:size() do 
        local item = items:get(i)
		result:setUsedDelta(item:getUsedDelta());
		result:setCondition(item:getCondition());
		result:setFavorite(item:isFavorite());
    end
end

function Recipe.OnCreate.OpenTTBoxLg(items, result, player)
	for i=1,items:size() do
		local baseitem = ZombRand(25)
		local perkitem1 = ZombRand(20)
		local perkitem2 = ZombRand(30)
		local perkitem3 = ZombRand(40)
		local perkitem4 = ZombRand(50)
		local item = items:get(i-1)
		
		if(baseitem == 1) then
			player:getInventory():AddItem("Base.GuitarAcoustic", 1)
		elseif(baseitem == 2) then
			player:getInventory():AddItem("Base.BarBell", 1)
		elseif(baseitem == 3) then
			player:getInventory():AddItem("Base.BaseballBat", 1)
		elseif(baseitem == 4) then
			player:getInventory():AddItem("Base.Crowbar", 1)
		elseif(baseitem == 5) then
			player:getInventory():AddItem("Base.GuitarElectricBassBlack", 1)
		elseif(baseitem == 6) then
			player:getInventory():AddItem("Base.GuitarElectricBassBlue", 1)
		elseif(baseitem == 7) then
			player:getInventory():AddItem("Base.GuitarElectricBassRed", 1)
		elseif(baseitem == 8) then
			player:getInventory():AddItem("Base.GuitarElectricBlack", 1)
		elseif(baseitem == 9) then
			player:getInventory():AddItem("Base.GuitarElectricBlue", 1)
		elseif(baseitem == 10) then
			player:getInventory():AddItem("Base.GuitarElectricRed", 1)
		elseif(baseitem == 11) then
			player:getInventory():AddItem("Base.FishingRod", 1)
		elseif(baseitem == 12) then
			player:getInventory():AddItem("Base.Golfclub", 1)
		elseif(baseitem == 13) then
			player:getInventory():AddItem("Base.HockeyStick", 1)
		elseif(baseitem == 14) then
			player:getInventory():AddItem("Base.Keytar", 1)
		elseif(baseitem == 15) then
			player:getInventory():AddItem("Base.LaCrosseStick", 1)
		elseif(baseitem == 16) then
			player:getInventory():AddItem("Base.EngineParts", ZombRand(5)+3)
		elseif(baseitem == 17) then
			player:getInventory():AddItem("Base.Bag_BigHikingBag", 1)
		elseif(baseitem == 18) then
			player:getInventory():AddItem("Base.Bag_NormalHikingBag", 1)
		elseif(baseitem == 19) then
			player:getInventory():AddItem("Base.PickAxe", 1)
		elseif(baseitem == 20) then
			player:getInventory():AddItem("Base.CarBatteryCharger", 1)
		elseif(baseitem == 21) then
			player:getInventory():AddItem("Base.GardenSaw", 1)
		elseif(baseitem == 22) then
			player:getInventory():AddItem("Base.WoodAxe", 1)
		elseif(baseitem == 23) then
			player:getInventory():AddItem("Base.Pot", 1)
		elseif(baseitem == 24) then
			player:getInventory():AddItem("Base.Shovel", 1)
		elseif(baseitem == 25) then
			player:getInventory():AddItem("Base.Shovel2", 1)			
		--break
		end
		
		if(perkitem1 == 1) then
			player:getInventory():AddItem("Base.ClubHammer", 1)
		elseif(perkitem1 == 2) then
			player:getInventory():AddItem("Base.Jack", 1)
		elseif(perkitem1 == 3) then
			player:getInventory():AddItem("Base.LugWrench", 1)
		elseif(perkitem1 == 4) then
			player:getInventory():AddItem("Base.Screwdriver", 1)
		elseif(perkitem1 == 5) then
			player:getInventory():AddItem("Base.AlarmClock2", 1)
		elseif(perkitem1 == 6) then
			player:getInventory():AddItem("Base.Bleach", 1)
		elseif(perkitem1 == 7) then
			player:getInventory():AddItem("Base.DishCloth", 1)
		elseif(perkitem1 == 8) then
			player:getInventory():AddItem("Base.Sponge", 1)
		elseif(perkitem1 == 9) then
			player:getInventory():AddItem("Base.Soap", 1)
		elseif(perkitem1 == 10) then
			player:getInventory():AddItem("Base.BluePen", 1)
		end
		
		if(perkitem2 == 1) then
			player:getInventory():AddItem("Base.Cornflour", 1)
		elseif(perkitem2 == 2) then
			player:getInventory():AddItem("Base.Cereal", 1)
		elseif(perkitem2 == 3) then
			player:getInventory():AddItem("Base.Chocolate", 1)
		elseif(perkitem2 == 4) then
			player:getInventory():AddItem("Base.Ramen", 1)
		elseif(perkitem2 == 5) then
			player:getInventory():AddItem("Base.CandyFruitSlices", 1)
		elseif(perkitem2 == 6) then
			player:getInventory():AddItem("Base.CandyCorn", 1)
		elseif(perkitem2 == 7) then
			player:getInventory():AddItem("Base.CandyPackage", 1)
		elseif(perkitem2 == 8) then
			player:getInventory():AddItem("Base.CookieChocolateChip", 1)
		elseif(perkitem2 == 9) then
			player:getInventory():AddItem("Base.DriedBlackBeans", 1)
		elseif(perkitem2 == 10) then
			player:getInventory():AddItem("Base.DriedChickpeas", 1)
		end
		
		if(perkitem3 == 1) then
			player:getInventory():AddItem("Base.Bandage", 1)
		elseif(perkitem3 == 2) then
			player:getInventory():AddItem("Base.BookCarpentry1", 1)
		elseif(perkitem3 == 3) then
			player:getInventory():AddItem("Base.BookCarpentry2", 1)
		elseif(perkitem3 == 4) then
			player:getInventory():AddItem("Base.BookCarpentry3", 1)
		elseif(perkitem3 == 5) then
			player:getInventory():AddItem("Base.BookCarpentry4", 1)
		elseif(perkitem3 == 6) then
			player:getInventory():AddItem("Base.BookCarpentry5", 1)
		elseif(perkitem3 == 7) then
			player:getInventory():AddItem("Base.BookCooking1", 1)
		elseif(perkitem3 == 8) then
			player:getInventory():AddItem("Base.BookCooking2", 1)
		elseif(perkitem3 == 9) then
			player:getInventory():AddItem("Base.BookCooking3", 1)
		elseif(perkitem3 == 10) then
			player:getInventory():AddItem("Base.BookCooking4", 1)
		end
		
		if(perkitem4 == 1) then
			player:getInventory():AddItem("Base.HottieZ", 1)
		elseif(perkitem4 == 2) then
			player:getInventory():AddItem("Base.MagazineWordsearch1", 1)
		elseif(perkitem4 == 3) then
			player:getInventory():AddItem("Base.MagazineWordsearch2", 1)
		elseif(perkitem4 == 4) then
			player:getInventory():AddItem("Base.Journal", 1)
		elseif(perkitem4 == 5) then
			player:getInventory():AddItem("Base.Battery", 1)
		elseif(perkitem4 == 6) then
			player:getInventory():AddItem("Base.Sledgehammer", 1)
		elseif(perkitem4 == 7) then
			player:getInventory():AddItem("Base.Earbuds", 1)
		elseif(perkitem4 == 8) then
			player:getInventory():AddItem("Base.Headphones", 1)
		elseif(perkitem4 == 9) then
			player:getInventory():AddItem("Base.HomeAlarm", 1)
		elseif(perkitem4 == 10) then
			player:getInventory():AddItem("Base.Speaker", 1)
		end
	end
end


function Recipe.OnCreate.OpenTTBoxMed(items, result, player)
	for i=1,items:size() do
		local baseitem = ZombRand(25)
		local perkitem1 = ZombRand(20)
		local perkitem2 = ZombRand(40)
		local item = items:get(i-1)
		
		if(baseitem == 1) then
			player:getInventory():AddItem("Base.EngineParts", ZombRand(5)+1)
		elseif(baseitem == 2) then
			player:getInventory():AddItem("Base.ModernBrake1", 1)
		elseif(baseitem == 3) then
			player:getInventory():AddItem("Base.ModernBrake2", 1)
		elseif(baseitem == 4) then
			player:getInventory():AddItem("Base.ModernBrake3", 1)
		elseif(baseitem == 5) then
			player:getInventory():AddItem("Base.ModernSuspension1", 1)
		elseif(baseitem == 6) then
			player:getInventory():AddItem("Base.ModernSuspension2", 1)
		elseif(baseitem == 7) then
			player:getInventory():AddItem("Base.ModernSuspension3", 1)
		elseif(baseitem == 8) then
			player:getInventory():AddItem("Base.CordlessPhone", 1)
		elseif(baseitem == 9) then
			player:getInventory():AddItem("Base.BorisBadger", 1)
		elseif(baseitem == 10) then
			player:getInventory():AddItem("Base.JacquesBeaver", 1)
		elseif(baseitem == 11) then
			player:getInventory():AddItem("Base.BackgammonBoard", 1)
		elseif(baseitem == 12) then
			player:getInventory():AddItem("Base.Bell", 1)
		elseif(baseitem == 13) then
			player:getInventory():AddItem("Base.CheckerBoard", 1)
		elseif(baseitem == 14) then
			player:getInventory():AddItem("Base.Torch", 1)
		elseif(baseitem == 15) then
			player:getInventory():AddItem("Base.BallPeenHammer", 1)
		elseif(baseitem == 16) then
			player:getInventory():AddItem("Base.ClubHammer", 1)
		elseif(baseitem == 17) then
			player:getInventory():AddItem("Base.HandAxe", 1)
		elseif(baseitem == 18) then
			player:getInventory():AddItem("Base.Charcoal", 1)
		elseif(baseitem == 19) then
			player:getInventory():AddItem("Base.Wrench", 1)
		elseif(baseitem == 20) then
			player:getInventory():AddItem("Base.CampingTentKit", 1)
		elseif(baseitem == 21) then
			player:getInventory():AddItem("Base.WalkieTalkie3", 1)
		elseif(baseitem == 22) then
			player:getInventory():AddItem("Base.WalkieTalkie2", 1)
		elseif(baseitem == 23) then
			player:getInventory():AddItem("Base.WhiskeyFull", 1)
		elseif(baseitem == 24) then
			player:getInventory():AddItem("Base.Coldpack", 1)
		elseif(baseitem == 25) then
			player:getInventory():AddItem("Base.CameraExpensive", 1)			
		--break
		end
		
		if(perkitem1 == 1) then
			player:getInventory():AddItem("Base.Aluminum", 1)
		elseif(perkitem1 == 2) then
			player:getInventory():AddItem("Base.BarbedWire", 1)
		elseif(perkitem1 == 3) then
			player:getInventory():AddItem("Base.NailsBox", 1)
		elseif(perkitem1 == 4) then
			player:getInventory():AddItem("Base.PaperclipBox", 1)
		elseif(perkitem1 == 5) then
			player:getInventory():AddItem("Base.Screws", 1)
		elseif(perkitem1 == 6) then
			player:getInventory():AddItem("Base.Handle", 1)
		elseif(perkitem1 == 7) then
			player:getInventory():AddItem("Base.Tarp", 1)
		elseif(perkitem1 == 8) then
			player:getInventory():AddItem("Base.WeldingRods", 1)
		elseif(perkitem1 == 9) then
			player:getInventory():AddItem("Base.HottieZ", 1)
		elseif(perkitem1 == 10) then
			player:getInventory():AddItem("Base.Book", 1)
		end
		
		if(perkitem2 == 1) then
			player:getInventory():AddItem("Base.FluffyfootBunny", 1)
		elseif(perkitem2 == 2) then
			player:getInventory():AddItem("Base.BorisBadger", 1)
		elseif(perkitem2 == 3) then
			player:getInventory():AddItem("Base.JacquesBeaver", 1)
		elseif(perkitem2 == 4) then
			player:getInventory():AddItem("Base.FreddyFox", 1)
		elseif(perkitem2 == 5) then
			player:getInventory():AddItem("Base.PancakeHedgehog", 1)
		elseif(perkitem2 == 6) then
			player:getInventory():AddItem("Base.MoleyMole", 1)
		elseif(perkitem2 == 7) then
			player:getInventory():AddItem("Base.Spiffo", 1)
		elseif(perkitem2 == 8) then
			player:getInventory():AddItem("Base.SpiffoBig", 1)
		elseif(perkitem2 == 9) then
			player:getInventory():AddItem("Base.FurbertSquirrel", 1)
		elseif(perkitem2 == 10) then
			player:getInventory():AddItem("Base.VideoGame", 1)
		end
	end
end


function Recipe.OnCreate.OpenTTBoxSm(items, result, player)
	for i=1,items:size() do
		local baseitem = ZombRand(25)
		local perkitem1 = ZombRand(50)
		local perkitem2 = ZombRand(50)
		local perkitem3 = ZombRand(50)
		local item = items:get(i-1)
		
		if(baseitem == 1) then
			player:getInventory():AddItem("Base.BookCarpentry1", 1)
		elseif(baseitem == 2) then
			player:getInventory():AddItem("Base.BookCarpentry2", 1)
		elseif(baseitem == 3) then
			player:getInventory():AddItem("Base.BookCarpentry3", 1)
		elseif(baseitem == 4) then
			player:getInventory():AddItem("Base.BookCarpentry4", 1)
		elseif(baseitem == 5) then
			player:getInventory():AddItem("Base.BookCarpentry5", 1)
		elseif(baseitem == 6) then
			player:getInventory():AddItem("Base.BookCooking1", 1)
		elseif(baseitem == 7) then
			player:getInventory():AddItem("Base.BookCooking2", 1)
		elseif(baseitem == 8) then
			player:getInventory():AddItem("Base.BookCooking3", 1)
		elseif(baseitem == 9) then
			player:getInventory():AddItem("Base.BookCooking4", 1)
		elseif(baseitem == 10) then
			player:getInventory():AddItem("Base.BookCooking5", 1)
		elseif(baseitem == 11) then
			player:getInventory():AddItem("Base.BookElectrician1", 1)
		elseif(baseitem == 12) then
			player:getInventory():AddItem("Base.BookElectrician2", 1)
		elseif(baseitem == 13) then
			player:getInventory():AddItem("Base.BookElectrician3", 1)
		elseif(baseitem == 14) then
			player:getInventory():AddItem("Base.BookElectrician4", 1)
		elseif(baseitem == 15) then
			player:getInventory():AddItem("Base.BookElectrician5", 1)
		elseif(baseitem == 16) then
			player:getInventory():AddItem("Base.BookFarming1", 1)
		elseif(baseitem == 17) then
			player:getInventory():AddItem("Base.BookFarming2", 1)
		elseif(baseitem == 18) then
			player:getInventory():AddItem("Base.BookFarming3", 1)
		elseif(baseitem == 19) then
			player:getInventory():AddItem("Base.BookFarming4", 1)
		elseif(baseitem == 20) then
			player:getInventory():AddItem("Base.BookFarming5", 1)
		elseif(baseitem == 21) then
			player:getInventory():AddItem("Base.BookFirstAid1", 1)
		elseif(baseitem == 22) then
			player:getInventory():AddItem("Base.BookFirstAid2", 1)
		elseif(baseitem == 23) then
			player:getInventory():AddItem("Base.BookFirstAid3", 1)
		elseif(baseitem == 24) then
			player:getInventory():AddItem("Base.BookFirstAid4", 1)
		elseif(baseitem == 25) then
			player:getInventory():AddItem("Base.BookFirstAid5", 1)			
		--break
		end
		
		if(perkitem1 == 1) then
			player:getInventory():AddItem("Base.BookFishing1", 1)
		elseif(perkitem1 == 2) then
			player:getInventory():AddItem("Base.BookFishing2", 1)
		elseif(perkitem1 == 3) then
			player:getInventory():AddItem("Base.BookFishing3", 1)
		elseif(perkitem1 == 4) then
			player:getInventory():AddItem("Base.BookFishing4", 1)
		elseif(perkitem1 == 5) then
			player:getInventory():AddItem("Base.BookFishing5", 1)
		elseif(perkitem1 == 6) then
			player:getInventory():AddItem("Base.BookForaging1", 1)
		elseif(perkitem1 == 7) then
			player:getInventory():AddItem("Base.BookForaging2", 1)
		elseif(perkitem1 == 8) then
			player:getInventory():AddItem("Base.BookForaging3", 1)
		elseif(perkitem1 == 9) then
			player:getInventory():AddItem("Base.BookForaging4", 1)
		elseif(perkitem1 == 10) then
			player:getInventory():AddItem("Base.BookForaging5", 1)
		end
		
		if(perkitem2 == 1) then
			player:getInventory():AddItem("Base.BookMechanic1", 1)
		elseif(perkitem2 == 2) then
			player:getInventory():AddItem("Base.BookMechanic2", 1)
		elseif(perkitem2 == 3) then
			player:getInventory():AddItem("Base.BookMechanic3", 1)
		elseif(perkitem2 == 4) then
			player:getInventory():AddItem("Base.BookMechanic4", 1)
		elseif(perkitem2 == 5) then
			player:getInventory():AddItem("Base.BookMechanic5", 1)
		elseif(perkitem2 == 6) then
			player:getInventory():AddItem("Base.BookMetalWelding1", 1)
		elseif(perkitem2 == 7) then
			player:getInventory():AddItem("Base.BookMetalWelding2", 1)
		elseif(perkitem2 == 8) then
			player:getInventory():AddItem("Base.BookMetalWelding3", 1)
		elseif(perkitem2 == 9) then
			player:getInventory():AddItem("Base.BookMetalWelding4", 1)
		elseif(perkitem2 == 10) then
			player:getInventory():AddItem("Base.BookMetalWelding5", 1)
		end
		
		if(perkitem3 == 1) then
			player:getInventory():AddItem("Base.BookTailoring1", 1)
		elseif(perkitem3 == 2) then
			player:getInventory():AddItem("Base.BookTailoring2", 1)
		elseif(perkitem3 == 3) then
			player:getInventory():AddItem("Base.BookTailoring3", 1)
		elseif(perkitem3 == 4) then
			player:getInventory():AddItem("Base.BookTailoring4", 1)
		elseif(perkitem3 == 5) then
			player:getInventory():AddItem("Base.BookTailoring5", 1)
		elseif(perkitem3 == 6) then
			player:getInventory():AddItem("Base.BookTrapping1", 1)
		elseif(perkitem3 == 7) then
			player:getInventory():AddItem("Base.BookTrapping2", 1)
		elseif(perkitem3 == 8) then
			player:getInventory():AddItem("Base.BookTrapping3", 1)
		elseif(perkitem3 == 9) then
			player:getInventory():AddItem("Base.BookTrapping4", 1)
		elseif(perkitem3 == 10) then
			player:getInventory():AddItem("Base.BookTrapping5", 1)
		end
	end
end

function Recipe.OnCreate.GenerateStashLoot(items, result, player)
	isSpawned = false
	local rand = ZombRand(3) + 1
	print(rand)
	if(rand == 1) then
		argX = 6862
		argY = 7182
		argZ = 0
		player:getInventory():AddItem("Tikitown.Tikitown_quest1_map1")
	elseif(rand == 2) then
		argX = 6324
		argY = 5319
		argZ = 0
		player:getInventory():AddItem("Tikitown.Tikitown_quest1_map2")
	elseif(rand == 3) then
		argX = 7782
		argY = 7399
		argZ = 0
		player:getInventory():AddItem("Tikitown.Tikitown_quest1_map3")
	elseif(rand == 4) then
		argX = 11837
		argY = 7010
		argZ = 0
		player:getInventory():AddItem("Tikitown.Tikitown_quest1_map4")
	end
	
	for i=0, items:size() do
		local item = items:get(i)
		local cell = getWorld():getCell()
		local sq = cell:getGridSquare(argX, argY, argZ)
		
		if sq ~= nil then
			sq:AddWorldInventoryItem("Tikitown.Titanium_Baseball_Bat", 0, 0, 0)
			isSpawned = true
		else
			Events.EveryHours.Add(TikitownIsCellLoaded)
		end
		break
	end
end

function TikitownIsCellLoaded()
	print("Cell isn't active - calling the check every hour")
	print("TARGET COORDS")
	print(argX)
	print(argY)
	print(argZ)
	local cell = getWorld():getCell()
	local sq = cell:getGridSquare(argX, argY, argZ)
	
	if sq ~= nill then
		print("Cell is loaded - adding them item and removing from call")
		Events.EveryHours.Remove(TikitownIsCellLoaded)
		sq:AddWorldInventoryItem("Tikitown.Titanium_Baseball_Bat", 0, 0, 0)
		isSpawned = true
	end
end
	
			
TikitownDismantleBattery = Recipe.OnGiveXP.DismantleLaserTagBattery
TikitownConvertBattery = Recipe.OnGiveXP.ConvertBatteries