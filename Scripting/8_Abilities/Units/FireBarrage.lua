do
    FireBarrage = setmetatable({}, {})
    local fb = getmetatable(FireBarrage)
    fb.__index = fb

    local a_code = 'A005'
    local mtrg,ctrg = CreateTrigger(),CreateTrigger()
    local mt,ct = {},{}

    function fb:get_a_code()
        return FourCC(a_code)
    end

    function fb:get_s_color()
        return BlzConvertColor(255, 0, 0, 0)
    end

    function fb:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function fb:on_start()
        local c = GetTriggerUnit()
        local p = Utils:round(CastingTime:get(c,a_code) / BlzGetAbilityIntegerField(BlzGetUnitAbility(c, FourCC(a_code)), ABILITY_IF_MISSILE_SPEED) - 0.01,2)
        table.insert(ct, {c=c,p=p,t=GetSpellTargetUnit(),cp=0.0})
        EnableTrigger(ctrg)
    end

    function fb:on_end()
        local c = GetTriggerUnit()
        for i=#ct,1,-1 do
            if ct[i].c == c then table.remove(ct,i) end
        end
    end

    function fb:channeling()
        for i=#ct,1,-1 do
            ct[i].cp = Utils:round(ct[i].cp + 0.01,2)
            if ct[i].cp >= ct[i].p then 
                ct[i].cp = 0.0
                local mx,my = Utils:GetUnitXY(ct[i].c)
                local m = AddSpecialEffect('Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl', mx, my)
                BlzSetSpecialEffectScale(m, 1.3)
                table.insert(mt,{m=m,c=ct[i].c,t=ct[i].t,mx=mx,my=my,a=Utils:get_angle_between_points(mx,my,GetUnitX(ct[i].t),GetUnitY(ct[i].t))})
                EnableTrigger(mtrg)
            end
        end
        if #ct == 0 then DisableTrigger(ctrg) end
    end

    function fb:ai_cast(u)
        if GetUnitAbilityLevel(u, FourCC(a_code)) > 0 then
            local order = String2OrderIdBJ(BlzGetAbilityStringLevelField(BlzGetUnitAbility(u, FourCC(a_code)), ABILITY_SLF_BASE_ORDER_ID_NCL6, 0))
            local aoe = BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, FourCC(a_code)), ABILITY_RLF_CAST_RANGE, 0) 
            local dist,t = 0,{}
            local p = 999
            for _,uu in ipairs(Units:get_area_alive_enemy(GetUnitX(u),GetUnitY(u),aoe,GetOwningPlayer(u))) do
                local up = GetUnitLevel(uu)
                if up < p then 
                    p,t = up,{}
                end
                if up == p then table.insert(t,uu) end
            end
            if #t == 0 then 
                return false 
            else
                local rn = GetRandomInt(1, #t)
                IssueTargetOrderById(u, order, t[rn])
                return true
            end
        end
        return false
    end

    function fb:missle_fly()
        for i = #mt,1,-1 do
            local ude = not(Units:exists(mt[i].t))
            if Utils:get_distance(mt[i].mx,mt[i].my,GetUnitX(mt[i].t),GetUnitY(mt[i].t)) <= 30.0 or ude then 
                if not(ude) and IsUnitAliveBJ(mt[i].t) then
                    DamageEngine:damage_unit(mt[i].c,mt[i].t,SpellPower:get(mt[i].c) * 1.0,ATTACK_TYPE_MAGIC,DAMAGE_TYPE_DIVINE,FourCC(a_code))
                end
                DestroyEffect(mt[i].m)
                table.remove(mt,i)
            else
                local r = Utils:get_rad_between_points(mt[i].mx,mt[i].my,GetUnitX(mt[i].t),GetUnitY(mt[i].t))
                mt[i].mx = Utils:move_x(mt[i].mx,14.0,r)
                mt[i].my = Utils:move_y(mt[i].my,14.0,r)
                mt[i].a = mt[i].a + 0.1
                local x = mt[i].mx + Cos(mt[i].a) * 45.0
                local y = mt[i].my + Sin(mt[i].a) * 45.0
                BlzSetSpecialEffectX(mt[i].m, x)
                BlzSetSpecialEffectY(mt[i].m, y)
                BlzSetSpecialEffectZ(mt[i].m, 75.0)
            end
        end
        if #mt == 0 then DisableTrigger(mtrg) end
    end

    OnInit.map(function()
        Data:register_ability_class(FireBarrage:get_a_code(),FireBarrage)
        TriggerRegisterTimerEventPeriodic(mtrg, 0.01)
        TriggerAddAction(mtrg, FireBarrage.missle_fly)
        TriggerRegisterTimerEventPeriodic(ctrg, 0.01)
        TriggerAddAction(ctrg, FireBarrage.channeling)
    end)
end