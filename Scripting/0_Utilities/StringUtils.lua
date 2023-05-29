do
    StringUtils = setmetatable({}, {})
    local stringUtils = getmetatable(StringUtils)
    stringUtils.__index = stringUtils

    function stringUtils:round(value,decplaces)
        local s,decplaces = tostring(value),decplaces or 0
        local dp = string.find(s,'.',1,true)
        s = not(dp) and s .. '.0000' or s .. '0000'
        dp = dp or string.len(tostring(value)) + 1
        return string.sub(s,1,decplaces > 0 and dp + decplaces or dp - 1)
    end
end