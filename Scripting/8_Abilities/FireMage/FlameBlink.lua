do
    FlameBlink = setmetatable({}, {})
    local a = getmetatable(FlameBlink)
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

    function a:on_cast()
        local caster = GetTriggerUnit()
        local x,y = Units:get_cast_point_x(caster),Units:get_cast_point_y(caster)
        self:relocate(caster,x,y)
    end

    function a:relocate(u,x,y)
        Utils:set_unit_xy(u,x,y)
    end

    OnInit.map(function()
        Data:register_ability_class(FlameBlink:get_a_code(),FlameBlink)
    end)
end