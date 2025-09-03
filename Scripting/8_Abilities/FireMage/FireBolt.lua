do
    Firebolt = setmetatable({}, {})
    local f = getmetatable(Firebolt)
    f.__index = f

    local a_code = 'A015'

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

    function f:damage_event(caster,target)
        Hero:add_energy(6)
        for i=1,2,1 do
            Buffs:apply(caster
                    ,target
                    ,'ignited'
            )
        end
    end

    function f:damage(caster,target)
        DamageEngine:damage_unit{
            source = caster
            ,target = target
            ,damage = SpellPower:get(caster) * 5.0
            ,attack_type = ATTACK_TYPE_MAGIC
            ,damage_type = DAMAGE_TYPE_FIRE
            ,id = FourCC(a_code)
            ,data = {
                on_crit = {
                    f = Hero.add_energy,
                    params = table.pack(Hero,4)
                }
                ,after_damage = {
                    f = Firebolt.damage_event,
                    params = table.pack(Firebolt,caster,target)
                }
            }
        }
    end

    OnInit.map(function()
        Data:register_ability_class(Firebolt:get_a_code(),Firebolt)
    end)
end