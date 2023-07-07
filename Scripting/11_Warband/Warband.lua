do
    Warband = setmetatable({}, {})
    local w = getmetatable(Warband)
    w.__index = w

    local warband = {
        0,FourCC('h004'),0,0
        ,0,0,0,0
        ,0,FourCC('h003'),FourCC('h003'),0
        ,0,0,0,0
        ,FourCC('h005'),FourCC('h005'),FourCC('h005'),FourCC('h005')
    }

    local units = {}

    function w:get_units()
        return units
    end

    function w:clear()
        for i=#units,1,-1 do
            Units:remove(units[i])
            table.remove(units,i)
        end
    end

    function w:set_slot(i,ut)
        if warband[i] then warband[i] = ut end
    end

    function w:get()
        return warband
    end

    function w:spawn(facing)
        local tbl,l = {},0
        for j=#warband,1,-1 do
            if Utils:mod(j,4) == 0 then 
                l = l + 1 
                tbl[l] = {}
            end
            tbl[l].u = tbl[l].u or {}
            table.insert(tbl[l].u,warband[j])
        end

        units = {}
        local d,x,y,u = 150.0,0,0,nil
        facing = facing or GetUnitFacing(Hero:get())
        for _,t in ipairs(tbl) do
            x,y = Utils:move_xy(GetUnitX(Hero:get()),GetUnitY(Hero:get()),d,Deg2Rad(facing))
            x,y = Utils:move_xy(x,y,50.0 * (#t.u-1),Deg2Rad(facing-90))
            for i,ut in ipairs(t.u) do
                if ut ~= 0 then 
                    u = CreateUnit(Players:get_empire(),ut,x,y,facing)
                    table.insert(units,u)
                end
                x,y = Utils:move_xy(x,y,100.0,Deg2Rad(facing+90))
            end
            d = d + 150.0
        end
    end
end