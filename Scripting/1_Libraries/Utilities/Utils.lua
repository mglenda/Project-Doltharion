do
    Utils = setmetatable({}, {})
    local u = getmetatable(Utils)
    u.__index = u

    function u:table_contains(tbl, x)
        for _, v in pairs(tbl) do
            if v == x then 
                return true 
            end
        end
        return false
    end

    function u:get_key_by_value(t,mk,v)
        for k,d in pairs(t) do
            if d[mk] and d[mk] == v then return k end
        end
        return nil
    end

    function u:table_merge(p,s)
        if self:type(p) ~= 'table' then p = {} end
        if self:type(s) ~= 'table' then s = {} end
        for k,v in pairs(s) do p[k] = v end
        return p
    end

    function u:round(n, dp)
        local r = nil
        if dp and dp > 0 then
          local m = 10^dp
          return math.floor(n * m + 0.5) / m
        end
        return math.floor(n + 0.5)
    end

    function u:table_length(t)
        local c = 0
        for _ in pairs(t) do c = c + 1 end
        return c
    end

    function u:type(v)
        return type(v) == 'userdata' and string.sub(tostring(v), 1, (string.find(tostring(v),':') or string.len(tostring(v)) + 1)-1) or type(v)
    end

    function u:GetUnitXY(u)
        return GetUnitX(u),GetUnitY(u)
    end
end