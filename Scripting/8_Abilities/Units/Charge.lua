do
    Charge = setmetatable({}, {})
    local ch = getmetatable(Charge)
    ch.__index = ch

    local a_code = 'A002'

    local trg = CreateTrigger()
    local units = {}

    function ch:get_a_code()
        return FourCC(a_code)
    end

    function ch:get_s_color()
        return BlzConvertColor(255, 0, 0, 0)
    end

    function ch:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function ch:on_cast()
        local u = GetTriggerUnit()
        local x,y = Units:get_cast_point_x(u),Units:get_cast_point_y(u)
        units[u] = {x=x,y=y,g={}}
        SetUnitPathing(u, false)
        SetUnitFacing(u, Utils:get_angle_between_points(GetUnitX(u),GetUnitY(u),x,y))
        EnableTrigger(trg)
    end

    function ch:on_end()
        SetUnitAnimationByIndex(GetTriggerUnit(), Data:get_unit_data(GetUnitTypeId(GetTriggerUnit())).a_w or 0)
    end 

    function ch:period()
        local c = 0
        for u,t in pairs(units) do
            local x,y = Utils:GetUnitXY(u)
            local rad = Utils:get_rad_between_points(x,y,t.x,t.y)
            SetUnitFacing(u, rad * bj_RADTODEG)
            x,y = Utils:move_xy(x,y,16.0,rad)
            if Utils:get_distance(x,y,t.x,t.y) <= 20.0 then
                units[u] = nil
                SetUnitPathing(u, true)
                ResetUnitAnimation(u)
            else
                for _,un in ipairs(Units:get_area_alive_enemy(x,y,75.0,GetOwningPlayer(u))) do
                    if not(Utils:itable_contains(units[u].g,un)) then
                        table.insert(units[u].g,un)
                        DamageEngine:damage_unit(u,un,AttackDamage:get(u) * 2.5,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_DEMOLITION,FourCC(a_code))
                        DestroyEffect(AddSpecialEffectTarget('Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodFootman.mdl', un, 'chest'))
                    end
                end
                Utils:set_unit_xy(u,x,y)
                DestroyEffect(AddSpecialEffect('Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl', x, y))
            end
            c = c + 1
        end
        if c == 0 then DisableTrigger(trg) end
    end

    OnInit.map(function()
        Data:register_ability_class(Charge:get_a_code(),Charge)
        TriggerRegisterTimerEventPeriodic(trg, 0.02)
        TriggerAddAction(trg, Charge.period)
        DisableTrigger(trg)
    end)
end