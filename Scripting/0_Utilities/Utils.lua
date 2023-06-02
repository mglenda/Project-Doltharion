do
    Utils = setmetatable({}, {})
    local u = getmetatable(Utils)
    u.__index = u

    function u:table_contains(tbl, x)
        for _, v in pairs(tbl) do
            if v == x then 
                return true 
            end
        end
        return false
    end

    function u:get_key_by_value(t,mk,v)
        for k,d in pairs(t) do
            if d[mk] and d[mk] == v then return k end
        end
        return nil
    end

    function u:table_merge(p,s)
        if self:type(p) ~= 'table' then p = {} end
        if self:type(s) ~= 'table' then s = {} end
        for k,v in pairs(s) do 
            if not(p[k]) then p[k] = self:type(v) == 'table' and self:copy_table(v) or v end
        end
        return p
    end

    function u:copy_table(t)
        local result = {}
        for k,v in pairs(t) do
            if (self:type(v) == 'table') then
                result[k] = self:copy_table(v)
            else
                result[k] = v
            end
        end
        return result
    end

    function u:round(n, dp)
        local r = nil
        if dp and dp > 0 then
          local m = 10^dp
          return math.floor(n * m + 0.5) / m
        end
        return math.floor(n + 0.5)
    end

    function u:table_length(t)
        local c = 0
        for _ in pairs(t) do c = c + 1 end
        return c
    end

    function u:type(v)
        return type(v) == 'userdata' and string.sub(tostring(v), 1, (string.find(tostring(v),':') or string.len(tostring(v)) + 1)-1) or type(v)
    end

    function u:GetUnitXY(u)
        return GetUnitX(u),GetUnitY(u)
    end

    function u:GetUnitXYZ(u)
        return GetUnitX(u),GetUnitY(u),self:get_unit_z(u)
    end

    function u:get_distance(x1,y1,x2,y2)
        return SquareRoot((x2 - x1)^2 + (y2 - y1)^2)
    end

    function u:get_unit_distance(x1,y1,u)
        local x2,y2 = self:GetUnitXY(u)
        return self:get_distance(x1,y1,x2,y2)
    end

    function u:get_units_distance(u1,u2)
        local x1,y1 = self:GetUnitXY(u1)
        local x2,y2 = self:GetUnitXY(u2)
        return self:get_distance(x1,y1,x2,y2)
    end

    function u:set_unit_xy(u,x,y)
        SetUnitX(u, x)
        SetUnitY(u, y)
    end

    local loc = Location(0, 0)

    function u:get_unit_z(u) 
        MoveLocation(loc,GetUnitX(u),GetUnitY(u))
        return GetLocationZ(loc) + GetUnitFlyHeight(u)
    end

    function u:get_point_z(x,y)
        MoveLocation(loc,x,y)
        return GetLocationZ(loc)
    end

    function u:get_rect_min_max(r)
        return GetRectMinX(r),GetRectMinY(r),GetRectMaxX(r),GetRectMaxY(r)
    end

    function u:is_unit_in_rect(u,r)
        local ux,uy = self:GetUnitXY(u)
        local rx1,ry1,rx2,ry2 = self:get_rect_min_max(r)
        return not(ux <= rx1 or uy <= ry1 or ux >= rx2 or uy >= ry2)
    end

    function u:get_rad_between_points(x1,y1,x2,y2)
        return Atan2(y2 - y1, x2 - x1)
    end

    function u:get_angle_between_points(x1,y1,x2,y2)
        return self:get_rad_between_points(x1,y1,x2,y2) * bj_RADTODEG
    end

    function u:move_x(x,d,r)
        return x + d * Cos(r)
    end

    function u:move_y(y,d,r)
        return y + d * Sin(r)
    end

    function u:move_xy(x,y,d,r)
        return self:move_x(x,d,r),self:move_y(y,d,r)
    end

    function u:mod(a,b)
        return a - math.floor(a/b)*b
    end
end