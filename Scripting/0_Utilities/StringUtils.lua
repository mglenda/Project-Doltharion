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

    function stringUtils:format_seconds(time,keepAll)
        time = time > 0 and time * 10 or 0
        local hours = math.floor(time/36000)
        time = time - math.floor(time/36000)*36000
        local minutes = self:round(time / 600,0)
        time = time - math.floor(time/600)*600
        local seconds = self:round(time / 10,0)
        time = time - math.floor(time/10)*10
        hours = (hours > 0 and self:round(hours,0) .. ':' or (keepAll and '00:' or ''))
        hours = (hours:len() == 2 and keepAll) and '0' .. hours or hours
        seconds = (minutes == '0' and seconds or ("0"..seconds):sub(-2)) .. '.' .. self:round(time,0)
        minutes = (minutes == '0' and (keepAll and '00:' or '') or minutes .. ':')
        minutes = (minutes:len() == 2 and keepAll) and '0' .. minutes or minutes
        return tostring(hours .. minutes .. seconds)
    end

    function stringUtils:format_seconds_minutes(time)
        time = time > 0 and time * 10 or 0
        local minutes = self:round(time / 600,0)
        time = time - math.floor(time/600)*600
        local seconds = self:round(time / 10,0)
        time = time - math.floor(time/10)*10
        seconds = (minutes == '0' and seconds or ("0"..seconds):sub(-2)) .. '.' .. self:round(time,0)
        minutes = (minutes == '0' and '' or minutes .. ':')
        minutes = minutes:len() == 2 and '0' .. minutes or minutes
        return tostring(minutes .. seconds)
    end
end