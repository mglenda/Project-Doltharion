do
    Absorbs = setmetatable({}, {})
    local a = getmetatable(Absorbs)
    a.__index = a

    local data = {}
    local seed = {}

    function a:apply(u,v,p)
        if Utils:type(data[u]) ~= 'table' then data[u] = {} end
        if Utils:type(seed[u]) ~= 'table' then seed[u] = {1} end
        local id = seed[u][1] 
        seed[u][1] = seed[u][1] >= 10000 and 1 or seed[u][1] + 1
        table.insert(data[u], {v = v,p = p or 10,id = id})
        table.sort(data[u], function (k1, k2) return k1.v > k2.v end)
        table.sort(data[u], function (k1, k2) return k1.p < k2.p end)
        TextTag:create({u=u,s=StringUtils:round(v,1) .. ' Absorbs',ls = 1.5,r = 75.0,g = 75.0,b = 255.0})
        return id
    end

    function a:damage(u,dmg)
        if Utils:type(data[u]) == 'table' then
            for i = #data[u],1,-1 do
                if data[u][i].v < dmg then
                    dmg = dmg - data[u][i].v
                    table.remove(data[u], i)
                else
                    data[u][i].v = data[u][i].v - dmg
                    return 0,true
                end
            end
        end
        return dmg,false
    end

    function a:get_all(u)
        local r = 0
        if Utils:type(data[u]) == 'table' then
            for i,v in ipairs(data[u]) do
                r = r + v.v
            end
        end
        return r 
    end

    function a:exists(u,id)
        if Utils:type(data[u]) == 'table' then
            for i,v in ipairs(data[u]) do
                if v.id == id then return true end
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
                if data[u][i].id == id then table.remove(data[u],i) end
            end
        end
    end
end