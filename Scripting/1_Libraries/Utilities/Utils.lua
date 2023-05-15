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

    function u:type(v)
        return type(v) == 'userdata' and string.sub(tostring(v), 1, (string.find(tostring(v),':') or string.len(tostring(v)) + 1)-1) or type(v)
    end

    function u:GetUnitXY(u)
        return GetUnitX(u),GetUnitY(u)
    end
end