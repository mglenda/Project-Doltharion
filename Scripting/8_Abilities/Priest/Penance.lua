do
    Penance = setmetatable({}, {})
    local p = getmetatable(Penance)
    p.__index = p

    local a_code = 'A003'
    local mtrg,ctrg = CreateTrigger(),CreateTrigger()
    local mt,ct = {},{}

    function p:get_a_code()
        return FourCC(a_code)
    end

    function p:get_s_color()
        return BlzConvertColor(255, 0, 0, 0)
    end

    function p:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function p:on_start()
        local c = GetTriggerUnit()
        local p = Utils:round(CastingTime:get(c,a_code) / BlzGetAbilityIntegerField(BlzGetUnitAbility(c, FourCC(a_code)), ABILITY_IF_MISSILE_SPEED) - 0.01,2)
        table.insert(ct, {c=c,p=p,t=GetSpellTargetUnit(),cp=0.0})
        EnableTrigger(ctrg)
    end

    function p:on_end()
        local c = GetTriggerUnit()
        for i=#ct,1,-1 do
            if ct[i].c == c then table.remove(ct,i) end
        end
    end

    function p:channeling()
        for i=#ct,1,-1 do
            if IsUnitDeadBJ(ct[i].t) then IssueImmediateOrderById(ct[i].c, String2OrderIdBJ('stop')) end
            ct[i].cp = Utils:round(ct[i].cp + 0.01,2)
            if ct[i].cp >= ct[i].p then 
                ct[i].cp = 0.0
                local mx,my = Utils:GetUnitXY(ct[i].c)
                local m = AddSpecialEffect('war3mapImported\\Penance.mdx', mx, my)
                BlzSetSpecialEffectScale(m, 1.2)
                table.insert(mt,{m=m,c=ct[i].c,t=ct[i].t,mx=mx,my=my,a=Utils:get_angle_between_points(mx,my,GetUnitX(ct[i].t),GetUnitY(ct[i].t))})
                EnableTrigger(mtrg)
            end
        end
        if #ct == 0 then DisableTrigger(ctrg) end
    end

    function p:missle_fly()
        for i = #mt,1,-1 do
            local ude = not(Units:exists(mt[i].t))
            if Utils:get_distance(BlzGetLocalSpecialEffectX(mt[i].m),BlzGetLocalSpecialEffectY(mt[i].m),GetUnitX(mt[i].t),GetUnitY(mt[i].t)) <= 30.0 or ude then 
                if not(ude) and IsUnitAliveBJ(mt[i].t) then
                    if IsUnitEnemy(mt[i].t, GetOwningPlayer(mt[i].c)) then
                        DamageEngine:damage_unit(mt[i].c,mt[i].t,SpellPower:get(mt[i].c) * 1.5,ATTACK_TYPE_MAGIC,DAMAGE_TYPE_DIVINE,FourCC(a_code))
                    else
                        Heal:unit(mt[i].c,mt[i].t,SpellPower:get(mt[i].c) * 1.5)
                    end
                end
                DestroyEffect(mt[i].m)
                table.remove(mt,i)
            else
                local r = Utils:get_rad_between_points(mt[i].mx,mt[i].my,GetUnitX(mt[i].t),GetUnitY(mt[i].t))
                mt[i].mx = Utils:move_x(mt[i].mx,14.0,r)
                mt[i].my = Utils:move_y(mt[i].my,14.0,r)
                mt[i].a = mt[i].a + 0.125
                local x = mt[i].mx + Cos(mt[i].a) * 25.0
                local y = mt[i].my + Sin(mt[i].a) * 25.0
                BlzSetSpecialEffectX(mt[i].m, x)
                BlzSetSpecialEffectY(mt[i].m, y)
                BlzSetSpecialEffectZ(mt[i].m, 75.0)
            end
        end
        if #mt == 0 then DisableTrigger(mtrg) end
    end

    OnInit.map(function()
        Data:register_ability_class(Penance:get_a_code(),Penance)
        TriggerRegisterTimerEventPeriodic(mtrg, 0.01)
        TriggerAddAction(mtrg, Penance.missle_fly)
        TriggerRegisterTimerEventPeriodic(ctrg, 0.01)
        TriggerAddAction(ctrg, Penance.channeling)
    end)
end