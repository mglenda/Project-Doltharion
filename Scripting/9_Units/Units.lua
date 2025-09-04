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

    function au:register_order(u,o)
        units[u].o = o
    end

    function au:clear_order(u)
        units[u].o = nil
    end

    function au:is_ordered(u)
        return units[u].o
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

    function au:register_cast_target(u,t)
        units[u].ct = t
    end

    function au:clear_cast_target(u)
        units[u].ct = nil
    end

    function au:get_cast_target(u)
        return units[u].ct
    end

    function au:get_all()
        self:refresh()
        return units
    end

    function au:pause_all()
        self:refresh()
        for uu,_ in pairs(units) do
            self:pause(uu)
        end
    end

    function au:unpause_all()
        self:refresh()
        for uu,_ in pairs(units) do
            self:unpause(uu)
        end
    end

    function au:pause(u)
        PauseUnit(u, true)
        self:clear_order(u)
    end

    function au:unpause(u)
        PauseUnit(u, false)
    end

    function au:get_ai_target(u,aoe)
        self:refresh()
        local tbl,m_p = {},999
        for uu,_ in pairs(units) do
            if IsUnitAliveBJ(uu) and IsUnitEnemy(uu, GetOwningPlayer(u)) and (not(aoe) or Utils:get_units_distance(uu,u) <= aoe) then 
                table.insert(tbl,uu) 
                local up = Data:get_unit_data(GetUnitTypeId(uu)).p or GetUnitLevel(uu)
                m_p = up < m_p and up or m_p 
            end
        end
        return tbl,m_p
    end

    function au:get_alive_enemy(p)
        self:refresh()
        local tbl = {}
        for u,_ in pairs(units) do
            if IsUnitAliveBJ(u) and IsUnitEnemy(u, p) then table.insert(tbl,u) end
        end
        return tbl
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
            if u ~= Hero:get() and GetUnitAbilityLevel(u, FourCC('DUMM')) <= 0 then RemoveUnit(u) end
        end
    end

    function au:remove(u)
        RemoveUnit(u)
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

    local gc_classes = {}

    function au:register_gc_class(class)
        table.insert(gc_classes,class)
    end

    oldRemoveUnit = RemoveUnit
    function RemoveUnit(u)
        if u == Target:get() then Target:clearTarget() end
        for i,class in ipairs(gc_classes) do
            class:erase_unit(u)
        end
        units[u] = nil
        oldRemoveUnit(u)
    end

    oldCreateUnit = CreateUnit
    function CreateUnit(p, ut, x, y, a)
        local u = oldCreateUnit(p, ut, x, y, a)
        SetUnitColor(u, Data:get_unit_data(ut).cl or PLAYER_COLOR_SNOW)
        units[u] = {}
        Units:check_auras(u)
        return u
    end

    oldBlzCreateUnitWithSkin = BlzCreateUnitWithSkin
    function BlzCreateUnitWithSkin(p, ut, x, y, a, s)
        local u = oldBlzCreateUnitWithSkin(p, ut, x, y, a, s)
        units[u] = {}
        Units:check_auras(u)
        return u
    end

    function au:check_auras(u)
        for _,a_code in ipairs(ObjectUtils:get_unit_ability_codes{unit = u}) do
            if a_code ~= 'Aatk' then
                if Data:get_ability_class(FourCC(a_code)) and Utils:type(Data:get_ability_class(FourCC(a_code)).aura_periodic) == 'function' then
                    Data:get_ability_class(FourCC(a_code)):enable()
                end
            end
        end
    end

    OnInit.final(function()
        TriggerRegisterAnyUnitEventBJ(d_trg, EVENT_PLAYER_UNIT_DEATH)
        TriggerAddAction(d_trg, Units.on_death)
    end)
end