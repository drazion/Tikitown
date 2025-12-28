if not GoKartTuning then GoKartTuning = {} end
if not GoKartTuning.Use then GoKartTuning.Use = {} end

local function info()
    local dir = getDir(MOD_ID)
end
Events.OnInitWorld.Add(info)

local function onWeaponHitCharacter(attacker, player, weapon, damage)
    local vehicle = player.getVehicle and player:getVehicle() or nil
    if (vehicle and string.find( vehicle:getScriptName(), "GoKart" )) then
        player:setAvoidDamage(true)
    end
end
Events.OnWeaponHitCharacter.Add(onWeaponHitCharacter)


function GoKartTuning.Use.Door(vehicle, part, character)
    for seat=0,vehicle:getMaxPassengers()-1 do
        if vehicle:getPassengerDoor(seat) == part then
            if not vehicle:getCharacter(seat) then
                ISVehicleMenu.onEnter(character, vehicle, seat)
                break
            end
        end
        if vehicle:getPassengerDoor2(seat) == part then
            if not vehicle:getCharacter(seat) then
                ISVehicleMenu.onEnter(character, vehicle, seat)
                break
            end
        end
    end
end