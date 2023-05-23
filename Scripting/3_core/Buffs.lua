do
    Buffs = setmetatable({}, {})
    local b = getmetatable(Buffs)
    b.__index = b

    local buffs = {}
    local trg = CreateTrigger()

    function b:apply(s,t,bn,data)
        local this = {
            u = t
            ,s = s
            ,bn = bn
            ,dur = 0
        }
        this = Utils:table_merge(this,Utils:table_merge(data,Data:get_buff(bn)))
        
        if Utils:type(buffs[t]) ~= 'table' then buffs[t] = {} end

        table.insert(buffs[t],this)
        if not(IsTriggerEnabled(trg)) then EnableTrigger(trg) end
    end

    function b:clear_debuff(u,bn)
        if Utils:type(buffs[u]) ~= 'table' then return end
        local t = {}
        for i,d in ipairs(buffs[u]) do
            if d.bn == bn then 
                table.insert(t,d)
                t[#t].prio = (d.d or 0) - d.dur
                t[#t].id = i
            end
        end

        table.sort(t, function (k1, k2) return k1.prio > k2.prio end)
        table.remove(buffs[u], t[#t].id)
    end

    function b:progress()
        if Utils:table_length(buffs) == 0 then DisableTrigger(trg) end
        for u,t in pairs(buffs) do
            for i = #buffs[u],1,-1 do
                buffs[u][i].dur = Utils:round(buffs[u][i].dur + 0.01,2)
                if buffs[u][i].dur >= (buffs[u][i].d or buffs[u][i].dur + 1) then
                    table.remove(buffs[u], i)
                end
            end
        end
    end

    OnInit.final(function()
        TriggerRegisterTimerEventPeriodic(trg, 0.01)
        TriggerAddAction(trg, Buffs.progress)
    end)
end