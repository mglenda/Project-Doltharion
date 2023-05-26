do
    AttackSpeed = setmetatable({}, {})
    local as = getmetatable(AttackSpeed)
    as.__index = as

    local as_ability = FourCC('ASPD')

    function as:get_modifiers(u)
        return Buffs:get_all_modifiers(u,'atkspeed')
    end

    function as:recalculate(u)
        local val,ns,m = 1.0,{},self:get_modifiers(u)
        for i,v in ipairs(m) do
            val = not(ns[v.n]) and val * v.v or val
            ns[v.n] = not(v.s)
        end
        self:set(u,Utils:round(val-1,2))
    end

    function as:set(u,v)
        if GetUnitAbilityLevel(u, as_ability) == 0 then UnitAddAbility(u, as_ability) end
        BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, as_ability), ABILITY_RLF_ATTACK_SPEED_INCREASE_ISX1, 0, v < 5.0 and v or 5.0)
        IncUnitAbilityLevel(u, as_ability)
        DecUnitAbilityLevel(u, as_ability)
    end

    function as:get(u)
        return BlzGetUnitWeaponRealField(u, UNIT_WEAPON_RF_ATTACK_BASE_COOLDOWN, 0) / (1 + BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, as_ability), ABILITY_RLF_ATTACK_SPEED_INCREASE_ISX1, 0))
    end

    function as:get_default(u)
        return BlzGetUnitWeaponRealField(u, UNIT_WEAPON_RF_ATTACK_BASE_COOLDOWN, 0)
    end
end