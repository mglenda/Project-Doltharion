do
    Resistance = setmetatable({}, {})
    local r = getmetatable(Resistance)
    r.__index = r

    local r_ability = FourCC('ARES')

    

    function r:set(u,v)
        if GetUnitAbilityLevel(u, r_ability) == 0 then UnitAddAbility(u, r_ability) end
        BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(u, r_ability), ABILITY_ILF_DEFENSE_BONUS_IDEF, 0, v - self:get_default(u))
        IncUnitAbilityLevel(u, r_ability)
        DecUnitAbilityLevel(u, r_ability)
    end

    function r:get(u)
        return BlzGetUnitArmor(u) 
    end

    function r:get_default(u)
        return BlzGetUnitArmor(u) - BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, r_ability), ABILITY_ILF_DEFENSE_BONUS_IDEF, 0)
    end
end