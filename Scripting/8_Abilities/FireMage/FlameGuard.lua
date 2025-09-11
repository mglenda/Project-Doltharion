do
    FlameGuard = setmetatable({}, {})
    local a = getmetatable(FlameGuard)
    a.__index = a

    local a_code = 'A021'

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

    function a:on_stunned(args)
        if Utils:type(args.caster) == 'unit' then
            Buffs:apply(args.caster,args.caster,'flameguard')
        end
    end

    OnInit.map(function()
        Data:register_ability_class(FlameGuard:get_a_code(),FlameGuard)
    end)
end