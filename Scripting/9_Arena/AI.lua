do
    AI = setmetatable({}, {})
    local ai = getmetatable(AI)
    ai.__index = ai

    local cast_trg = CreateTrigger()

    function ai:start_casting()
        EnableTrigger(cast_trg)
    end

    function ai:stop_casting()
        DisableTrigger(cast_trg)
    end

    function ai:start()
        self:start_casting()
    end

    function ai:stop()
        self:stop_casting()
    end

    function ai:cast_action()
        for u,_ in pairs(Units:get_all()) do
            if IsUnitAliveBJ(u) and u ~= Hero:get() then
                local abs = ObjectUtils:getUnitAbilities(u,true)
                for _,v in ipairs(abs) do
                    if Abilities:is_ability_available(u,FourCC(v.ac)) then
                        if Utils:type(Data:get_ability_class(FourCC(v.ac)).ai_cast) == 'function' and Data:get_ability_class(FourCC(v.ac)):ai_cast(u) then break end
                    end
                end
            end
        end
    end

    OnInit.final(function()
        TriggerAddAction(cast_trg, AI.cast_action)
        TriggerRegisterTimerEventPeriodic(cast_trg, 1.0)
        DisableTrigger(cast_trg)
    end)
end 