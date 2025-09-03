do
    Ignite = setmetatable({}, {})
    local a = getmetatable(Ignite)
    a.__index = a

    local a_code = 'A017'

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

    OnInit.map(function()
        Data:register_ability_class(Ignite:get_a_code(),Ignite)
    end)
end