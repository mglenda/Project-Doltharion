do
    CodoWave = setmetatable({}, {})
    local a = getmetatable(CodoWave)
    a.__index = a

    local a_code = 'A018'
    local ct = {}
    local ctrg = CreateTrigger()

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
        return 139,69,19
    end

    OnInit.map(function()
        Data:register_ability_class(CodoWave:get_a_code(),CodoWave)
    end)
end