do
    CriticalChance = setmetatable({}, {})
    local cc = getmetatable(CriticalChance)
    cc.__index = cc

    local cc_ability = FourCC('APWR')

    function cc:get_modifiers(u)
        return Buffs:get_all_modifiers(u,'critchance')
    end

    function cc:recalculate(u)
        local val,ns,m = self:get_default(u),{},self:get_modifiers(u)
        for i,v in ipairs(m) do
            val = not(ns[v.n]) and val + v.v or val
            ns[v.n] = not(v.s)
        end
        self:set(u,val)
    end

    function cc:set(u,v)
        if GetUnitAbilityLevel(u, cc_ability) == 0 then UnitAddAbility(u, cc_ability) end
        BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(u, cc_ability), ABILITY_ILF_AGILITY_BONUS, 0, v - self:get_default(u))
        IncUnitAbilityLevel(u, cc_ability)
        DecUnitAbilityLevel(u, cc_ability)
    end

    function cc:get(u)
        return (GetHeroAgi(u, false) + (Data:get_unit_data(GetUnitTypeId(u)).crit or 10)) + BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, cc_ability), ABILITY_ILF_AGILITY_BONUS, 0)
    end

    function cc:get_default(u)
        return (GetHeroAgi(u, false) + (Data:get_unit_data(GetUnitTypeId(u)).crit or 10))
    end
end