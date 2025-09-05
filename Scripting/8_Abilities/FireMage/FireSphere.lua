do
    FireSphere = setmetatable({}, {})
    local a = getmetatable(FireSphere)
    a.__index = a

    local a_code = 'A016'
    local trg = CreateTrigger()
    local period = 0.1
    local spheres = {}

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
    
    function a:on_cast()
        local caster = GetTriggerUnit()
        local aoe = BlzGetAbilityRealLevelField(BlzGetUnitAbility(caster, GetSpellAbilityId()), ABILITY_RLF_AREA_OF_EFFECT, 0)
        local x,y = Units:get_cast_point_x(caster),Units:get_cast_point_y(caster)
        self:create_sphere(caster,x,y,aoe,12.0)
    end

    function a:create_sphere(caster,x,y,aoe,duration)
        local orb = AddSpecialEffect('war3mapImported\\Orb of Fire.mdx', x, y)
        BlzSetSpecialEffectScale(orb, 1.6)
        BlzPlaySpecialEffectWithTimeScale(orb, ANIM_TYPE_BIRTH, 0.4)
        local tbl = {
            caster = caster
            ,x = x
            ,y = y
            ,aoe = aoe
            ,orb = orb
            ,duration = duration
            ,tick = 6
            ,tick_missiles = 6
        }
        table.insert(spheres,tbl)
        if not(IsTriggerEnabled(trg)) then EnableTrigger(trg) end
    end

    function a:deal_damage(caster,x,y,aoe)
        local e = AddSpecialEffect('Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl', x, y)
        BlzSetSpecialEffectScale(e, Utils:round(aoe / 250.0,2))
        BlzSetSpecialEffectZ(e, Utils:get_point_z(x,y))
        DestroyEffect(e)
        for _,u in ipairs(Units:get_area_alive_enemy(x,y,aoe,GetOwningPlayer(caster))) do
            DamageEngine:damage_unit{
                source = caster
                ,target = u
                ,damage = SpellPower:get(caster) * 2.5
                ,attack_type = ATTACK_TYPE_MAGIC
                ,damage_type = DAMAGE_TYPE_FIRE
                ,id = FourCC(a_code)
            }
        end
    end

    function a:spawn_missiles(caster,x,y,z,aoe)
        for _,u in ipairs(Units:get_area_alive_enemy(x,y,aoe,GetOwningPlayer(caster))) do
            PhoenixBarrage:create_missile{
                caster = caster
                ,target = u
                ,spawn_x = x
                ,spawn_y = y
                ,spawn_z = z
                ,generate_energy = true
            }
        end
    end

    function a:tick()
        for i = #spheres,1,-1 do
            local t = spheres[i]
            if not(IsUnitAliveBJ(t.caster)) or t.duration <= 0 or not(Units:exists(t.caster)) then
                self:_remove(i)
            else
                if t.tick <= 0 then
                    t.tick = 8
                    self:deal_damage(t.caster,t.x,t.y,t.aoe)
                else
                    t.tick = t.tick - 1
                end
                if t.tick_missiles <= 0 then 
                    t.tick_missiles = 2
                    self:spawn_missiles(t.caster,t.x,t.y,BlzGetLocalSpecialEffectZ(t.orb) + 70.0,Abilities:get_cast_range(t.caster,Firebolt:get_a_code()))
                else
                    t.tick_missiles = t.tick_missiles - 1
                end
                t.duration = t.duration - period
            end
        end
        if #spheres == 0 then DisableTrigger(trg) end
    end

    function a:_remove(i)
        DestroyEffect(spheres[i].orb)
        table.remove(spheres,i)
    end

    function a:_flush()
        DisableTrigger(trg)
        for i=#spheres,1,-1 do
            self:_remove(i)
        end
    end

    OnInit.map(function()
        Data:register_ability_class(FireSphere:get_a_code(),FireSphere)
        TriggerRegisterTimerEventPeriodic(trg, period)
        TriggerAddAction(trg, function() FireSphere:tick() end)
    end)
end