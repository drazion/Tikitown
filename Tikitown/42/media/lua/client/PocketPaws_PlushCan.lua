require "TimedActions/ISBaseTimedAction"

PocketPaws_PlushCan = {}

PocketPaws_PlushCan.RewardItems = {
    "Tikitown.Whale",
    "Tikitown.Penguin",
    "Tikitown.Rhino",
    "Tikitown.Sheep",
	"Tikitown.Cat",
    "Tikitown.Dolphin",
    "Tikitown.Pig",
    "Tikitown.Raccoon",
	"Tikitown.Possum",
    "Tikitown.Beaver",
    "Tikitown.Elephant",   
}

-------------------------------------------------------------------
-- Context menu hook
-------------------------------------------------------------------
local function addPlushCanContextMenu(playerIndex, context, items)
    local player = getSpecificPlayer(playerIndex)
    if not player then return end

    local canItem = nil

    for _, v in ipairs(items) do
        local item = v
        if not instanceof(item, "InventoryItem") then
            item = item.items[1]
        end

        if item and item:getFullType() == "Tikitown.PlushCanSurprise" then
            canItem = item
            break
        end
    end

    if not canItem then return end

    context:addOption(
        getText("ContextMenu_OpenPlushCan"),
        canItem,
        PocketPaws_PlushCan.onOpenPlushCan,
        player
    )
end

function PocketPaws_PlushCan.onOpenPlushCan(canItem, player)
    -- queue our timed action
    ISTimedActionQueue.add(ISOpenPlushCan:new(player, canItem, 80))
end

Events.OnFillInventoryObjectContextMenu.Add(addPlushCanContextMenu)
