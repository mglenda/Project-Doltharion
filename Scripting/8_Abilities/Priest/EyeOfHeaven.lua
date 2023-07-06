do
    EyeOfHeaven = setmetatable({}, {})
    local eoh = getmetatable(EyeOfHeaven)
    eoh.__index = eoh

    local a_code = 'A009'
    local trg = CreateTrigger()
    local period,period_a = 0.05,0.3
    local tbl = {}

    function eoh:get_a_code()
        return FourCC(a_code)
    end

    function eoh:get_s_color()
        return BlzConvertColor(255, 0, 0, 0)
    end

    function eoh:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function eoh:on_cast()
        local aoe = BlzGetAbilityRealLevelField(BlzGetUnitAbility(GetTriggerUnit(), GetSpellAbilityId()), ABILITY_RLF_AREA_OF_EFFECT, 0)
        local x,y = Units:get_cast_point_x(GetTriggerUnit()),Units:get_cast_point_y(GetTriggerUnit())
        local e = AddSpecialEffect('war3mapImported\\Life High.mdl', x, y)
        BlzSetSpecialEffectScale(e, 10.0)
        BlzSetSpecialEffectZ(e, 180.0)
        table.insert(tbl,{aoe=aoe,x=x,y=y,c=GetTriggerUnit(),e=e,l_units={},d=12.0,p=period_a})
        EnableTrigger(trg)
    end

    function eoh:refresh()
        if #tbl > 0 then 
            for i=#tbl,1,-1 do
                EyeOfHeaven:refresh_lightings(i)
                if tbl[i].d > 0 then 
                    if tbl[i].p > 0 then
                        tbl[i].p = tbl[i].p - period
                    else
                        for _,u in ipairs(Units:get_area_alive_ally(tbl[i].x,tbl[i].y,tbl[i].aoe,GetOwningPlayer(tbl[i].c))) do
                            if not(Utils:get_key_by_value(tbl[i].l_units,'u',u)) then
                                table.insert(tbl[i].l_units,{u=u,c=16})
                            end
                        end
                        tbl[i].p = period_a
                    end
                    tbl[i].d = tbl[i].d - period
                else
                    for _,v in ipairs(tbl[i].l_units) do
                        if v.l then DestroyLightning(v.l) end
                    end
                    DestroyEffect(tbl[i].e)
                    table.remove(tbl,i)
                end
            end
        else
            DisableTrigger(trg)
        end
    end

    function eoh:refresh_lightings(j)
        for i=#tbl[j].l_units,1,-1 do
            local u = tbl[j].l_units[i].u
            if Utils:get_unit_distance(tbl[j].x,tbl[j].y,u) > tbl[j].aoe then
                if tbl[j].l_units[i].l then DestroyLightning(tbl[j].l_units[i].l) end
                table.remove(tbl[j].l_units,i)
            else
                if tbl[j].l_units[i].c >= 16 then
                    if tbl[j].l_units[i].l then DestroyLightning(tbl[j].l_units[i].l) end
                    tbl[j].l_units[i].l = AddLightningEx('HWSB', true, tbl[j].x, tbl[j].y, BlzGetLocalSpecialEffectZ(tbl[j].e) - 15, GetUnitX(u), GetUnitY(u), Utils:get_unit_z(u) + 30)
                    tbl[j].l_units[i].c = 0
                else
                    if tbl[j].l_units[i].l then MoveLightningEx(tbl[j].l_units[i].l, true, tbl[j].x, tbl[j].y, BlzGetLocalSpecialEffectZ(tbl[j].e) - 15, GetUnitX(u), GetUnitY(u), Utils:get_unit_z(u) + 30)  end
                    tbl[j].l_units[i].c = tbl[j].l_units[i].c + 1
                end
            end
        end
    end

    OnInit.map(function()
        Data:register_ability_class(EyeOfHeaven:get_a_code(),EyeOfHeaven)

        TriggerRegisterTimerEventPeriodic(trg, period)
        TriggerAddAction(trg, EyeOfHeaven.refresh)
    end)
end