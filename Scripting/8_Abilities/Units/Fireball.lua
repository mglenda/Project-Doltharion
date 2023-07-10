do
    Fireball = setmetatable({}, {})
    local f = getmetatable(Fireball)
    f.__index = f

    local a_code = 'A011'
    local mtrg = CreateTrigger()
    local mt = {}

    function f:get_a_code()
        return FourCC(a_code)
    end

    function f:get_a_string()
        return a_code
    end

    function f:get_s_color()
        return BlzConvertColor(255, 0, 0, 0)
    end

    function f:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function f:ai_cast(u)
        if GetUnitAbilityLevel(u, FourCC(a_code)) > 0 then
            local order = String2OrderIdBJ(BlzGetAbilityStringLevelField(BlzGetUnitAbility(u, FourCC(a_code)), ABILITY_SLF_BASE_ORDER_ID_NCL6, 0))
            local aoe = BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, FourCC(a_code)), ABILITY_RLF_CAST_RANGE, 0) 
            local t,p = AI:get_target(u,aoe)
            if t then 
                IssueTargetOrderById(u, order, t) 
                return true
            else
                return false
            end
        end
        return false
    end

    function f:on_cast()
        local c = GetSpellAbilityUnit()
        local t = Units:get_cast_target(c)
        local mx,my = Utils:GetUnitXY(c)
        local m = AddSpecialEffect('war3mapImported\\Firebolt.mdx', mx, my)
        BlzSetSpecialEffectScale(m, 1.0)
        table.insert(mt,{m=m,c=c,t=t,mx=mx,my=my,a=Utils:get_angle_between_units(c,t)})
        EnableTrigger(mtrg)
    end

    function f:missle_fly()
        for i = #mt,1,-1 do
            local ude = not(Units:exists(mt[i].t))
            if Utils:get_distance(mt[i].mx,mt[i].my,GetUnitX(mt[i].t),GetUnitY(mt[i].t)) <= 30.0 or ude then 
                if not(ude) and IsUnitAliveBJ(mt[i].t) then
                    DamageEngine:damage_unit(mt[i].c,mt[i].t,SpellPower:get(mt[i].c) * 5.0,ATTACK_TYPE_MAGIC,DAMAGE_TYPE_FIRE,FourCC(a_code))
                    Buffs:apply(mt[i].c,mt[i].t,'fireball')
                end
                DestroyEffect(mt[i].m)
                table.remove(mt,i)
            else
                local r = Utils:get_rad_between_points(mt[i].mx,mt[i].my,GetUnitX(mt[i].t),GetUnitY(mt[i].t))
                mt[i].mx = Utils:move_x(mt[i].mx,14.0,r)
                mt[i].my = Utils:move_y(mt[i].my,14.0,r)
                mt[i].a = mt[i].a + 0.1
                local x = mt[i].mx + Cos(mt[i].a) * 15.0
                local y = mt[i].my + Sin(mt[i].a) * 15.0
                BlzSetSpecialEffectX(mt[i].m, x)
                BlzSetSpecialEffectY(mt[i].m, y)
                BlzSetSpecialEffectZ(mt[i].m, 75.0)
            end
        end
        if #mt == 0 then DisableTrigger(mtrg) end
    end

    OnInit.map(function()
        Data:register_ability_class(Fireball:get_a_code(),Fireball)
        TriggerRegisterTimerEventPeriodic(mtrg, 0.01)
        TriggerAddAction(mtrg, Fireball.missle_fly)
    end)
end