do
    CastingTime = setmetatable({}, {})
    local ct = getmetatable(CastingTime)
    ct.__index = ct

    function ct:get_modifiers_const(u)
        return Buffs:get_all_modifiers(u,'ctime_const')
    end

    function ct:get_modifiers_factor(u)
        return Buffs:get_all_modifiers(u,'ctime_factor')
    end

    function ct:recalculate(u)
        local ns,m,ab,abs = {},self:get_modifiers_const(u),{},ObjectUtils:getUnitAbilities(u)
        for _,a in pairs(abs) do if a.ac ~= 'Aatk' then ab[a.ac] = self:get_default(u,a.ac) end end
        for i,v in ipairs(m) do
            if not(ns[v.n]) then 
                local al = Utils:type(v.al) == 'table' and v.al or abs
                for _,a in ipairs(al) do
                    if a.ac ~= 'Aatk' and ab[a.ac] then ab[a.ac] = ab[a.ac] + v.v end
                end
                ns[v.n] = not(v.s)
            end
        end
        m = self:get_modifiers_factor(u)
        for i,v in ipairs(m) do
            if not(ns[v.n]) then 
                local al = Utils:type(v.al) == 'table' and v.al or abs
                for _,a in ipairs(al) do
                    if a.ac ~= 'Aatk' and ab[a.ac] then ab[a.ac] = ab[a.ac] * v.v end
                end
                ns[v.n] = not(v.s)
            end
        end
        for a,v in pairs(ab) do
            self:set(u,Utils:round(v,2),a)
        end
    end

    function ct:set(u,v,a)
        BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, FourCC(a)), ABILITY_RLF_FOLLOW_THROUGH_TIME, 0, v < 0.05 and 0 or v)
        IncUnitAbilityLevel(u, FourCC(a))
        DecUnitAbilityLevel(u, FourCC(a))
    end

    function ct:get(u,a)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, FourCC(a)), ABILITY_RLF_FOLLOW_THROUGH_TIME, 0)
    end

    function ct:get_default(u,a)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, FourCC(a)), ABILITY_RLF_DURATION_NORMAL, 0)
    end
end