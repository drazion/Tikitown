local function GoKartEnter(player)
    local vehicle = player:getVehicle()
    sendClientCommand(source, "GoKart", "PlayerEnter", {
        vehicleId = vehicle:getId()
    })
    player:SetVariable("VehicleScriptName", vehicle:getScriptName());
end

local function GoKartExit(player)
    --player:SetVariable("VehicleScriptName", "")
    sendClientCommand(source, "GoKart", "PlayerExit", {})
    player:SetVariable("VehicleScriptName", "");
end

Events.OnEnterVehicle.Add(GoKartEnter)
Events.OnExitVehicle.Add(GoKartExit)