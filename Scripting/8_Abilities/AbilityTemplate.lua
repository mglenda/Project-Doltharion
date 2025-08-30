do
    AbilityTemplate = setmetatable({}, {})
    local a = getmetatable(AbilityTemplate)
    a.__index = a

    local a_code = 'A016'

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
        return 236,121,5
    end

    OnInit.map(function()
        Data:register_ability_class(AbilityTemplate:get_a_code(),AbilityTemplate)
    end)
end