do
    Heal = setmetatable({}, {})
    local h = getmetatable(Heal)
    h.__index = h

    local dcm = 1.5

    function h:unit(s,u,v)
        v = v * GetRandomReal(0.99, 1.01)
        local crit = CriticalChance:get(s) >= GetRandomInt(1, 100)
        v = crit and v * dcm or v
        local hp = GetUnitState(u, UNIT_STATE_LIFE)
        SetUnitState(u, UNIT_STATE_LIFE, hp + v)
        TextTag:create({u=u,s=(v >= 0 and '+' or '-') .. StringUtils:round(v,0),fs=crit and TextTag:defFontSize() * 1.2 or TextTag:defFontSize(),ls = crit and 2.5 or 1.0,r = 40.0,g = 180.0,b = 40.0,os = 50.0})
    end
end