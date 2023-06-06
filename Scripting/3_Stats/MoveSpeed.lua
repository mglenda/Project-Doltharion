do
    MoveSpeed = setmetatable({}, {})
    local ms = getmetatable(MoveSpeed)
    ms.__index = ms

    function ms:get_modifiers_const(u)
        return Buffs:get_all_modifiers(u,'movespeed_const')
    end

    function ms:get_modifiers_factor(u)
        return Buffs:get_all_modifiers(u,'movespeed_factor')
    end

    function ms:recalculate(u)
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

    function ms:set(u,v)
        SetUnitMoveSpeed(u, v)
    end

    function ms:get(u)
        return GetUnitMoveSpeed(u)
    end

    function ms:get_default(u)
        return GetUnitDefaultMoveSpeed(u)
    end
end