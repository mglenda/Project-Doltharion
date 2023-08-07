do
    LightingSpheres = setmetatable({}, {})
    local ls = getmetatable(LightingSpheres)
    ls.__index = ls

    local a_code = 'A014'
    local trg = CreateTrigger()
    local t = {}

    function ls:get_a_code()
        return FourCC(a_code)
    end

    function ls:get_a_string()
        return a_code
    end

    function ls:get_s_color()
        return BlzConvertColor(255, 0, 0, 0)
    end

    function ls:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    OnInit.map(function()
        Data:register_ability_class(LightingSpheres:get_a_code(),LightingSpheres)
    end)
end