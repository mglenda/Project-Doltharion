do
    AI = setmetatable({}, {})
    local ai = getmetatable(AI)
    ai.__index = ai

    local cast_trg = CreateTrigger()
    local attack_trg = CreateTrigger()

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

    function ai:start()
        self:start_casting()
        self:start_attacking()
    end

    function ai:stop()
        self:stop_casting()
        self:stop_attacking()
    end

    function ai:get_target(u,aoe)
        local g = aoe and Units:get_area_alive_enemy(GetUnitX(u),GetUnitY(u),aoe,GetOwningPlayer(u)) or Units:get_alive_enemy(GetOwningPlayer(u))
        local t,p = {},999
        for _,uu in ipairs(g) do
            local up = Data:get_unit_data(GetUnitTypeId(uu)).p or GetUnitLevel(uu)
            if up < p then 
                p,t = up,{}
            end
            if up == p then table.insert(t,uu) end
        end
        if #t == 0 then 
            return nil,p
        else
            local rn = GetRandomInt(1, #t)
            return t[rn],p
        end
    end

    function ai:attack_action()
        local u,v = GetAttacker(),GetAttackedUnitBJ()
        local t,p = AI:get_target(u)
        local p_t = Data:get_unit_data(GetUnitTypeId(u)).p_tolerance or 0
        local vp = Data:get_unit_data(GetUnitTypeId(v)).p or GetUnitLevel(v)
        if t and math.abs(p - vp) > p_t then 
            IssueTargetOrderById(u, String2OrderIdBJ('attack'), t) 
        end
    end

    function ai:cast_action()
        for u,_ in pairs(Units:get_all()) do
            if IsUnitAliveBJ(u) and u ~= Hero:get() then
                local abs = ObjectUtils:getUnitAbilities(u,true)
                if not(Units:is_casting(u)) then
                    for _,v in ipairs(abs) do
                        if Abilities:is_ability_available(u,FourCC(v.ac)) then
                            if Utils:type(Data:get_ability_class(FourCC(v.ac)).ai_cast) == 'function' and Data:get_ability_class(FourCC(v.ac)):ai_cast(u) then break end
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
        TriggerAddAction(attack_trg, AI.attack_action)
        DisableTrigger(attack_trg)
    end)
end 