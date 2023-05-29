do
    AllUnits = setmetatable({}, {})
    local au = getmetatable(AllUnits)
    au.__index = au

    local units = {}

    function au:get()
        self:refresh()
        return units
    end

    function au:refresh()
        for u,_ in pairs(units) do
            if GetUnitName(u) == '' then units[u] = nil end
        end
    end

    local oldBlzCreateUnitWithSkin = BlzCreateUnitWithSkin
    function BlzCreateUnitWithSkin(p, ut, x, y, a, s)
        local u = oldBlzCreateUnitWithSkin(p, ut, x, y, a, s)
        units[u] = {}
        return u
    end

    local oldRemoveUnit = RemoveUnit
    function RemoveUnit(u)
        units[u] = nil
        oldRemoveUnit(u)
    end

    local oldCreateUnit = CreateUnit
    function CreateUnit(p, ut, x, y, a)
        local u = oldCreateUnit(p, ut, x, y, a)
        units[u] = {}
        return u
    end
end