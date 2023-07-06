do
    FlashHeal = setmetatable({}, {})
    local fh = getmetatable(FlashHeal)
    fh.__index = fh

    local a_code = 'A007'

    function fh:get_a_code()
        return FourCC(a_code)
    end

    function fh:get_s_color()
        return BlzConvertColor(255, 0, 0, 0)
    end

    function fh:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function fh:on_cast()
        local c = GetSpellAbilityUnit()
        local t = Units:get_cast_target(c)
        if IsUnitAliveBJ(t) then 
            AddSpecialEffectTargetUnitBJ('chest', t, 'Abilities\\Spells\\Human\\Heal\\HealTarget.mdl')
            Heal:unit(c,t,SpellPower:get(c) * 2.5)
            Abilities:add_to_cooldown(c,PainSupression:get_a_code(),-3.0)
        end
    end

    OnInit.map(function()
        Data:register_ability_class(FlashHeal:get_a_code(),FlashHeal)
    end)
end