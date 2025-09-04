do
    HitPoints = setmetatable({}, {})
    local hp = getmetatable(HitPoints)
    hp.__index = hp

    local hp_ability = FourCC('AHIT')

    function hp:get_modifiers_const(u)
        return Utils:table_merge(Modifiers:get_all_modifiers(u,'hp_const'),Buffs:get_all_modifiers(u,'hp_const'))
    end

    function hp:get_modifiers_factor(u)
        return Utils:table_merge(Modifiers:get_all_modifiers(u,'hp_factor'),Buffs:get_all_modifiers(u,'hp_factor'))
    end

    function hp:recalculate(u)
        local val,ns,m = self:get_default(u),{},self:get_modifiers_const(u)
        for i,v in ipairs(m) do
            val = not(ns[v.n]) and val + v.v or val
            ns[v.n] = not(v.s)
        end
        m = self:get_modifiers_factor(u)
        for i,v in ipairs(m) do
            val = not(ns[v.n]) and val * v.v or val
            ns[v.n] = not(v.s)
        end
        self:set(u,Utils:round(val,0))
    end

    function hp:set(u,v)
        local r = GetUnitLifePercent(u)
        if GetUnitAbilityLevel(u, hp_ability) == 0 then UnitAddAbility(u, hp_ability) end
        BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(u, hp_ability), ABILITY_ILF_MAX_LIFE_GAINED, 0, v - self:get_default(u))
        IncUnitAbilityLevel(u, hp_ability)
        DecUnitAbilityLevel(u, hp_ability)
        BlzSetUnitMaxHP(u, v)
        SetUnitLifePercentBJ(u, r)
    end

    function hp:get(u)
        return Utils:round(BlzGetUnitMaxHP(u),0)
    end

    function hp:get_default(u)
        return Utils:round(BlzGetUnitMaxHP(u),0) - BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, hp_ability), ABILITY_ILF_MAX_LIFE_GAINED, 0)
    end
end