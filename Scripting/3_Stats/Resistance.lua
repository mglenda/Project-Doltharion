do
    Resistance = setmetatable({}, {})
    local r = getmetatable(Resistance)
    r.__index = r

    local r_ability = FourCC('ARES')

    function r:get_modifiers(u)
        return Buffs:get_all_modifiers(u,'resist')
    end

    function r:recalculate(u)
        local res,ns,m = self:get_default(u),{},self:get_modifiers(u)
        for i,v in ipairs(m) do
            res = not(ns[v.n]) and res + v.v or res
            ns[v.n] = not(v.s)
        end
        self:set(u,res)
    end
    
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