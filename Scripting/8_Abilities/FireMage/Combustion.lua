do
    Combustion = setmetatable({}, {})
    local a = getmetatable(Combustion)
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
        return 8,170,0
    end

    function a:on_start()
        local c = GetTriggerUnit()
        local p = Utils:round(CastingTime:get(c,a_code) / BlzGetAbilityIntegerField(BlzGetUnitAbility(c, FourCC(a_code)), ABILITY_IF_MISSILE_SPEED) - 0.01,2)
        if GetUnitTypeId(c) == AnimMage:get_ut() then AnimationSeq:start(c,AnimMage:seq_spellchannel()) end
        table.insert(ct, {
            c=c
            ,p=p
            ,cp = 0.0
        })
        EnableTrigger(ctrg)
    end

    function a:on_end()
        local c = GetTriggerUnit()
        for i=#ct,1,-1 do
            if ct[i].c == c then table.remove(ct,i) end
        end
    end

    function a:channeling()
        for i=#ct,1,-1 do
            local t = ct[i]
            t.cp = Utils:round(t.cp + 0.01,2)
            local tx,ty = MouseCoords:get_xy()
            if t.cp >= t.p then 
                local tz = Utils:get_point_z(tx,ty)
                t.cp = 0.0
                Missile:create{
                    e_model = 'Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl'
                    ,e_scale = 2.0
                    ,spawn_offset = 100.0
                    ,caster = t.c
                    ,target_x = tx
                    ,target_y = ty
                    ,target_z = tz
                    ,speed = 18.0
                    ,a_phase = math.random() * 10 * math.pi
                    ,w_speed = 0.08 + math.random() * 0.08
                    ,w_radius = 10 + math.random() * 10
                    ,on_impact = function(m)
                        self:damage(m.caster,m.target_x,m.target_y,m.target_z)
                    end
                    
                }
            end
            Units:register_cast_point(t.c,tx,ty)
        end
        if #ct == 0 then DisableTrigger(ctrg) end
    end
    
    function a:damage(caster,x,y,z)
        local e = AddSpecialEffect('Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl', x, y)
        BlzSetSpecialEffectZ(e, z + 70.0)
        BlzSetSpecialEffectScale(e, 4.5)
        DestroyEffect(e)

        local aoe = BlzGetAbilityRealLevelField(BlzGetUnitAbility(caster, self:get_a_code()), ABILITY_RLF_AREA_OF_EFFECT, 0)
        e = AddSpecialEffect('Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl', x, y)
        BlzSetSpecialEffectScale(e, Utils:round(aoe / 250.0,2))
        BlzSetSpecialEffectZ(e, z)
        DestroyEffect(e)

        for _,u in ipairs(Units:get_area_alive_enemy(x,y,aoe,GetOwningPlayer(caster))) do
            DamageEngine:damage_unit{
                source = caster
                ,target = u
                ,damage = SpellPower:get(caster) * 2.5
                ,attack_type = ATTACK_TYPE_MAGIC
                ,damage_type = DAMAGE_TYPE_FIRE
                ,id = FourCC(a_code)
                ,data = {
                    after_damage = {
                        f = Buffs.apply,
                        params = table.pack(Buffs,caster,u,'ignited')
                    }
                }
            }
        end
    end

    OnInit.map(function()
        Data:register_ability_class(Combustion:get_a_code(),Combustion)
        TriggerRegisterTimerEventPeriodic(ctrg, 0.01)
        TriggerAddAction(ctrg, function() Combustion:channeling() end) 
    end)
end