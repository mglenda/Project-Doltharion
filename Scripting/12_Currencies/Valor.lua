do
    Valor = setmetatable({}, {})
    local v = getmetatable(Valor)
    v.__index = v

    local valor_used = 0
    local valor_total = 2100

    function v:recalculate()
        valor_used = 0
        for i,ut in ipairs(Warband:get()) do
            if ut ~= 0 then valor_used = valor_used + UnitType:get_valor_cost(ut) end
        end
        return valor_used
    end

    function v:is_affordable(ut)
        return valor_used + UnitType:get_valor_cost(ut) <= valor_total
    end

    function v:get()
        return valor_total 
    end

    function v:set(x)
        valor_total = x
        return valor_total 
    end

    function v:add(x)
        valor_total = valor_total + x
        return valor_total 
    end

    function v:sub(x)
        valor_total = valor_total - x 
        return valor_total 
    end
end