do
    StormStrike = setmetatable({}, {})
    local ss = getmetatable(StormStrike)
    ss.__index = ss

    local a_code = 'A013'
    local trg = CreateTrigger()
    local t = {}

    function ss:get_a_code()
        return FourCC(a_code)
    end

    function ss:get_a_string()
        return a_code
    end

    function ss:get_s_color()
        return BlzConvertColor(255, 0, 0, 0)
    end

    function ss:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function ss:on_start()
        local c = GetTriggerUnit()
        local ct = CastingTime:get(c,a_code)
        local af = Utils:round(CastingTime:get_default(c,a_code) / 1.3,2)
        local p = Utils:round(CastingTime:get(c,a_code) / CastingTime:get_default(c,a_code),2)
        if GetUnitTypeId(c) == AnimShaman:get_ut() then AnimationSeq:start(c,AnimShaman:seq_attack(),Utils:round(1.5*af*p,2)) end
        table.insert(t,{
            c=c
            ,pt={
                Utils:round(0.25*af*p,2)
                ,Utils:round(0.7*af*p,2)
                ,Utils:round(1.2*af*p,2)
            }
            ,t=GetSpellTargetUnit()
            ,p=0
            ,i=1
            ,aoe=BlzGetAbilityRealLevelField(BlzGetUnitAbility(c, FourCC(a_code)), ABILITY_RLF_AREA_OF_EFFECT, 0) 
            ,re=AddSpecialEffectTarget('Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl', c, 'right weapon')
        })
        EnableTrigger(trg)
    end

    function ss:destroy_le(i)
        if t[i].le then 
            DestroyEffect(t[i].le)
            t[i].le = nil
        end
    end

    function ss:destroy_re(i)
        if t[i].re then 
            DestroyEffect(t[i].re)
            t[i].re = nil
        end
    end

    function ss:hit_left_hand(i)
        self:destroy_le(i)
        self:damage(i,2)
        t[i].re = AddSpecialEffectTarget('Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl', t[i].c, 'right weapon')
        t[i].le = AddSpecialEffectTarget('Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl', t[i].c, 'left weapon')
    end

    function ss:hit_right_hand(i)
        self:destroy_re(i)
        self:damage(i,1)
        t[i].le = AddSpecialEffectTarget('Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl', t[i].c, 'left weapon')
    end

    function ss:hit_both_hands(i)
        self:destroy_le(i)
        self:destroy_re(i)
        self:damage(i,3)
    end

    function ss:damage(i,j)
        local tx,ty = Utils:GetUnitXY(t[i].t)
        DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl', tx, ty))
        if j == 3 then DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl', tx, ty)) end
        DamageEngine:reg_onCrit(t[i].c,self:get_a_code(),LightingSpheres.add,LightingSpheres,t[i].c)
        for _,u in ipairs(Units:get_area_alive_enemy(tx,ty,t[i].aoe,GetOwningPlayer(t[i].c))) do
            DamageEngine:damage_unit(t[i].c,u,AttackPower:get(t[i].c) * (2.0 + (0.75 * j)),ATTACK_TYPE_MAGIC,DAMAGE_TYPE_LIGHTNING,FourCC(a_code))
        end
    end

    function ss:channeling()
        if #t == 0 then 
            DisableTrigger(trg)
        else
            for i=#t,1,-1 do
                local j = t[i].i
                if t[i].pt[j] then 
                    if t[i].pt[j] <= t[i].p then
                        t[i].i = j + 1
                        if j == 1 then 
                            StormStrike:hit_right_hand(i)
                        elseif j == 2 then 
                            StormStrike:hit_left_hand(i)
                        elseif j == 3 then 
                            StormStrike:hit_both_hands(i)
                        end
                    end
                    t[i].p = Utils:round(t[i].p + 0.01,2)
                end
            end
        end
    end

    function ss:on_end()
        local c = GetTriggerUnit()
        for i=#t,1,-1 do
            if t[i].c == c then 
                if t[i].le then DestroyEffect(t[i].le) end
                if t[i].re then DestroyEffect(t[i].re) end
                table.remove(t,i) 
            end
        end
    end

    OnInit.map(function()
        Data:register_ability_class(StormStrike:get_a_code(),StormStrike)
        TriggerRegisterTimerEventPeriodic(trg, 0.01)
        TriggerAddAction(trg, StormStrike.channeling)
    end)
end