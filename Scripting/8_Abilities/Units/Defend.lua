do
    Defend = setmetatable({}, {})
    local d = getmetatable(Defend)
    d.__index = d

    local a_code = 'A010'

    function d:get_a_code()
        return FourCC(a_code)
    end

    function d:get_a_string()
        return a_code
    end

    function d:get_s_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function d:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function d:on_cast()
        Buffs:apply(GetTriggerUnit(),GetTriggerUnit(),'defend')
    end

    function d:on_ai_damaged(u)
        if GetUnitAbilityLevel(u, FourCC(a_code)) > 0 then
            local order = String2OrderIdBJ(BlzGetAbilityStringLevelField(BlzGetUnitAbility(u, FourCC(a_code)), ABILITY_SLF_BASE_ORDER_ID_NCL6, 0))
            IssueImmediateOrderById(u,order)
            return true
        end
        return false
    end

    OnInit.map(function()
        Data:register_ability_class(Defend:get_a_code(),Defend)
    end)
end