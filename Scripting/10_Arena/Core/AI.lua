do
    AI = setmetatable({}, {})
    local ai = getmetatable(AI)
    ai.__index = ai

    local cast_trg = CreateTrigger()
    local attack_trg = CreateTrigger()
    local damage_trg = CreateTrigger()
    local smart_order = 851971

    function ai:start_casting()
        EnableTrigger(cast_trg)
    end

    function ai:stop_casting()
        DisableTrigger(cast_trg)
    end

    function ai:start_attacking()
        EnableTrigger(attack_trg)
    end

    function ai:stop_attacking()
        DisableTrigger(attack_trg)
    end

    function ai:start_damaging()
        EnableTrigger(damage_trg)
    end

    function ai:stop_damaging()
        DisableTrigger(damage_trg)
    end

    function ai:start()
        self:start_casting()
        self:start_attacking()
        self:start_damaging()
    end

    function ai:stop()
        self:stop_casting()
        self:stop_attacking()
        self:stop_damaging()
    end

    function ai:get_target(u,aoe)
        local g,m_p = Units:get_ai_target(u,aoe)
        m_p = m_p + (Data:get_unit_data(GetUnitTypeId(u)).p_tolerance or 0)
        local t = {}
        for _,uu in ipairs(g) do
            local up = Data:get_unit_data(GetUnitTypeId(uu)).p or GetUnitLevel(uu)
            if up <= m_p then 
                table.insert(t,uu)
            end
        end
        if #t == 0 then 
            return nil,m_p
        else
            local rn = GetRandomInt(1, #t)
            return t[rn],m_p
        end
    end

    function ai:damaging_action()
        local s,t = GetEventDamageSource(),BlzGetEventDamageTarget()
        if IsUnitAliveBJ(s) and s ~= Hero:get() and not(IsUnitPaused(s)) then
            local abs = ObjectUtils:get_unit_abilities_with_priority(s)
            if not(Units:is_casting(s)) and not(Units:is_ordered(s)) then
                for _,a_code in ipairs(abs) do
                    if Abilities:is_ability_available(s,FourCC(a_code)) then
                        local o = Utils:type(Data:get_ability_class(FourCC(a_code)).on_ai_damaging) == 'function' and Data:get_ability_class(FourCC(a_code)):on_ai_damaging(s) or nil
                        if o then 
                            Units:register_order(s,o)
                            break 
                        end
                    end
                end
            end
        end
        if IsUnitAliveBJ(t) and t ~= Hero:get() then
            local abs = ObjectUtils:get_unit_abilities_with_priority(t)
            if not(Units:is_casting(t)) and not(Units:is_ordered(t)) and not(IsUnitPaused(t)) then
                for _,v in ipairs(abs) do
                    if Abilities:is_ability_available(t,FourCC(a_code)) then
                        local o = Utils:type(Data:get_ability_class(FourCC(a_code)).on_ai_damaged) == 'function' and Data:get_ability_class(FourCC(a_code)):on_ai_damaged(t) or nil
                        if o then 
                            Units:register_order(t,o)
                            break 
                        end
                    end
                end
            end
        end
    end

    function ai:attack_action()
        if GetTriggerEventId() == EVENT_PLAYER_UNIT_ATTACKED or GetIssuedOrderId() == smart_order then 
            local u,v = GetTriggerEventId() == EVENT_PLAYER_UNIT_ATTACKED and GetAttacker() or GetOrderedUnit(),GetTriggerEventId() == EVENT_PLAYER_UNIT_ATTACKED and GetAttackedUnitBJ() or nil
            if u ~= Hero:get() and (not(v) or v ~= Hero:get()) then
                local t,p = AI:get_target(u)
                if v and t then 
                    local vp = Data:get_unit_data(GetUnitTypeId(v)).p or GetUnitLevel(v)
                    if vp <= p then 
                        t = v
                    end
                end
                IssueTargetOrderById(u, String2OrderIdBJ('attack'), t) 
            end
        end
    end
    
    function ai:cast_action()
        for u,_ in pairs(Units:get_all()) do
            if IsUnitAliveBJ(u) and u ~= Hero:get() and not(IsUnitPaused(u)) then
                if not(Units:is_casting(u)) and not(Units:is_ordered(u)) then
                    local abs = ObjectUtils:get_unit_abilities_with_priority(u)
                    for _,v in ipairs(abs) do
                        if Abilities:is_ability_available(u,FourCC(a_code)) then
                            local o = Utils:type(Data:get_ability_class(FourCC(a_code)).ai_cast) == 'function' and Data:get_ability_class(FourCC(a_code)):ai_cast(u) or nil
                            if o then 
                                Units:register_order(u,o)
                                break 
                            end
                        end
                    end
                end
            end
        end
    end

    OnInit.final(function()
        TriggerAddAction(cast_trg, AI.cast_action)
        TriggerRegisterTimerEventPeriodic(cast_trg, 0.5)
        DisableTrigger(cast_trg)

        TriggerRegisterAnyUnitEventBJ(attack_trg, EVENT_PLAYER_UNIT_ATTACKED)
        TriggerRegisterAnyUnitEventBJ(attack_trg, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
        TriggerAddAction(attack_trg, AI.attack_action)
        DisableTrigger(attack_trg)

        TriggerRegisterAnyUnitEventBJ(damage_trg, EVENT_PLAYER_UNIT_DAMAGING)
        TriggerAddAction(damage_trg, AI.damaging_action)
        DisableTrigger(damage_trg)
    end)
end 