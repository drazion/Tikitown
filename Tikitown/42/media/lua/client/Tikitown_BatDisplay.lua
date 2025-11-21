Recipe      = Recipe or {}
Recipe.OnCreate = Recipe.OnCreate or {}

-------------------------------------------------
-- MountSpecialBat
-- Store bat condition and repair count on display
-------------------------------------------------
function Recipe.OnCreate.MountSpecialBat(items, result, player)
    local batCondition = 0
    local batRepairs   = 0

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item and item:getFullType() == "Tikitown.Titanium_Baseball_Bat" then
            batCondition = item:getCondition() or 0

            if item.getHaveBeenRepaired then
                batRepairs = item:getHaveBeenRepaired() or 0
            end
            break
        end
    end

    local md = result:getModData()
    md.TT_BatCondition   = batCondition
    md.TT_BatRepairCount = batRepairs
end

-------------------------------------------------
-- RemoveSpecialBat
-- Restore condition and repair count to new bat
-------------------------------------------------
function Recipe.OnCreate.RemoveSpecialBat(items, result, player)
    local storedCondition
    local storedRepairs

    -- Find the consumed display item and read its stored data
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item and item:getFullType() == "Tikitown.Special_Bat_Mounted" then
            local md = item:getModData()
            storedCondition = md.TT_BatCondition
            storedRepairs   = md.TT_BatRepairCount
            break
        end
    end

    -- Result here is the Titanium bat (first output in the recipe)
    if storedCondition then
        result:setCondition(storedCondition)
    end

    if storedRepairs and result.setHaveBeenRepaired then
        result:setHaveBeenRepaired(storedRepairs)
    end
end
