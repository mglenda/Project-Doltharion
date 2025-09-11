do
    HeartOfPhoenix = setmetatable({}, {})
    local a = getmetatable(HeartOfPhoenix)
    a.__index = a

    local a_code = 'A022'

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

    function a:apply_buff(unit)
        if Buffs:get_stack_count(unit,'hophoenix') >= Data:get_buff('hophoenix').ms then
            self:summon_phoenix(unit)
            Buffs:clear_buff{
                unit = unit
                ,buff_name = 'hophoenix'
                ,all_stacks = true
            }
        else
            Buffs:apply(unit,unit,'hophoenix')
        end
    end

    function a:summon_phoenix(unit)
        local x,y = Utils:GetUnitXY(unit)
        local z = Utils:get_unit_impact_z(unit) + 100.0
        local e = AddSpecialEffect('units\\human\\phoenix\\phoenix', x, y)
        local f = GetUnitFacing(unit)
        BlzSetSpecialEffectZ(e, z)
        BlzSetSpecialEffectScale(e, 1.6)
        BlzPlaySpecialEffect(e, ANIM_TYPE_BIRTH)
        BlzSetSpecialEffectYaw(e, f * bj_DEGTORAD)
        BlzSetSpecialEffectColorByPlayer(e, Players:get_passive())
        BlzSetSpecialEffectAlpha(e, 25.0)

        Buffs:apply(unit,unit,'sophoenix')
        WaitAndDo:register{
            duration = 0.6
            ,on_end = {
                func = function()
                    BlzSetSpecialEffectScale(e, 0.01)
                    DestroyEffect(e)
                end
            }
        }
    end

    OnInit.map(function()
        Data:register_ability_class(HeartOfPhoenix:get_a_code(),HeartOfPhoenix)
    end)
end