do
    Warband = setmetatable({}, {})
    local w = getmetatable(Warband)
    w.__index = w

    local warband = {
        {u = FourCC('h004'),l = 1}
        ,{u = FourCC('h004'),l = 1}
        ,{u = FourCC('h002'),l = 2}
        ,{u = FourCC('h002'),l = 2}
        ,{u = FourCC('h002'),l = 2}
        ,{u = FourCC('h001'),l = 3}
        ,{u = FourCC('h001'),l = 3}
        ,{u = FourCC('h001'),l = 3}
        ,{u = FourCC('h001'),l = 3}
        ,{u = FourCC('h005'),l = 4}
        ,{u = FourCC('h003'),l = 4}
        ,{u = FourCC('h005'),l = 4}
    }

    local units = {}

    function w:get()
        return units
    end

    function w:clear()
        for i=#units,1,-1 do
            Units:remove(units[i])
            table.remove(units,i)
        end
    end

    function w:spawn(facing)
        local tbl = {}
        for _,t in ipairs(warband) do
            local l = t.l or (Data:get_unit_data(t.u).l or 1)
            local i = Utils:get_key_by_value(tbl,'l',l)
            if not(i) then 
                table.insert(tbl,{l = l})
                i = #tbl
            end
            tbl[i].u = tbl[i].u or {}
            table.insert(tbl[i].u,t.u)
        end

        table.sort(tbl, function (k1, k2) return k1.l > k2.l end)
        units = {}
        local d,x,y,u = 150.0,0,0,nil
        facing = facing or GetUnitFacing(Hero:get())
        for _,t in ipairs(tbl) do
            x,y = Utils:move_xy(GetUnitX(Hero:get()),GetUnitY(Hero:get()),d,Deg2Rad(facing))
            x,y = Utils:move_xy(x,y,50.0 * (#t.u-1),Deg2Rad(facing-90))
            for i,ut in ipairs(t.u) do
                u = CreateUnit(Players:get_empire(),ut,x,y,facing)
                table.insert(units,u)
                x,y = Utils:move_xy(GetUnitX(u),GetUnitY(u),100.0,Deg2Rad(facing+90))
            end
            d = d + 150.0
        end
    end
end