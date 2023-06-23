do
    Target = setmetatable({}, {})
    local target = getmetatable(Target)
    target.__index = target

    function target:setTarget(unit)
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
        Controller:registerKeyboardEvent(OSKEY_ESCAPE,Target.clearTarget)

        local trg = CreateTrigger()
        TriggerRegisterPlayerSelectionEventBJ(trg, Players:get_player(), true)
        TriggerAddAction(trg, function()
            if GetTriggerUnit() ~= Hero:get() then
                Target:setTarget(GetTriggerUnit())
                SelectUnitForPlayerSingle(Hero:get(), Players:get_player())
            end
        end)
    end)
end