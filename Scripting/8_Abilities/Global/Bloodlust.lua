do
    Bloodlust = setmetatable({}, {})
    local b = getmetatable(Bloodlust)
    b.__index = b

    local a_code = 'A001'

    function b:get_a_code()
        return FourCC(a_code)
    end

    function b:get_a_string()
        return a_code
    end

    function b:get_s_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function b:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function b:get_tooltip_values()
        local buff = Data:get_buff('bloodlust')
        return {
            duration = buff.d,
            attack_speed = (buff.st.atkspeed[1] - 1) * 100,
            cast_speed = (1 - buff.st.ctime_factor[1]) * 100
        }
    end

    function b:on_cast()
        local aoe = BlzGetAbilityRealLevelField(BlzGetUnitAbility(GetTriggerUnit(), GetSpellAbilityId()), ABILITY_RLF_AREA_OF_EFFECT, 0)
        local x,y = Utils:GetUnitXY(GetTriggerUnit())
        for _,u in ipairs(Units:get_area_alive_ally(x,y,aoe,GetOwningPlayer(GetTriggerUnit()))) do
            Buffs:apply(GetTriggerUnit(),u,'bloodlust')
        end
    end

    OnInit.map(function()
        Data:register_ability_class(Bloodlust:get_a_code(),Bloodlust)
    end)
end
