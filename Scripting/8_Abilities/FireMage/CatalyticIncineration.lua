do
    CatalyticIncineration = setmetatable({}, {})
    local a = getmetatable(CatalyticIncineration)
    a.__index = a

    local a_code = 'A020'
    local a_group = {}
    local a_trg = CreateTrigger()
    local missile_classes = {}

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

    function a:on_start()
        local c = GetTriggerUnit()
        if GetUnitTypeId(c) == AnimMage:get_ut() then AnimationSeq:start(c,AnimMage:seq_spellchannel()) end

        local i = Utils:get_key_by_value(a_group,'caster',c)
        if i then
            if Utils:type(a_group[i].orb) == 'effect' then DestroyEffect(a_group[i].orb) end
            table.remove(a_group,i)
        end

        local x,y = Utils:GetUnitXY(c)
        local z = Utils:get_unit_impact_z(c)
        local t = Utils:round(CastingTime:get(c,a_code),2)
        local z_offset = 120.0
        local shoot_interval = 10 --Every 0.1 second, 100 = 1 Second, 1 = 0.01 second ect.
        table.insert(a_group,{
            caster = c
            ,ready = false
            ,orb = EffectAnimation:create_xyz(
                'war3mapImported\\Orb of Fire.mdx' --effect model
                ,x --x 
                ,y --y 
                ,z + z_offset --z 
                ,0.9 --scale to reach
                ,t --time of scaling (casting time)
            )
            ,z_offset = z_offset
            ,tick = shoot_interval
            ,tick_base = shoot_interval
            ,cast_range = Abilities:get_cast_range(c,self:get_a_code())
        })
    end

    function a:on_end()
        local c = GetTriggerUnit()
        local i = Utils:get_key_by_value(a_group,'caster',c)
        if i and not(a_group[i].ready) then
            DestroyEffect(a_group[i].orb)
            table.remove(a_group,i)
        end
    end

    function a:on_cast()
        local c = GetSpellAbilityUnit()
        local t = Units:get_cast_target(c)
        local i = Utils:get_key_by_value(a_group,'caster',c)
        a_group[i].target = t
        a_group[i].ready = true
        a_group[i].energy_cost_per_missile = 1
        a_group[i].energy_cost_per_missile_increment = 1
        a_group[i].energy_cost_per_missile_max = 10
        a_group[i].energy_cost_increment_per_missle_count = 5
        a_group[i].missle_count = 0
        --
        Buffs:apply(c,c,'cataclysed')
        EnableTrigger(a_trg)
    end

    function a:periodic()
        for i=#a_group,1,-1 do
            local tbl = a_group[i]
            local x,y = Utils:GetUnitXY(tbl.caster)
            local z = Utils:get_unit_impact_z(tbl.caster) + tbl.z_offset
            Utils:set_special_effect_xyz(tbl.orb,x,y,z)
            if tbl.ready then
                if Units:exists(tbl.target) and IsUnitAliveBJ(tbl.target) and Utils:get_unit_distance(x,y,tbl.target) <= tbl.cast_range and Hero:get_energy() >= tbl.energy_cost_per_missile then
                    if tbl.tick <= 0 then
                        local m_class = missile_classes[GetRandomInt(1, #missile_classes)]
                        m_class:create_missile{
                            caster = tbl.caster
                            ,target = tbl.target
                            ,spawn_z = z + 20.0
                            ,spawn_x = x
                            ,spawn_y = y
                            ,generate_energy = true
                        }
                        Hero:add_energy(-tbl.energy_cost_per_missile)
                        tbl.tick = tbl.tick_base
                        tbl.missle_count = tbl.missle_count + 1
                        if Utils:mod(tbl.missle_count,tbl.energy_cost_increment_per_missle_count) == 0 and tbl.energy_cost_per_missile < tbl.energy_cost_per_missile_max then 
                            tbl.energy_cost_per_missile = tbl.energy_cost_per_missile + tbl.energy_cost_per_missile_increment
                        end
                    else
                        tbl.tick = tbl.tick - 1
                    end
                else
                    DestroyEffect(tbl.orb)
                    Buffs:clear_buff{
                        unit = tbl.caster
                        ,buff_name = 'cataclysed'
                    }
                    table.remove(a_group,i)
                end
            end
        end
        if #a_group == 0 then DisableTrigger(a_trg) end
    end

    OnInit.map(function()
        Data:register_ability_class(CatalyticIncineration:get_a_code(),CatalyticIncineration)
        TriggerRegisterTimerEventPeriodic(a_trg, 0.01)
        TriggerAddAction(a_trg, function() CatalyticIncineration:periodic() end) 
        table.insert(missile_classes,Firebolt)
        table.insert(missile_classes,PhoenixBarrage)
    end)
end