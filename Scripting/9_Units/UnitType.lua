do
    UnitType = setmetatable({}, {})
    local ut = getmetatable(UnitType)
    ut.__index = ut

    local x,y = 7358.3, 11186.5
    
    function ut:get_unit_name(ut)
        local u = oldCreateUnit(Players:get_passive(), ut, x, y, 180.0)
        local un = GetUnitName(u)
        oldRemoveUnit(u)
        return un
    end
end
