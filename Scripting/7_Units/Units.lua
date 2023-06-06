do  
    Units = setmetatable({}, {})
    local au = getmetatable(Units)
    au.__index = au

    local units = {}
    
    function au:register_cast_point(u,x,y)
        units[u].cp = {x=x,y=y}
    end

    function au:clear_cast_point(u)
        units[u].cp = {}
    end

    function au:get_cast_point_x(u)
        if units[u].cp then return units[u].cp.x end
        return nil
    end

    function au:get_cast_point_y(u)
        if units[u].cp then return units[u].cp.y end
        return nil
    end

    function au:get_all()
        self:refresh()
        return units
    end

    function au:get_area_alive_enemy(x,y,aoe,p)
        self:refresh()
        local tbl = {}
        for u,_ in pairs(units) do
            if IsUnitAliveBJ(u) and Utils:get_unit_distance(x,y,u) <= aoe and IsUnitEnemy(u, p) then table.insert(tbl,u) end
        end
        return tbl
    end

    function au:get_area_alive_ally(x,y,aoe,p)
        self:refresh()
        local tbl = {}
        for u,_ in pairs(units) do
            if IsUnitAliveBJ(u) and Utils:get_unit_distance(x,y,u) <= aoe and IsUnitAlly(u, p) then table.insert(tbl,u) end
        end
        return tbl
    end
    
    function au:get_area_alive(x,y,aoe)
        self:refresh()
        local tbl = {}
        for u,_ in pairs(units) do
            if IsUnitAliveBJ(u) and Utils:get_unit_distance(x,y,u) <= aoe then table.insert(tbl,u) end
        end
        return tbl
    end

    function au:get_area(x,y,aoe)
        self:refresh()
        local tbl = {}
        for u,_ in pairs(units) do
            if Utils:get_unit_distance(x,y,u) <= aoe then table.insert(tbl,u) end
        end
        return tbl
    end

    function au:refresh()
        for u,_ in pairs(units) do
            if GetUnitName(u) == '' then units[u] = nil end
        end
    end

    function au:remove_all()
        for u,_ in pairs(units) do
            if u ~= Hero:get() then RemoveUnit(u) end
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
        SetUnitColor(u, Data:get_unit_data(ut).cl or PLAYER_COLOR_SNOW)
        units[u] = {}
        return u
    end
end