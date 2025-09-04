do
    AttackPower = setmetatable({}, {})
    local ap = getmetatable(AttackPower)
    ap.__index = ap

    local ap_ability = FourCC('APWR')

    function ap:get_modifiers_const(u)
        return Utils:table_merge(Modifiers:get_all_modifiers(u,'attpow_const'),Buffs:get_all_modifiers(u,'attpow_const'))
    end

    function ap:get_modifiers_factor(u)
        return Utils:table_merge(Modifiers:get_all_modifiers(u,'attpow_factor'),Buffs:get_all_modifiers(u,'attpow_factor'))
    end

    function ap:recalculate(u)
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

    function ap:set(u,v)
        if GetUnitAbilityLevel(u, ap_ability) == 0 then UnitAddAbility(u, ap_ability) end
        BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(u, ap_ability), ABILITY_ILF_STRENGTH_BONUS_ISTR, 0, v - self:get_default(u))
        IncUnitAbilityLevel(u, ap_ability)
        DecUnitAbilityLevel(u, ap_ability)
    end

    function ap:get(u)
        return GetHeroStr(u, false) + BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, ap_ability), ABILITY_ILF_STRENGTH_BONUS_ISTR, 0)
    end

    function ap:get_default(u)
        return GetHeroStr(u, false)
    end
end