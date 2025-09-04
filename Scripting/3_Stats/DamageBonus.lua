do
    DamageBonus = setmetatable({}, {})
    local db = getmetatable(DamageBonus)
    db.__index = db

    local data = {}

    function db:get_modifiers_value(u)
        return Utils:table_merge(Modifiers:get_all_modifiers(u,'dmg_bonus_value'),Buffs:get_all_modifiers(u,'dmg_bonus_value'))
    end

    function db:get_modifiers_const(u)
        return Utils:table_merge(Modifiers:get_all_modifiers(u,'dmg_bonus_const'),Buffs:get_all_modifiers(u,'dmg_bonus_const'))
    end

    function db:get_modifiers_factor(u)
        return Utils:table_merge(Modifiers:get_all_modifiers(u,'dmg_bonus_factor'),Buffs:get_all_modifiers(u,'dmg_bonus_factor'))
    end

    --[[
    v = v.st[m][1]
    ,s = v.st[m][2]
    ,al = v.st[m][3]
    ,p = v.prio or 10
    ,n = v.bn
    ]]--
    
    function db:recalculate(u)
        local no_stack = {}
        local values,factors,constants = {all = 0},{all = 1.0},{all = 0.0}

        local modifiers = self:get_modifiers_value(u)
        local is_d = #modifiers > 0
        for i,m_data in ipairs(modifiers) do
            if not(no_stack[m_data.n]) then
                if Utils:type(m_data.al) == 'table' then
                    for _,id in ipairs(m_data.al) do
                        values[FourCC(id)] = (values[FourCC(id)] or 0) + m_data.v
                    end
                else
                    values.all = values.all + m_data.v
                end
            end
            no_stack[m_data.n] = not(m_data.s)
        end 

        modifiers = self:get_modifiers_const(u)
        is_d = is_d or #modifiers > 0
        no_stack = {}
        for i,m_data in ipairs(modifiers) do
            if not(no_stack[m_data.n]) then
                if Utils:type(m_data.al) == 'table' then
                    for _,id in ipairs(m_data.al) do
                        constants[FourCC(id)] = (constants[FourCC(id)] or 0.0) + m_data.v
                    end
                else
                    constants.all = constants.all + m_data.v
                end
            end
            no_stack[m_data.n] = not(m_data.s)
        end

        modifiers = self:get_modifiers_factor(u)
        is_d = is_d or #modifiers > 0
        no_stack = {}
        for i,m_data in ipairs(modifiers) do
            if not(no_stack[m_data.n]) then
                if Utils:type(m_data.al) == 'table' then
                    for _,id in ipairs(m_data.al) do
                        factors[FourCC(id)] = (factors[FourCC(id)] or 1.0) * m_data.v
                    end
                else
                    factors.all = factors.all * m_data.v
                end
            end
            no_stack[m_data.n] = not(m_data.s)
        end

        if is_d then
            self:set{
                u=u
                ,factors = factors
                ,constants = constants
                ,values = values
            }
        else
            self:erase_unit(u)
        end
    end

    function db:set(args)
        data[args.u] = {}
        data[args.u].factors = args.factors
        data[args.u].constants = args.constants
        data[args.u].values = args.values
    end

    function db:get(u,id)
        local factor,constant,value = 1.0,1.0,0
        if Utils:type(data[u]) == 'table' then
            factor = factor * (data[u].factors.all or 1.0)
            constant = constant + (data[u].constants.all or 0.0)
            value = value + (data[u].values.all or 0)

            factor = factor * (data[u].factors[id] or 1.0)
            constant = constant + (data[u].constants[id] or 0.0)
            value = value + (data[u].values[id] or 0)
        end
        return Utils:round(factor,2),Utils:round(constant,2),Utils:round(value,2)
    end

    function db:erase_unit(u)
        data[u] = nil
    end

    OnInit.map(function()
        Units:register_gc_class(DamageBonus)
    end)
end