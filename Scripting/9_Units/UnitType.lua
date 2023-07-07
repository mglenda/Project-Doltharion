do
    UnitType = setmetatable({}, {})
    local ut = getmetatable(UnitType)
    ut.__index = ut

    local x,y = 7358.3, 11186.5
    
    function ut:get_name(ut)
        local u = oldCreateUnit(Players:get_passive(), ut, x, y, 180.0)
        local un = GetUnitName(u)
        oldRemoveUnit(u)
        return un
    end

    function ut:get_valor_cost(ut)
        local u = oldCreateUnit(Players:get_passive(), ut, x, y, 180.0)
        local vc = BlzGetUnitIntegerField(u, UNIT_IF_GOLD_BOUNTY_AWARDED_BASE)
        oldRemoveUnit(u)
        return vc
    end
end
