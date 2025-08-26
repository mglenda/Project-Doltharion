do
    MoveOverhaul = setmetatable({}, {})
    local mo = getmetatable(MoveOverhaul)
    mo.__index = mo

    local t_period = 0.00625
    local t_margin = 0.01
    local oldGetUnitMS = GetUnitMoveSpeed
    local oldSetUnitMS = SetUnitMoveSpeed

    function mo:load()
        self.p_trigger = CreateTrigger()
        DisableTrigger(self.p_trigger)
        self.o_trigger = CreateTrigger()
        DisableTrigger(self.o_trigger)

        TriggerRegisterTimerEventPeriodic(self.p_trigger, t_period)
        TriggerAddAction(self.p_trigger, function() MoveOverhaul:refresh() end)
        TriggerRegisterAnyUnitEventBJ(self.o_trigger, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
        TriggerAddAction(self.o_trigger, function() MoveOverhaul:store_order_point() end)

        self.units = {}
    end

    function mo:approx_equal (a,b)
        return (a >= (b - t_margin)) and (a <= (b + t_margin))
    end

    function mo:refresh()
        local uc = 0
        for u,t in pairs(self.units) do
            local nx,ny = Utils:GetUnitXY(u)
            if not(IsUnitAliveBJ(u)) or not(Units:exists(u)) then
                self:clear(u)
            elseif (not(self:approx_equal(nx, t.x)) or not(self:approx_equal(ny, t.y))) and not(IsUnitPaused(u)) then
                local order = GetUnitCurrentOrder(u)
                local dx = nx - t.x
                local dy = ny - t.y
                local d = SquareRoot(dx * dx + dy * dy)
                dx = dx / d * t.speed
                dy = dy / d * t.speed
                if (order == 851986 or order == 851971) and (t.ox - nx)*(t.ox - nx) < (dx*dx) and (t.oy - ny)*(t.oy - ny) < (dy*dy) then
                    SetUnitX(u, t.ox)
                    SetUnitY(u, t.oy)
                    t.x = t.ox
                    t.y = t.oy
                    IssueImmediateOrderById(u, 851972)
                else
                    t.x = nx + dx
                    t.y = ny + dy
                    SetUnitX(u, t.x)
                    SetUnitY(u, t.y)
                end
            end
            uc = uc + 1
        end
        if uc <= 0 then
            DisableTrigger(self.p_trigger)
            DisableTrigger(self.o_trigger)
        end
    end

    function mo:store_order_point()
        local u = GetTriggerUnit()
        local ox = GetOrderPointX()
        local oy = GetOrderPointY()
        if ox and oy and Utils:type(self.units[u]) == 'table' then
            self.units[u].ox = ox
            self.units[u].oy = oy
        end
    end

    function mo:get(u)
        return self.units[u]
    end

    function mo:clear(u)
        self.units[u] = nil
    end

    function mo:register(u,speed)
        local x,y = Utils:GetUnitXY(u)
        self.units[u] = {
            x = y
            ,y = x
            ,speed = (speed - 522) * t_period
            ,ox = x
            ,oy = y
        }
        if not(IsTriggerEnabled(self.p_trigger)) then
            EnableTrigger(self.p_trigger)
        end
        if not(IsTriggerEnabled(self.o_trigger)) then
            EnableTrigger(self.o_trigger)
        end
    end

    function GetUnitMoveSpeed(u)
        ut = MoveOverhaul:get(u)
        if Utils:type(ut) == 'table' then
            return math.floor((ut.speed / t_period) + 522)
        end
        return oldGetUnitMS(u)
    end

    function SetUnitMoveSpeed(u,speed)
        oldSetUnitMS(u, speed)
        if speed > 522 then
            MoveOverhaul:register(u,speed)
        else
            MoveOverhaul:clear(u)
        end
    end

    OnInit.map(function()
        MoveOverhaul:load()
    end)
end