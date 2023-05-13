do
    StringUtils = setmetatable({}, {})
    local stringUtils = getmetatable(StringUtils)
    stringUtils.__index = stringUtils

    function stringUtils:round(value,decplaces)
        local dot,s = StringUtils:instr(tostring(value),'.'),tostring(value)
        decplaces = decplaces and (not(dot) and decplaces == 0 and decplaces or (dot and decplaces or decplaces + 1)) or 0
        local decs = decplaces > 0 and (dot and '' or '.') or ''
        dot = decplaces > 0 and (dot or string.len(s)) or (dot and dot - 1 or string.len(s))
        for i=1,decplaces do
            decs = decs .. '0'
        end
        return string.sub(s .. decs,1,dot+decplaces)
    end

    function stringUtils:instr(str,find)
        for i=1,string.len(str) do
            if string.sub(str,i,i) == find then
                return i
            end
        end
        return nil
    end
end