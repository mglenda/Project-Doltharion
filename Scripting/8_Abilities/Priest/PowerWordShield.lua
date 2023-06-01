do
    PowerWordShield = setmetatable({}, {})
    local pws = getmetatable(PowerWordShield)
    pws.__index = pws

    local a_code = 'A000'
    local a_code_dot = 'A002'

    function pws:get_a_code_dot()
        return a_code_dot
    end

    function pws:get_a_code()
        return a_code
    end

    function pws:on_cast()
        local aoe = BlzGetAbilityRealLevelField(BlzGetUnitAbility(GetTriggerUnit(), GetSpellAbilityId()), ABILITY_RLF_AREA_OF_EFFECT, 0)
        local x,y = AllUnits:get_cast_point_x(GetTriggerUnit()),AllUnits:get_cast_point_y(GetTriggerUnit())
        for _,u in ipairs(AllUnits:get_area_alive_ally(x,y,aoe,GetOwningPlayer(GetTriggerUnit()))) do
            Buffs:apply(GetTriggerUnit(),u,'pwshield')
        end
    end

    function pws:is_casted()
        return GetSpellAbilityId() == FourCC(PowerWordShield:get_a_code())
    end

    OnInit.final(function()
        local trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_FINISH)
        TriggerAddCondition(trg, Condition(PowerWordShield.is_casted))
        TriggerAddAction(trg, PowerWordShield.on_cast)
    end)
end