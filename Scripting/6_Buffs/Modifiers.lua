do
    Modifiers = setmetatable({}, {})
    local m = getmetatable(Modifiers)
    m.__index = m

    local modifiers = {}

    --[[
        v = value of increase
        s = true/false wether it stacks
        al = ability list
    ]]--
    function m:get_all_modifiers(u,s_name)
        local tbl = {}
        if Utils:type(modifiers[u]) == 'table' then
            for i,v in ipairs(modifiers[u]) do
                if Utils:type(v.m_stats) == 'table' and v.m_stats[s_name] then
                    table.insert(tbl,{
                                    v = v.m_stats[s_name][1]
                                    ,s = false --modifiers doesn't stack
                                    ,al = v.m_stats[s_name][2]
                                    ,p = v.m_prio or 10
                                    ,n = v.m_name
                                })
                end
            end
        end

        table.sort(tbl, function (k1, k2) return k1.p < k2.p end)
        return tbl
    end

    function m:_recalculate_stats(u,m_stats)
        if Utils:type(m_stats) == 'table' then
            for s_name,_ in pairs(m_stats) do
                local s_class = Data:get_stat_class(s_name)
                s_class:recalculate(u)
            end
        end
    end

    function m:_remove(u,i)
        local m_table = modifiers[u][i]
        self:_erase_effects(u,i)
        table.remove(modifiers[u],i)
        self:_recalculate_stats(u,m_table.m_stats)
    end

    function m:_erase_effects(u,i)
        if Utils:type(modifiers[u][i].m_effects) == 'table' then
            for _,e in ipairs(modifiers[u][i].m_effects) do
                DestroyEffect(e)
            end
            modifiers[u][i].m_effects = nil
        end
    end

    --[[
        Modifiers:remove{
            unit = Hero:get()
            ,m_name = 'mod_test'
        }
    ]]--

    function m:remove(args)
        local u = args.unit
        local m_name = args.m_name
        if u and m_name and Utils:type(modifiers[u]) == 'table' then
            local i = Utils:get_key_by_value(modifiers[u],'m_name',m_name)
            if i then self:_remove(u,i) end
        end
    end

    --[[
        Modifiers:apply{
            unit = Hero:get()
            ,m_name = 'mod_test'

            --Optional
            ,m_data = 
        }
    ]]--

    --m_data Structure:
    --  m_prio = priority
    --  m_stats = stats
    --  m_effects = effects -> {e_model,e_attpoint,e_scale}
 
    function m:apply(args)
        local u = args.unit
        local m_name = args.m_name

        if m_name and u then
            modifiers[u] = Utils:type(modifiers[u]) == 'table' and modifiers[u] or {}

            --Merge custom data with pre-defined data
            local m_data = Utils:table_merge(args.m_data,Data:get_modifier(m_name))
            local m_effects = m_data.m_effects
            local _effects = nil

            --Erase modifier if already exists upon unit, no stacking behavior for modifiers
            local i = Utils:get_key_by_value(modifiers[u],'m_name',m_name)
            if i then 
                self:_remove(u,i)
            end

            if Utils:type(m_effects) == 'table' then
                _effects = {}
                for _,e_def in ipairs(m_effects) do
                    local e = AddSpecialEffectTargetUnitBJ(e_def.e_attpoint, u, e_def.e_model)
                    BlzSetSpecialEffectScale(e, e_def.e_scale or 1.0)
                    table.insert(_effects,e)
                end
            end

            m_data.m_effects = _effects
            m_data.m_name = m_name
            table.insert(modifiers[u],m_data)
            self:_recalculate_stats(u,m_data.m_stats)
        end
    end

    --Garbage Collector on RemoveUnit
    function m:erase_unit(u)
        if Utils:type(modifiers[u]) == 'table' then
            for i,_ in ipairs(modifiers[u]) do
                self:_erase_effects(u,i)
            end
        end
        modifiers[u] = nil
    end

    OnInit.map(function()
        Units:register_gc_class(Modifiers)
    end)
end