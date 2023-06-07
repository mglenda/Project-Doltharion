do
    Buffs = setmetatable({}, {})
    local b = getmetatable(Buffs)
    b.__index = b

    local buffs = {}
    local trg = CreateTrigger()

    function b:erase_unit(u)
        buffs[u] = nil
    end

    function b:get_all_modifiers(u,m)
        local tbl = {}
        if Utils:type(buffs[u]) == 'table' then
            for i,v in ipairs(buffs[u]) do
                if Utils:type(v.st) == 'table' and v.st[m] then
                    table.insert(tbl,{
                                    v = v.st[m][1]
                                    ,s = v.st[m][2]
                                    ,al = v.st[m][3]
                                    ,p = v.prio or 10
                                    ,n = v.bn
                                })
                end
            end
        end

        table.sort(tbl, function (k1, k2) return k1.p < k2.p end)
        return tbl
    end

    function b:apply(s,t,bn,data)
        local this = {
            u = t
            ,s = s
            ,bn = bn
            ,dur = 0
            ,per = 0
        }
        this = Utils:table_merge(this,Utils:table_merge(data,Data:get_buff(bn)))

        --Create Effects Start
        if Utils:type(this['e']) == 'table' then
            if (this.es or self:get_stack_count(t,bn) == 0) then
                local efs = {}
                for _,eff in ipairs(this['e']) do
                    local e = AddSpecialEffectTargetUnitBJ(eff.a, t, eff.m)
                    BlzSetSpecialEffectScale(e, eff.s or 1.0)
                    table.insert(efs,e)
                end
                this['e'] = efs
            else
                this['e'] = self:get_effects(t,bn)
            end
        end
        --Create Effects End
        
        if Utils:type(buffs[t]) ~= 'table' then buffs[t] = {} end

        if this.ms then 
            local tbl = {}
            for i,d in ipairs(buffs[t]) do
                if d.bn == this.bn then 
                    table.insert(tbl,d)
                    tbl[#tbl].c_prio = (d.d or 0) - d.dur
                    tbl[#tbl].id = i
                end
            end
            table.sort(tbl, function (k1, k2) return k1.c_prio > k2.c_prio end)
            for i=1,this.ms-1 do
                table.remove(tbl, 1)
            end
            table.sort(tbl, function (k1, k2) return k1.id > k2.id end)
            for i,d in ipairs(tbl) do
                table.remove(buffs[t], d.id)
            end
        end

        table.insert(buffs[t],this)
        self:modify_stats(this.st,this.u)

        if Utils:type(this.func_a) == 'function' then this.func_a(this) end
        if not(IsTriggerEnabled(trg)) then EnableTrigger(trg) end
    end

    function b:modify_stats(st,u)
        if Utils:type(st) == 'table' then
            local ns = {}
            for sn,_ in pairs(st) do
                local c = Data:get_stat_class(sn)
                if not(ns[c]) then
                    c:recalculate(u)
                    ns[c] = true
                end
            end
        end
    end

    function b:get_effects(u,bn)
        if Utils:type(buffs[u]) ~= 'table' then return nil end
        for i,d in ipairs(buffs[u]) do
            if d.bn == bn then return d.e end
        end
        return nil
    end

    function b:get_ui_tbl(u)
        local t = {}
        if Utils:type(buffs[u]) ~= 'table' then return t end
        for i,d in ipairs(buffs[u]) do
            if not(d.h) then
                local k = Utils:get_key_by_value(t,'bn',d.bn)
                if not(k) then
                    table.insert(t,{
                        prio = d.prio or 10
                        ,sc = 1
                        ,bn = d.bn
                        ,is_d = d.is_d
                        ,tc = d.tc
                    })
                else
                    t[k].sc = (t[k].sc or 0) + 1
                end
            end
        end

        table.sort(t, function (k1, k2) return k1.prio < k2.prio end)
        return t
    end

    function b:get_stack_count(u,bn)
        local c = 0
        if Utils:type(buffs[u]) ~= 'table' then return c end
        for i,d in ipairs(buffs[u]) do
            if d.bn == bn then c = c + 1 end
        end
        return c
    end

    function b:erase_effects(bt)
        if Utils:type(bt.e) == 'table' then
            for _,e in ipairs(bt.e) do
                if Utils:type(e) == 'effect' then DestroyEffect(e) end
            end
        end
    end

    function b:clear_buff(u,bn,dis)
        if Utils:type(buffs[u]) ~= 'table' then return end
        local t = {}
        for i,d in ipairs(buffs[u]) do
            if d.bn == bn and (not(dis) or not(d.nd)) then 
                table.insert(t,d)
                t[#t].c_prio = (d.d or 0) - d.dur
                t[#t].id = i
            end
        end

        table.sort(t, function (k1, k2) return k1.c_prio > k2.c_prio end)
        Buffs:clear(u,t[#t].id,#t,dis)
    end

    function b:clear(u,i,sc,dis)
        --destroy effects start 
        --sc param saving performance for cases where we already have information about stacks count which means calling get_stack_count funcion would be ineffective
        sc = sc or self:get_stack_count(u,buffs[u][i].bn)
        if buffs[u][i].es or sc == 1 then self:erase_effects(buffs[u][i]) end
        --destroy effects end
        local bt = buffs[u][i]
        table.remove(buffs[u], i)
        if dis and Utils:type(bt.func_d) == 'function' then bt.func_d(bt) end
        if Utils:type(bt.func_e) == 'function' then bt.func_e(bt) end
        if IsUnitAliveBJ(u) then self:modify_stats(bt.st,u) end
    end

    function b:progress()
        local c = 0
        for u,t in pairs(buffs) do
            for i = #buffs[u],1,-1 do
                buffs[u][i].dur = Utils:round(buffs[u][i].dur + 0.01,2)
                buffs[u][i].per = Utils:round(buffs[u][i].per + 0.01,2)
                if buffs[u][i].per >= ((Utils:type(buffs[u][i].p) == 'function' and buffs[u][i].p(buffs[u][i]) or buffs[u][i].p) or buffs[u][i].per + 1) then
                    buffs[u][i].per = 0
                    if Utils:type(buffs[u][i].func_p) == 'function' then buffs[u][i].func_p(buffs[u][i]) end
                end
                if buffs[u][i].dur >= (buffs[u][i].d or buffs[u][i].dur + 1) or (Utils:type(buffs[u][i].func_q) == 'function' and buffs[u][i].func_q(buffs[u][i])) or (IsUnitDeadBJ(u) and not(buffs[u][i].dp)) then
                    Buffs:clear(u,i)
                end
            end
            c = c + 1
        end
        if c == 0 then DisableTrigger(trg) end
    end

    OnInit.final(function()
        TriggerRegisterTimerEventPeriodic(trg, 0.01)
        TriggerAddAction(trg, Buffs.progress)
    end)
end