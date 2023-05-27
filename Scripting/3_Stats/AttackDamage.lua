do
    AttackDamage = setmetatable({}, {})
    local ad = getmetatable(AttackDamage)
    ad.__index = ad

    local ad_ability = FourCC('AATK')

    function ad:get_modifiers_const(u)
        return Buffs:get_all_modifiers(u,'attdmg_const')
    end

    function ad:get_modifiers_factor(u)
        return Buffs:get_all_modifiers(u,'attdmg_factor')
    end

    function ad:recalculate(u)
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

    function ad:set(u,v)
        if GetUnitAbilityLevel(u, ad_ability) == 0 then UnitAddAbility(u, ad_ability) end
        BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(u, ad_ability), ABILITY_ILF_ATTACK_BONUS, 0, v - self:get_default(u))
        IncUnitAbilityLevel(u, ad_ability)
        DecUnitAbilityLevel(u, ad_ability)
    end

    function ad:get(u)
        return self:get_default(u) + BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, ad_ability), ABILITY_ILF_ATTACK_BONUS, 0)
    end

    function ad:get_default(u)
        return BlzGetUnitWeaponIntegerField(u, UNIT_WEAPON_IF_ATTACK_DAMAGE_BASE, 0)
    end
end