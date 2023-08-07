do
    Target = setmetatable({}, {})
    local target = getmetatable(Target)
    target.__index = target

    function target:set(unit)
        self:clear_e()
        if self.unit then Units:clear_on_death(self.unit,'target') end
        Units:register_on_death(unit,'target',function()
            Target:clear_e()
        end)
        self.e = AddSpecialEffectTarget('Abilities\\Spells\\Other\\Aneu\\AneuTarget.mdl', unit, 'overhead')
        self.unit = unit
        UI.t_panel:loadUnit(unit)
        UI.t_panel:show()
    end

    function target:clearTarget()
        self:clear_e()
        if self.unit then Units:clear_on_death(self.unit,'target') end
        self.unit = nil
        UI.t_panel:hide()
    end

    function target:clear_e()
        if self.e then 
            DestroyEffect(self.e)
            self.e = nil
        end
    end

    function target:get()
        return self.unit
    end

    OnInit.map(function()
        Controller:registerKeyboardEvent(OSKEY_ESCAPE,function()
            Target:clearTarget()
        end)

        local trg = CreateTrigger()
        TriggerRegisterPlayerSelectionEventBJ(trg, Players:get_player(), true)
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_ATTACKED)
        TriggerAddAction(trg, function()
            if GetTriggerEventId() == EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER then 
                if GetOrderedUnit() == Hero:get() and GetOrderTargetUnit() ~= Target:get() then Target:set(GetOrderTargetUnit()) end
            elseif GetTriggerEventId() == EVENT_PLAYER_UNIT_ATTACKED then 
                if GetAttacker() == Hero:get() and GetAttackedUnitBJ() ~= Target:get() then Target:set(GetAttackedUnitBJ()) end
            elseif GetTriggerUnit() ~= Hero:get() then
                if GetTriggerUnit() ~= Target:get() then Target:set(GetTriggerUnit()) end
                SelectUnitForPlayerSingle(Hero:get(), Players:get_player())
            end
        end)
    end)
end