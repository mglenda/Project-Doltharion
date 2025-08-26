do
    Ignite = setmetatable({}, {})
    local a = getmetatable(Ignite)
    a.__index = a

    local a_code = 'A017'
    local units = {}

    function a:get_a_code()
        return FourCC(a_code)
    end

    function a:get_a_string()
        return a_code
    end

    function a:get_s_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function a:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function a:get_dmg_color()
        return 255,215,0
    end

    function a:apply(caster,target,damage)
        local dmg = damage * (Utils:round(CastingTime:get_default(caster,a_code),2) / Data:get_buff('ignited').d)
        Buffs:apply(caster
                    ,target
                    ,'ignited'
                    ,{
                        dmg = dmg
                        ,func_e = function(bt)
                            Ignite:clear(bt.s,bt.u)
                        end
                    })
        self:add(caster,target)
    end

    function a:add(caster,target)
        units[caster] = units[caster] or {}
        for i,u in ipairs(units[caster]) do
            if u == target then return end
        end
        table.insert(units[caster],target)
    end

    function a:clear(caster,target)
        if Utils:type(units[caster]) == 'table' and not(Buffs:unit_has_buff(target,'ignited'))then
            for i=#units[caster],1,-1 do
                if units[caster][i] == target then
                    table.remove(units[caster],i)
                end
            end
            if #units[caster] == 0 then units[caster] = nil end
        end
    end

    function a:get_units(caster)
        return units[caster] or {}
    end

    OnInit.map(function()
        Data:register_ability_class(Ignite:get_a_code(),Ignite)
    end)
end