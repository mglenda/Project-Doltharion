do
    Players = setmetatable({}, {})
    local p = getmetatable(Players)
    p.__index = p

    function p:get_player()
        return Player(0)
    end

    function p:get_empire()
        return Player(1)
    end

    function p:get_bandits()
        return Player(2)
    end

    function p:get_passive()
        return Player(PLAYER_NEUTRAL_PASSIVE)
    end
end