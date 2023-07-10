do
    PowerWordShield = setmetatable({}, {})
    local pws = getmetatable(PowerWordShield)
    pws.__index = pws

    local a_code = 'A000'

    function pws:get_a_code()
        return FourCC(a_code)
    end

    function pws:get_a_string()
        return a_code
    end

    function pws:get_s_color()
        return BlzConvertColor(255, 0, 0, 0)
    end

    function pws:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function pws:on_cast()
        local aoe = BlzGetAbilityRealLevelField(BlzGetUnitAbility(GetTriggerUnit(), GetSpellAbilityId()), ABILITY_RLF_AREA_OF_EFFECT, 0)
        local x,y = Units:get_cast_point_x(GetTriggerUnit()),Units:get_cast_point_y(GetTriggerUnit())
        local eff = AddSpecialEffect('war3mapImported\\Empyrean Nova.mdx', x, y)
        BlzSetSpecialEffectScale(eff, Utils:round(aoe / 350.0,2))
        DestroyEffect(eff)
        for _,u in ipairs(Units:get_area_alive(x,y,aoe)) do
            if IsUnitEnemy(u, GetOwningPlayer(GetTriggerUnit())) then
                DamageEngine:damage_unit(GetTriggerUnit(),u,SpellPower:get(GetTriggerUnit()) * 2.5,ATTACK_TYPE_MAGIC,DAMAGE_TYPE_DIVINE,FourCC(a_code))
            else
                Buffs:apply(GetTriggerUnit(),u,'pwshield')
                Heal:unit(GetTriggerUnit(),u,SpellPower:get(GetTriggerUnit()) * 4.0)
            end
        end
    end

    OnInit.map(function()
        Data:register_ability_class(PowerWordShield:get_a_code(),PowerWordShield)
    end)
end