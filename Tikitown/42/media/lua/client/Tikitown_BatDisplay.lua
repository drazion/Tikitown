Recipe = Recipe or {}
Recipe.OnCreate = Recipe.OnCreate or {}

-------------------------------------------------
-- MountSpecialBat
-- Reads bat cond/repairs from consumed bat
-- and stores them on the mounted display's modData
-------------------------------------------------
function Recipe.OnCreate.MountSpecialBat(craftRecipeData, character)
    if not craftRecipeData then
        print("MountSpecialBat: missing craftRecipeData")
        return
    end

    local inputs  = craftRecipeData:getAllConsumedItems()
    local outputs = craftRecipeData:getAllCreatedItems()

    if not inputs or inputs:isEmpty() or not outputs or outputs:isEmpty() then
        print("MountSpecialBat: no inputs or outputs")
        return
    end

    -------------------------------------------------
    -- Find the Titanium bat in the inputs
    -------------------------------------------------
    local batCondition = 0
    local batRepairs   = 0

    for i = 0, inputs:size() - 1 do
        local item = inputs:get(i)
        if item and item:getFullType() == "Tikitown.Titanium_Baseball_Bat" then
            batCondition = item:getCondition() or 0

            if item.getHaveBeenRepaired then
                batRepairs = item:getHaveBeenRepaired() or 0
            end

            -- Debug:
            -- print("MountSpecialBat: found bat cond="..tostring(batCondition).." repairs="..tostring(batRepairs))
            break
        end
    end

    -------------------------------------------------
    -- Find the mounted display in the outputs
    -------------------------------------------------
    local display = nil

    for i = 0, outputs:size() - 1 do
        local item = outputs:get(i)
        if item and item:getFullType() == "Tikitown.Special_Bat_Mounted" then
            display = item
            break
        end
    end

    -- Fallback in case we ever change output order
    if not display then
        display = outputs:get(0)
        -- print("MountSpecialBat: fallback to first output "..display:getFullType())
    end

    local md = display:getModData()
    md.TT_BatCondition   = batCondition
    md.TT_BatRepairCount = batRepairs

    -- Debug:
    -- print(string.format("MountSpecialBat: stored cond=%d repairs=%d", batCondition, batRepairs))
end

-------------------------------------------------
-- RemoveSpecialBat
-- Reads stored cond/repairs from the mounted display
-- and applies them to the new Titanium bat output
-------------------------------------------------
function Recipe.OnCreate.RemoveSpecialBat(craftRecipeData, character)
    if not craftRecipeData then
        print("RemoveSpecialBat: missing craftRecipeData")
        return
    end

    local inputs  = craftRecipeData:getAllConsumedItems()
    local outputs = craftRecipeData:getAllCreatedItems()

    if not inputs or inputs:isEmpty() or not outputs or outputs:isEmpty() then
        print("RemoveSpecialBat: no inputs or outputs")
        return
    end

    -------------------------------------------------
    -- Find the mounted display in inputs and read modData
    -------------------------------------------------
    local storedCondition = nil
    local storedRepairs   = nil

    for i = 0, inputs:size() - 1 do
        local item = inputs:get(i)
        if item and item:getFullType() == "Tikitown.Special_Bat_Mounted" then
            local md = item:getModData()
            storedCondition = md.TT_BatCondition
            storedRepairs   = md.TT_BatRepairCount
            -- Debug:
            -- print("RemoveSpecialBat: read cond="..tostring(storedCondition).." repairs="..tostring(storedRepairs))
            break
        end
    end

    if not storedCondition and not storedRepairs then
        print("RemoveSpecialBat: no stored bat data on mounted display")
        return
    end

    -------------------------------------------------
    -- Find the new Titanium bat in outputs and apply
    -------------------------------------------------
    for i = 0, outputs:size() - 1 do
        local item = outputs:get(i)
        if item and item:getFullType() == "Tikitown.Titanium_Baseball_Bat" then
            if storedCondition then
                item:setCondition(storedCondition)
            end
            if storedRepairs and item.setHaveBeenRepaired then
                item:setHaveBeenRepaired(storedRepairs)
            end

            -- If you want to be extra safe:
            -- item:syncItemFields()

            -- Debug:
            -- print(string.format("RemoveSpecialBat: applied cond=%d repairs=%d", storedCondition or -1, storedRepairs or -1))
            break
        end
    end
end
