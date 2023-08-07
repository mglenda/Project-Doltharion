do
    AnimationSeq = setmetatable({}, {})
    local as = getmetatable(AnimationSeq)
    as.__index = as

    local data = {}
    local trg = CreateTrigger()

    function as:start(u,seq,d)
        if #seq <= 0 then 
            return
        else
            if Utils:type(data[u]) == 'table' then
                if data[u].t then DestroyTimer(data[u].t) end
            end
            local od = self:get_duration(seq)
            SetUnitTimeScale(u, Utils:round(od / (d or od),2))
            data[u] = {
                t = CreateTimer()
                ,seq = seq
                ,s = Utils:round((d or od) / od,2)
            }
            self:play_next(u)
        end
    end

    function as:play_next(u)
        SetUnitAnimationByIndex(u, data[u].seq[1][1])
        local d = Utils:round(data[u].seq[1][2] * data[u].s,2)
        local l = data[u].seq[1][3]
        table.remove(data[u].seq,1)
        if data[u].t then DestroyTimer(data[u].t) end
        if #data[u].seq > 0 then 
            data[u].t = CreateTimer()
            TimerStart(data[u].t, d, false, function() 
                AnimationSeq:play_next(u)
            end)
        else
            data[u].t = CreateTimer()
            TimerStart(data[u].t, d, false, function()
                AnimationSeq:stop(u,l)
            end)
        end
    end

    function as:get_duration(seq)
        local d = 0
        for i,v in ipairs(seq) do
            d = d + v[2]
        end
        return d
    end

    function as:stop(u,l)
        if data[u].t then DestroyTimer(data[u].t) end
        SetUnitTimeScale(u, 1.0)
        if not(l) then ResetUnitAnimation(u) end
    end

    OnInit.final(function()
        TriggerRegisterAnyUnitEventBJ(trg,EVENT_PLAYER_UNIT_ISSUED_ORDER)
        TriggerRegisterAnyUnitEventBJ(trg,EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
        TriggerRegisterAnyUnitEventBJ(trg,EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
        TriggerAddAction(trg, function()
            AnimationSeq:stop(GetOrderedUnit())
        end)
    end)
end