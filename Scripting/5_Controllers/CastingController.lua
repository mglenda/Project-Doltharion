do
    CastingController = setmetatable({}, {})
    local cc = getmetatable(CastingController)
    cc.__index = cc

    function cc:load()
        self.trigger = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(self.trigger, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerRegisterAnyUnitEventBJ(self.trigger, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
        TriggerRegisterAnyUnitEventBJ(self.trigger, EVENT_PLAYER_UNIT_SPELL_FINISH)
        TriggerAddAction(self.trigger, self.onCast)
    end

    function cc:onCast()
        if GetTriggerEventId() == EVENT_PLAYER_UNIT_SPELL_EFFECT then
            Units:register_cast_point(GetTriggerUnit(),GetSpellTargetX(),GetSpellTargetY())
            if GetTriggerUnit() == Hero:get() then
                Hero:setCasting(CastingController:getOrder())
                CastingBar:start(Hero:get(),GetSpellAbilityId())
                UI.a_panel:setPushed(GetSpellAbilityId())
                if Utils:type(Data:get_ability_class(GetSpellAbilityId()).on_start) == 'function' then Data:get_ability_class(GetSpellAbilityId()):on_start() end
            end
        elseif GetTriggerEventId() == EVENT_PLAYER_UNIT_SPELL_ENDCAST then
            Units:clear_cast_point(GetTriggerUnit())
            if GetTriggerUnit() == Hero:get() then
                Hero:clearCasting()
                CastingBar:stop()
                UI.a_panel:setNormal(GetSpellAbilityId())
                if Utils:type(Data:get_ability_class(GetSpellAbilityId()).on_end) == 'function' then Data:get_ability_class(GetSpellAbilityId()):on_end() end
            end
        elseif GetTriggerEventId() == EVENT_PLAYER_UNIT_SPELL_FINISH then
            Abilities:start_ability_cooldown(GetTriggerUnit(),GetSpellAbilityId())
            if Utils:type(Data:get_ability_class(GetSpellAbilityId()).on_cast) == 'function' then Data:get_ability_class(GetSpellAbilityId()):on_cast() end
        end
    end
    
    function cc:setOrder(order)
        self.order = order
    end

    function cc:getOrder()
        return self.order
    end

    function cc:disable()
        if IsTriggerEnabled(self.trigger) then
            DisableTrigger(self.trigger)
        end
    end

    function cc:enable()
        if not(IsTriggerEnabled(self.trigger)) then
            EnableTrigger(self.trigger)
        end
    end
end