do
    Target = setmetatable({}, {})
    local target = getmetatable(Target)
    target.__index = target

    function target:setTarget(unit)
        Target.unit = unit
        UI.t_panel:loadUnit(unit)
        UI.t_panel:show()
        Resistance:set(unit,50)
    end

    function target:clearTarget()
        Target.unit = nil
        UI.t_panel:hide()
    end

    function target:get()
        return Target.unit
    end

    OnInit.map(function()
        Controller:registerKeyboardEvent(OSKEY_ESCAPE,Target.clearTarget)

        local trg = CreateTrigger()
        TriggerRegisterPlayerSelectionEventBJ(trg, Hero:getPlayer(), true)
        TriggerAddAction(trg, function()
            if GetTriggerUnit() ~= Hero:get() then
                Target:setTarget(GetTriggerUnit())
                SelectUnitForPlayerSingle(Hero:get(), Hero:getPlayer())
            end
        end)
    end)
end