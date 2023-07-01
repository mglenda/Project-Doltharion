do
    SpellPower = setmetatable({}, {})
    local sp = getmetatable(SpellPower)
    sp.__index = sp

    local sp_ability = FourCC('APWR')

    function sp:get_modifiers_const(u)
        return Buffs:get_all_modifiers(u,'spepow_const')
    end

    function sp:get_modifiers_factor(u)
        return Buffs:get_all_modifiers(u,'spepow_factor')
    end

    function sp:recalculate(u)
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

    function sp:set(u,v)
        if GetUnitAbilityLevel(u, sp_ability) == 0 then UnitAddAbility(u, sp_ability) end
        BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(u, sp_ability), ABILITY_ILF_INTELLIGENCE_BONUS, 0, v - self:get_default(u))
        IncUnitAbilityLevel(u, sp_ability)
        DecUnitAbilityLevel(u, sp_ability)
    end

    function sp:get(u)
        return (GetHeroInt(u, false) + (Data:get_unit_data(GetUnitTypeId(u)).spower or 0)) + BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, sp_ability), ABILITY_ILF_INTELLIGENCE_BONUS, 0)
    end

    function sp:get_default(u)
        return (GetHeroInt(u, false) + (Data:get_unit_data(GetUnitTypeId(u)).spower or 0))
    end
end