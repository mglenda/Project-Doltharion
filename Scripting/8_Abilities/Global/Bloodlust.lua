do
    Bloodlust = setmetatable({}, {})
    local b = getmetatable(Bloodlust)
    b.__index = b

    local a_code = 'A001'

    function b:get_a_code()
        return FourCC(a_code)
    end

    function b:get_s_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function b:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function b:on_cast()
        Buffs:apply(GetTriggerUnit(),GetTriggerUnit(),'bloodlust')
    end

    OnInit.map(function()
        Data:register_ability_class(Bloodlust:get_a_code(),Bloodlust)
    end)
end