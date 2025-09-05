do
    CastingController = setmetatable({}, {})
    local cc = getmetatable(CastingController)
    cc.__index = cc

    function cc:load()
        if self.trigger then DestroyTrigger(self.trigger) end
        self.trigger = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(self.trigger, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerRegisterAnyUnitEventBJ(self.trigger, EVENT_PLAYER_UNIT_SPELL_CAST)
        TriggerRegisterAnyUnitEventBJ(self.trigger, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
        TriggerRegisterAnyUnitEventBJ(self.trigger, EVENT_PLAYER_UNIT_SPELL_FINISH)
        TriggerAddAction(self.trigger, self.onCast)

        self.face_g = {}
        self.facing_trigger = CreateTrigger()
        TriggerRegisterTimerEventPeriodic(self.facing_trigger,0.02)
        TriggerAddAction(self.facing_trigger, function() CastingController:facing() end)
    end

    function cc:facing()
        for i,u in ipairs(self.face_g) do
            local t = Units:get_cast_target(u)
            local tx = t and GetUnitX(t) or Units:get_cast_point_x(u)
            local ty = t and GetUnitY(t) or Units:get_cast_point_y(u)
            if tx and ty then
                SetUnitFacing(u, Utils:get_angle_between_points(GetUnitX(u),GetUnitY(u),tx,ty))
            end
        end
    end

    function cc:register_facing(u)
        table.insert(self.face_g,u)
        EnableTrigger(self.facing_trigger)
    end

    function cc:clear_facing(u)
        for i=#self.face_g,1,-1 do
            if self.face_g[u] == u then table.remove(self.face_g,i) end
        end
        if #self.face_g == 0 then DisableTrigger(self.facing_trigger) end
    end
    
    function cc:onCast()
        if GetTriggerEventId() == EVENT_PLAYER_UNIT_SPELL_EFFECT then
            Units:register_cast_point(GetTriggerUnit(),GetSpellTargetX(),GetSpellTargetY())
            Units:register_cast_target(GetTriggerUnit(),GetSpellTargetUnit())
            Units:register_casting(GetTriggerUnit(),GetSpellAbilityId())
            if GetTriggerUnit() == Hero:get() then
                Hero:setCasting(CastingController:getOrder())
                CastingController:clearOrder()
                CastingBar:start(Hero:get(),GetSpellAbilityId())
                UI.a_panel:setPushed(GetSpellAbilityId())
            end
            if BlzGetAbilityIntegerField(BlzGetUnitAbility(GetTriggerUnit(), GetSpellAbilityId()), ABILITY_IF_CASTER_ATTACHMENTS) == 1 then 
                CastingController:register_facing(GetTriggerUnit()) 
            end
            if Utils:type(Data:get_ability_class(GetSpellAbilityId()).on_start) == 'function' then Data:get_ability_class(GetSpellAbilityId()):on_start() end
        elseif GetTriggerEventId() == EVENT_PLAYER_UNIT_SPELL_CAST then
            if Utils:type(Data:get_ability_class(GetSpellAbilityId()).on_begin) == 'function' then Data:get_ability_class(GetSpellAbilityId()):on_begin() end
        elseif GetTriggerEventId() == EVENT_PLAYER_UNIT_SPELL_ENDCAST then
            local d = BlzGetAbilityActivatedTooltip(GetSpellAbilityId(), GetUnitAbilityLevel(GetTriggerUnit(),GetSpellAbilityId()))
            if d ~= 'Tool tip missing!' and d:sub(7,7) == 'C' then Abilities:start_ability_cooldown(GetTriggerUnit(),GetSpellAbilityId()) end
            CastingController:clear_facing(GetTriggerUnit())
            Units:clear_cast_point(GetTriggerUnit())
            Units:clear_cast_target(GetTriggerUnit())
            Units:clear_casting(GetTriggerUnit())
            Units:clear_order(GetTriggerUnit())
            if GetTriggerUnit() == Hero:get() then
                Hero:clearCasting()
                CastingBar:stop()
                UI.a_panel:setNormal(GetSpellAbilityId())
            end
            if Utils:type(Data:get_ability_class(GetSpellAbilityId()).on_end) == 'function' then Data:get_ability_class(GetSpellAbilityId()):on_end() end
        elseif GetTriggerEventId() == EVENT_PLAYER_UNIT_SPELL_FINISH then
            local d = BlzGetAbilityActivatedTooltip(GetSpellAbilityId(), GetUnitAbilityLevel(GetTriggerUnit(),GetSpellAbilityId()))
            if d ~= 'Tool tip missing!' and d:sub(7,7) == '_' then Abilities:start_ability_cooldown(GetTriggerUnit(),GetSpellAbilityId()) end
            if Utils:type(Data:get_ability_class(GetSpellAbilityId()).on_cast) == 'function' then Data:get_ability_class(GetSpellAbilityId()):on_cast() end
        end
    end
    
    function cc:setOrder(order,target)
        self.order,self.target = order,target
    end

    function cc:clearOrder()
        self.order,self.target = nil,nil
    end

    function cc:getOrder()
        return self.order
    end

    function cc:getTarget()
        return self.target
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

    OnInit(function()
        CastingController:load()
    end)
end