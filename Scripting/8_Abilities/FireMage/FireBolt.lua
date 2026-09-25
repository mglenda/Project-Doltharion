do
    Firebolt = setmetatable({}, {})
    local f = getmetatable(Firebolt)
    f.__index = f

    local a_code = 'A015'
    local damage_factor = 5.0
    local ignited_stacks = 2
    local energy_gain = 6
    local critical_energy_gain = 10

    function f:get_a_code()
        return FourCC(a_code)
    end

    function f:get_a_string()
        return a_code
    end

    function f:get_s_color()
        return BlzConvertColor(255, 0, 0, 0)
    end

    function f:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end
    
    function f:get_dmg_color()
        return 255,215,0
    end

    function f:get_damage(caster)
        return SpellPower:get(caster) * damage_factor
    end

    function f:get_tooltip_values(caster)
        return {
            damage = self:get_damage(caster),
            ignite_stacks = ignited_stacks,
            energy_gain = energy_gain,
            critical_energy_gain = critical_energy_gain
        }
    end

    function f:on_start()
        local c = GetTriggerUnit()
        if GetUnitTypeId(c) == AnimMage:get_ut() then 
            AnimationSeq:start(
                c
                ,AnimMage:seq_spellcast()
                ,Utils:round(CastingTime:get(c,a_code),2)
            )
        end
    end

    function f:on_cast()
        local c = GetSpellAbilityUnit()
        local t = Units:get_cast_target(c)
        self:create_missile{
            caster = c
            ,target = t
            ,spawn_z = Utils:get_unit_impact_z(c) + 20.0
        }
    end

    function f:create_missile(args)
        Missile:create{
            e_model = 'Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl'
            ,e_scale = 1.2
            ,spawn_offset = 100.0
            ,caster = args.caster
            ,target = args.target
            ,spawn_x = args.spawn_x
            ,spawn_y = args.spawn_y
            ,spawn_z = args.spawn_z
            ,speed = 14.0
            ,a_phase = math.random() * 30 * math.pi
            ,w_speed = 0.08 + math.random() * 0.08
            ,w_radius = 30 + math.random() * 20
            ,on_impact = function(m)
                self:damage(m.caster,m.target)
            end
        }
    end

    function f:on_damage(args)
        if args.damage_id == self:get_a_code() then
            Hero:add_energy(args.damage_was_crit and critical_energy_gain or energy_gain)
            for i=1,ignited_stacks,1 do
                Buffs:apply(args.damage_source
                        ,args.damage_target
                        ,'ignited'
                )
            end
        end
    end

    function f:damage(caster,target)
        DamageEngine:damage_unit{
            source = caster
            ,target = target
            ,damage = self:get_damage(caster)
            ,attack_type = ATTACK_TYPE_MAGIC
            ,damage_type = DAMAGE_TYPE_FIRE
            ,id = FourCC(a_code)
        }
    end

    OnInit.map(function()
        Data:register_ability_class(Firebolt:get_a_code(),Firebolt)
    end)
end
