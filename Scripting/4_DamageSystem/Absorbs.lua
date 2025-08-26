do
    Absorbs = setmetatable({}, {})
    local a = getmetatable(Absorbs)
    a.__index = a

    local data = {}
    local seed = {}
    local dcm = 1.5

    function a:apply(s,u,v,p)
        if Utils:type(data[u]) ~= 'table' then data[u] = {} end
        seed[u] = seed[u] or 1
        local id = seed[u]
        seed[u] = seed[u] >= 10000 and 1 or seed[u] + 1
        v = v * GetRandomReal(0.99, 1.01)
        local crit = CriticalChance:get(s) >= GetRandomInt(1, 100)
        if crit then v = v * dcm end
        v = Utils:round(v,0)
        table.insert(data[u], {v = v,p = p or 10,id = id,m = v})
        table.sort(data[u], function (k1, k2) return k1.v > k2.v end)
        table.sort(data[u], function (k1, k2) return k1.p < k2.p end)
        TextTag:create({u=u,fs=crit and TextTag:defFontSize() * 1.2 or TextTag:defFontSize(),s=(v >= 0 and '+' or '-') .. StringUtils:round(v,0) .. ' Absorbs',ls = crit and 2.5 or 1.5,r = 145.0,g = 145.0,b = 255.0})
        self:set_mana(u)
        return id
    end

    function a:damage(u,dmg)
        if Utils:type(data[u]) == 'table' then
            for i = #data[u],1,-1 do
                if data[u][i].v < dmg then
                    dmg = dmg - data[u][i].v
                    self:flush(u,i)
                else
                    data[u][i].v = data[u][i].v - dmg
                    self:set_mana(u)
                    return 0,true
                end
            end
        end
        return dmg,false
    end

    function a:get_all(u)
        local r,m = 0,0
        if Utils:type(data[u]) == 'table' then
            for i,v in ipairs(data[u]) do
                r = r + v.v
                m = m + v.m
            end
        end
        return r,m 
    end

    function a:set_mana(u)
        local v,m = self:get_all(u)
        if GetUnitStateSwap(UNIT_STATE_MAX_MANA, u) < m or m <= 0 then
            BlzSetUnitMaxMana(u, m)
        end
        SetUnitManaBJ(u, v)
        if m <= 0 then
            Utils:refresh_unit_bars()
        end
    end

    function a:flush(u,i)
        table.remove(data[u],i)
        self:set_mana(u)
    end

    function a:exists(u,id)
        if Utils:type(data[u]) == 'table' then
            for i,v in ipairs(data[u]) do
                if v.id == id then return v.v end
            end
        end
        return false
    end

    function a:clear_all(u)
        data[u] = {}
    end

    function a:clear(u,id)
        if Utils:type(data[u]) == 'table' then
            for i = #data[u],1,-1 do
                if data[u][i].id == id then self:flush(u,i) end
            end
        end
    end
end