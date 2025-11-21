TikitownPower = TikitownPower or {}

function TikitownPower.say(text)
    local player = getSpecificPlayer(0)
    if player then
        player:Say(text)
    else
        print("[TikitownPower] " .. text)
    end
end
