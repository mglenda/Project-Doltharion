do
    Clique = setmetatable({}, {})
    local c = getmetatable(Clique)
    c.__index = c

    local key_SHIFT = ConvertOsKeyType(160) 
    local key_ALT = ConvertOsKeyType(164) 
    local key_CTRL = ConvertOsKeyType(162) 
    local mkey_SHIFT = 1
    local mkey_CTRL = 2
    local mkey_ALT = 4
    local mkey_SHIFT_CTRL = 3
    local mkey_SHIFT_ALT = 5
    local mkey_CTRL_ALT = 6
    local mkey_CTRL_ALT_SHIFT = 7
    local key = 0
    local trg = CreateTrigger()
    local c_trg = CreateTrigger()

    function c:shift()
        return mkey_SHIFT
    end

    function c:alt()
        return mkey_ALT
    end

    function c:ctrl()
        return mkey_CTRL
    end

    function c:shift_ctrl()
        return mkey_SHIFT_CTRL
    end

    function c:ctrl_alt()
        return mkey_CTRL_ALT
    end
    
    function c:shift_alt()
        return mkey_SHIFT_ALT
    end

    function c:shift_ctrl_alt()
        return mkey_CTRL_ALT_SHIFT
    end

    function c:get_key()
        return key
    end

    function c:clear_key()
        key = 0
    end

    function c:key_pressed()
        key = BlzGetTriggerPlayerMetaKey()
    end

    function c:on_click(u)
        local order,ac = AbilityController:get_clique_data(key)
        if order and not(Hero:isCasting()) and Units:exists(u) and Abilities:is_ability_available(Hero:get(),ac) then 
            CastingController:setOrder(order)
            IssueTargetOrderById(Hero:get(), order, u) 
        end
    end

    OnInit.final(function()
        for mKey = 0,7 do
            BlzTriggerRegisterPlayerKeyEvent(trg, Players:get_player(), key_SHIFT, mKey, true)
            BlzTriggerRegisterPlayerKeyEvent(trg, Players:get_player(), key_ALT, mKey, true)
            BlzTriggerRegisterPlayerKeyEvent(trg, Players:get_player(), key_CTRL, mKey, true)
        end
        TriggerAddAction(trg, Clique.key_pressed)
        for mKey = 0,7 do
            BlzTriggerRegisterPlayerKeyEvent(c_trg, Players:get_player(), key_SHIFT, mKey, false)
            BlzTriggerRegisterPlayerKeyEvent(c_trg, Players:get_player(), key_ALT, mKey, false)
            BlzTriggerRegisterPlayerKeyEvent(c_trg, Players:get_player(), key_CTRL, mKey, false)
        end
        TriggerAddAction(c_trg, Clique.clear_key)
    end)
end