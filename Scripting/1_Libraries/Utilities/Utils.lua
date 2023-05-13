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
        return string.sub(tostring(v), 1, (string.find(tostring(v),':') or string.len(tostring(v)) + 1)-1)
    end
end