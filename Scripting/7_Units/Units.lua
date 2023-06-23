do  
    Units = setmetatable({}, {})
    local au = getmetatable(Units)
    au.__index = au

    local units = {}
    local d_trg = CreateTrigger()

    function au:register_casting(u,a)
        units[u].ca = a
    end

    function au:clear_casting(u)
        units[u].ca = nil
    end
    
    function au:is_casting(u)
        return units[u].ca
    end

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

    function au:exists(u)
        return not(GetUnitName(u) == '')
    end

    function au:remove_all()
        for u,_ in pairs(units) do
            if u ~= Hero:get() then RemoveUnit(u) end
        end
    end

    function au:on_death()
        local u = GetDyingUnit()
        if Utils:type(units[u].odf) == 'table' then
            for i,v in pairs(units[u].odf) do
                if Utils:type(v) == 'function' then v() end
            end
        end 
        units[u].odf = nil
    end

    function au:register_on_death(u,i,f)
        units[u].odf = units[u].odf or {}
        units[u].odf[i] = f
    end

    function au:clear_on_death(u,i)
        if Utils:type(units[u].odf) == 'table' then
            units[u].odf[i] = nil
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
        if u == Target:get() then Target:clearTarget() end
        Buffs:erase_unit(u)
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

    OnInit.final(function()
        TriggerRegisterAnyUnitEventBJ(d_trg, EVENT_PLAYER_UNIT_DEATH)
        TriggerAddAction(d_trg, Units.on_death)
    end)
end