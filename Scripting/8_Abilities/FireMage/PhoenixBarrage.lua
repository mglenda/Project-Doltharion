do
    PhoenixBarrage = setmetatable({}, {})
    local a = getmetatable(PhoenixBarrage)
    a.__index = a

    local a_code = 'A019'
    local damage_factor = 2.5
    local energy_gain = 2
    local critical_energy_gain = 6
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
        return 204,0,204
    end

    function a:get_damage(caster)
        return SpellPower:get(caster) * damage_factor
    end

    function a:get_tooltip_values(caster)
        return {
            damage = self:get_damage(caster),
            missile_count = BlzGetAbilityIntegerField(BlzGetUnitAbility(caster,self:get_a_code()),ABILITY_IF_MISSILE_SPEED),
            energy_gain = energy_gain,
            critical_energy_gain = critical_energy_gain
        }
    end

    function a:on_start()
        local c = GetTriggerUnit()
        local p = Utils:round(CastingTime:get(c,a_code) / BlzGetAbilityIntegerField(BlzGetUnitAbility(c, FourCC(a_code)), ABILITY_IF_MISSILE_SPEED) - 0.01,2)
        if GetUnitTypeId(c) == AnimMage:get_ut() then AnimationSeq:start(c,AnimMage:seq_spellchannel()) end
        table.insert(ct, {
            c=c
            ,p=p
            ,t=GetSpellTargetUnit()
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
            if IsUnitDeadBJ(t.t) then IssueImmediateOrderById(t.c, String2OrderIdBJ('stop')) end
            t.cp = Utils:round(t.cp + 0.01,2)
            if t.cp >= t.p then 
                t.cp = 0.0
                self:create_missile{
                    caster = t.c
                    ,target = t.t
                    ,spawn_z = Utils:get_unit_impact_z(t.c) + 20.0
                    ,generate_energy = true
                }
            end
        end
        if #ct == 0 then DisableTrigger(ctrg) end
    end

    function a:create_missile(args)
        Missile:create{
            e_model = 'Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl'
            ,e_scale = 1.5
            ,spawn_offset = 100.0
            ,caster = args.caster
            ,target = args.target
            ,generate_energy = args.generate_energy
            ,spawn_x = args.spawn_x
            ,spawn_y = args.spawn_y
            ,spawn_z = args.spawn_z
            ,speed = 12.0
            ,a_phase = math.random() * 15 * math.pi
            ,w_speed = 0.08 + math.random() * 0.08
            ,w_radius = 20 + math.random() * 20
            ,on_impact = function(m)
                self:damage(m.caster,m.target,m.generate_energy)
            end
        }
    end
    
    function a:damage(caster,target,generate_energy)
        DamageEngine:damage_unit{
            source = caster
            ,target = target
            ,damage = self:get_damage(caster)
            ,attack_type = ATTACK_TYPE_MAGIC
            ,damage_type = DAMAGE_TYPE_FIRE
            ,id = FourCC(a_code)
            ,data = {
                generate_energy = generate_energy
            }
        }
    end

    function a:on_damage(args)
        if args.damage_id == self:get_a_code() then
            if args.custom_data.generate_energy then Hero:add_energy(args.damage_was_crit and critical_energy_gain or energy_gain) end
            if GetUnitAbilityLevel(args.damage_source, HeartOfPhoenix:get_a_code()) > 0 and Buffs:get_stack_count(args.damage_target,'ignited') >= 10 then
                HeartOfPhoenix:apply_buff(args.damage_source)
            end
            Buffs:clear_buff{
                unit = args.damage_target
                ,buff_name = 'ignited'
            }
        end
    end

    OnInit.map(function()
        Data:register_ability_class(PhoenixBarrage:get_a_code(),PhoenixBarrage)
        TriggerRegisterTimerEventPeriodic(ctrg, 0.01)
        TriggerAddAction(ctrg, function() PhoenixBarrage:channeling() end) 
    end)
end
