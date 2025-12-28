function ProximaInjection(food, character, player)
	--local bodyDamage = player:getBodyDamage();
	--print("Taking Medicine")
	--print(food)
	--print(character)
	
	local itemType = food:getFullType()
	local playerObj = getSpecificPlayer(0)
	local bodyDamage = playerObj:getBodyDamage()
	
	--Infection Reset
	if itemType == "Tikitown.ImmunoStasis3" then
		--print("Taking suppressant")
		if bodyDamage:isInfected() then
			--bodyDamage:setInfected(false);
			bodyDamage:setInfectionMortalityDuration(-1);
			bodyDamage:setInfectionTime(-1);
			bodyDamage:setInfectionLevel(0);
			--local bodyParts = bodyDamage:getBodyParts();
			--for i=bodyParts:size()-1, 0, -1  do
			--	local bodyPart = bodyParts:get(i);
			--	bodyPart:SetInfected(false);
		end
	end
	
	--Heal
	if itemType == "Tikitown.NeuroCline7R" then
		--print("Regeneration Stim Detected")
		bodyDamage:AddGeneralHealth(170)
	end
	
	if itemType == "Tikitown.Endurase6B" then
		--print("Endurance Stim Detected")
		--bodyDamage:setFatigue(0)
		playerObj:getStats():setEndurance(1)
		local parts = bodyDamage:getBodyParts()
        for i = 0, parts:size() - 1 do
            local bp = parts:get(i)
            if bp.setStiffness then bp:setStiffness(0) end
            if bp.setAdditionalPain then bp:setAdditionalPain(0) end
            -- Optional: wipe lingering achy flags if present in your build
            if bp.setOldWoundPain then bp:setOldWoundPain(0) end
        end
	end
end