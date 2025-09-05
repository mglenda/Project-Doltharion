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

    function p:get_challengers()
        return Player(2)
    end

    function p:get_passive()
        return Player(PLAYER_NEUTRAL_PASSIVE)
    end

    function p:get_hostile()
        return Player(PLAYER_NEUTRAL_AGGRESSIVE)
    end

    OnInit.final(function()
        SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, false, Player(0))
        SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, false, Player(1))
        SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, false, Player(2))
    end)
end