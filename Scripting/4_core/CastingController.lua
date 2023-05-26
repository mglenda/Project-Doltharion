do
    CastingController = setmetatable({}, {})
    local cc = getmetatable(CastingController)
    cc.__index = cc

    function cc:load()
        self.trigger = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(self.trigger, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerRegisterAnyUnitEventBJ(self.trigger, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
        TriggerAddAction(self.trigger, self.onCast)
    end

    function cc:onCast()
        if GetTriggerEventId() == EVENT_PLAYER_UNIT_SPELL_EFFECT then
            if GetTriggerUnit() == Hero:get() then
                Hero:setCasting(CastingController:getOrder())
                CastingBar:start(Hero:get(),GetSpellAbilityId())
                UI.a_panel:setPushed(UI.a_panel:getFrameByAbility(GetSpellAbilityId()))
            end
        elseif GetTriggerEventId() == EVENT_PLAYER_UNIT_SPELL_ENDCAST then
            if GetTriggerUnit() == Hero:get() then
                Hero:clearCasting()
                CastingBar:stop()
                UI.a_panel:setNormal(UI.a_panel:getFrameByAbility(GetSpellAbilityId()))
            end
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