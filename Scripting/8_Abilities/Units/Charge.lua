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

    function ch:get_a_string()
        return a_code
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
        units[u] = units[u] or {x=x,y=y,g={}}
        units[u].tr = units[u].tr or BlzGetUnitRealField(u, UNIT_RF_TURN_RATE)
        SetUnitPathing(u, false)
        SetUnitFacing(u, Utils:get_angle_between_points(GetUnitX(u),GetUnitY(u),x,y))
        EnableTrigger(trg)
        BlzSetUnitRealField(u,UNIT_RF_TURN_RATE,0)
    end

    function ch:ai_cast(u)
        if GetUnitAbilityLevel(u, FourCC(a_code)) > 0 then
            local order = String2OrderIdBJ(BlzGetAbilityStringLevelField(BlzGetUnitAbility(u, FourCC(a_code)), ABILITY_SLF_BASE_ORDER_ID_NCL6, 0))
            local aoe = BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, FourCC(a_code)), ABILITY_RLF_CAST_RANGE, 0) 
            local dist,t = 0,{}
            for _,uu in ipairs(Units:get_area_alive_enemy(GetUnitX(u),GetUnitY(u),aoe,GetOwningPlayer(u))) do
                local d = Utils:get_units_distance(u,uu)
                if d > 200.0 then 
                    table.insert(t,{u=uu,d=d})
                end
            end
            if #t == 0 then 
                return false 
            else
                table.sort(t, function (k1, k2) return k1.d > k2.d end)
                local x,y = Utils:GetUnitXY(t[1].u)
                IssuePointOrderById(u, order, x, y)
                return true
            end
        end
        return false
    end
    
    function ch:period()
        local c = 0
        for u,t in pairs(units) do
            local x,y = Utils:GetUnitXY(u)
            local rad = Utils:get_rad_between_points(x,y,t.x,t.y)
            SetUnitFacing(u, rad * bj_RADTODEG)
            x,y = Utils:move_xy(x,y,14.0,rad)
            local ude = not(Units:exists(u))
            if Utils:get_distance(x,y,t.x,t.y) <= 50.0 or IsUnitDeadBJ(u) or ude then
                local tr = units[u].tr
                units[u] = nil
                if not(ude) then 
                    BlzSetUnitRealField(u,UNIT_RF_TURN_RATE,tr)
                    SetUnitPathing(u, true)
                    ResetUnitAnimation(u)
                    MoveSpeed:recalculate(u)
                end
            else
                SetUnitAnimationByIndex(u, Data:get_unit_data(GetUnitTypeId(u)).a_walk or 0)
                MoveSpeed:set(u,0)
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