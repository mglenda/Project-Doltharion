do
    PainSupression = setmetatable({}, {})
    local ps = getmetatable(PainSupression)
    ps.__index = ps

    local a_code = 'A008'

    function ps:get_a_code()
        return FourCC(a_code)
    end

    function ps:get_a_string()
        return a_code
    end

    function ps:get_s_color()
        return BlzConvertColor(255, 0, 0, 0)
    end

    function ps:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function ps:on_cast()
        local c = GetSpellAbilityUnit()
        local t = Units:get_cast_target(c)
        if IsUnitAliveBJ(t) then 
            Buffs:apply(c,t,'painsupression')
        end
    end

    OnInit.map(function()
        Data:register_ability_class(PainSupression:get_a_code(),PainSupression)
    end)
end