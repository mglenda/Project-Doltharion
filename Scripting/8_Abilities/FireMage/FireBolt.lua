do
    Firebolt = setmetatable({}, {})
    local f = getmetatable(Firebolt)
    f.__index = f

    local a_code = 'A015'
    local mtrg = CreateTrigger()
    local mt = {}

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

    function f:on_cast()
        local c = GetSpellAbilityUnit()
        local t = Units:get_cast_target(c)
        local m = Missile:create{
            e_model = 'war3mapImported\\Firebolt.mdx'
            ,e_scale = 1.2
            ,spawn_x = GetUnitX(c)
            ,spawn_y = GetUnitY(c)
            ,spawn_z = Utils:get_unit_impact_z(c)
            ,target = t
            ,speed = 14.0
            ,a_phase = math.random() * 30 * math.pi
            ,w_speed = 0.08 + math.random() * 0.08
            ,w_radius = 30 + math.random() * 20
        }

        table.insert(mt,{
            m = m,
            c = c,
            t = t
        })
        EnableTrigger(mtrg)
    end
    
    function f:missle_fly()
        for i = #mt,1,-1 do
            local ude = not Units:exists(mt[i].t)
            local mis = mt[i].m
            if mis:get_distance_from_traget() <= 30.0 or ude then
                if not ude and IsUnitAliveBJ(mt[i].t) then
                    --Target Hit Functionality
                    local target = mt[i].t
                    local caster = mt[i].c
                    DamageEngine:damage_unit{
                        source = caster
                        ,target = target
                        ,damage = SpellPower:get(caster) * 2.0
                        ,attack_type = ATTACK_TYPE_MAGIC
                        ,damage_type = DAMAGE_TYPE_FIRE
                        ,id = FourCC(a_code)
                        ,data = {
                            on_crit = {
                                f = Ignite.apply,
                                params = table.pack(Ignite,caster,target)
                            }
                        }
                    }
                end
                mis:destroy()
                table.remove(mt,i)
            else
                mis:move()
            end
        end
        if #mt == 0 then DisableTrigger(mtrg) end
    end

    OnInit.map(function()
        Data:register_ability_class(Firebolt:get_a_code(),Firebolt)
        TriggerRegisterTimerEventPeriodic(mtrg, 0.01)
        TriggerAddAction(mtrg, Firebolt.missle_fly)
    end)
end