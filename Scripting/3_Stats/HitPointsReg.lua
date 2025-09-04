do
    HitPointsReg = setmetatable({}, {})
    local hp = getmetatable(HitPointsReg)
    hp.__index = hp

    local hp_ability = FourCC('AHPS')

    function hp:get_modifiers_const(u)
        return Utils:table_merge(Modifiers:get_all_modifiers(u,'hpreg_const'),Buffs:get_all_modifiers(u,'hpreg_const'))
    end

    function hp:get_modifiers_factor(u)
        return Utils:table_merge(Modifiers:get_all_modifiers(u,'hpreg_factor'),Buffs:get_all_modifiers(u,'hpreg_factor'))
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
        self:set(u,Utils:round(val,2))
    end

    function hp:set(u,v)
        if GetUnitAbilityLevel(u, hp_ability) == 0 then UnitAddAbility(u, hp_ability) end
        BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, hp_ability), ABILITY_RLF_AMOUNT_OF_HIT_POINTS_REGENERATED, 0, v - self:get_default(u))
        BlzSetUnitRealField(u, UNIT_RF_HIT_POINTS_REGENERATION_RATE, v)
    end

    function hp:get(u)
        return Utils:round(BlzGetUnitRealField(u, UNIT_RF_HIT_POINTS_REGENERATION_RATE),2)
    end

    function hp:get_default(u)
        return Utils:round(BlzGetUnitRealField(u, UNIT_RF_HIT_POINTS_REGENERATION_RATE) - BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, hp_ability), ABILITY_RLF_AMOUNT_OF_HIT_POINTS_REGENERATED, 0),2)
    end
end