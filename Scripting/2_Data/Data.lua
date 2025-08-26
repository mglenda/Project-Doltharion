do
    Data = setmetatable({}, {})
    local d = getmetatable(Data)
    d.__index = d

    local stats = {}

    OnInit.map(function()
        stats['resist'] = Resistance
        stats['critchance'] = CriticalChance
        stats['attpow_const'] = AttackPower
        stats['attpow_factor'] = AttackPower
        stats['spepow_const'] = SpellPower
        stats['spepow_factor'] = SpellPower
        stats['atkspeed'] = AttackSpeed
        stats['attdmg_const'] = AttackDamage
        stats['attdmg_factor'] = AttackDamage
        stats['hp_const'] = HitPoints
        stats['hp_factor'] = HitPoints
        stats['hpreg_const'] = HitPointsReg
        stats['hpreg_factor'] = HitPointsReg
        stats['ctime_const'] = CastingTime
        stats['ctime_factor'] = CastingTime
        stats['movespeed_const'] = MoveSpeed
        stats['movespeed_factor'] = MoveSpeed
    end)

    function d:get_stat_class(sn)
        return stats[sn]
    end

    local abilities = {}

    function d:register_ability_class(ac,class)
        abilities[ac] = class
    end

    function d:get_ability_class(ac)
        return abilities[ac]
    end

    function d:get_dmg_color(ac)
        if abilities[ac] and Utils:type(abilities[ac].get_dmg_color) == 'function' then
            return abilities[ac]:get_dmg_color()
        end
        return 255,76,76
    end

    local units = {}

    OnInit.map(function()
        units[FourCC('h004')] = {
            cl = PLAYER_COLOR_VIOLET
            ,wl = true
        }
        units[FourCC('h002')] = {
            cl = PLAYER_COLOR_LIGHT_BLUE
            ,wl = true
        }
        units[FourCC('h003')] = {
            cl = PLAYER_COLOR_WHEAT
            ,a_walk = 0
            ,p_tolerance = 2
            ,wl = true
        }
        units[FourCC('h001')] = {
            cl = PLAYER_COLOR_LIGHT_BLUE
            ,wl = true
        }
        units[FourCC('H000')] = {
            cl = PLAYER_COLOR_AQUA
            ,a_walk = 2
            ,p = 3
        }
        units[FourCC('H001')] = {
            cl = GetPlayerColor(Players:get_passive())
            ,p = 2
        }
        units[FourCC('h005')] = {
            cl = PLAYER_COLOR_MAROON
            ,patt = 2
            ,spower = 54.0
            ,crit = 25.0
            ,wl = true
            ,p_tolerance = 2
        }
    end)

    function d:get_unit_data(u)
        return units[u] or {}
    end

    function d:get_warband_list_data()
        local tbl = {}
        for ut,v in pairs(units) do
            if v.wl then 
                table.insert(tbl,{
                    ut = ut
                })
            end
        end
        return tbl
    end

    --reserved u,s,bn,dur,per,a_id
    --tc = text color :: defines color of stack text viac func BlzConvertColor(a, r, g, b), if not defined default value is used = BlzConvertColor(255, 255, 255, 255)
    --is_d = isdebuff :: true if it is negative debuff, not set or false if it is positive buff
    --d = duration :: number bigger than 0 to set buff duration, not set = infinite duration
    --prio = priority :: define what is priority of the buff by which it will be sorted for various actions, lower number = higher priority
    --e = effects_data :: table of effects which should be applied, each effect should have its own table containing m = model string path, a = attachment point, s = scale (optional)
    --es = effects_stack :: true each stack of buff applies effects, not set / false = effects will be applied only once per buff type, no matter how much stacks buff has
    --p = period :: defines period duration, can by function() which returns number or number
    --h = hidden :: true buff won't be displayed on unit panel, not set / false it will be displayed on unit panel
    --dp = death persistent :: true buff will not end on target death / false or not defined buff will end on target death
    --ms = max stacks :: integer number if defined then buff will have maximum of ms stacks / not defined buff will create new stack on each apply
    --nd = not dispellable :: true buff is not dispellable with dispells / not defined or false buff is dispellable with dispells
    --wp = warband panel :: true buff will be displayed on warband panel / not defined or fales it won't
    --func_a = apply func :: function which happens when buff is applied
    --func_p = period func :: function which happens on period end
    --func_q = quit func :: function which if returns true buff will expire
    --func_e = end func :: function which will always execute when buff expires
    --func_d = dispell func :: function which will execute if buff was dispelled
    --st = stats :: table containing all stats modified by buff, id of element should be name of stat to be modified, value of 
                  --element should be table containing: 
                  --value at 1st position 
                  --true/false at 2nd position to define wether effect stacks or no where true means it does stack and false/nil/undefined means it does not
                  --ability list at 3rd position which are affected by effect at 3rd position, false/nil means all abilities are affected
                  --Example: st = {['resist'] = {10,true}} = means this buff incrase resistance of unit by 10 per stack
                  --Example: st = {['resist'] = {5}}  = means this buff incrase resistance of unit by 5, does not stack
                  --Example: st = {['resist'] = {8,false}}  = means this buff incrase resistance of unit by 8, does not stack
        -- Stat_List ::
            -- 'resist' = Resistance
            -- 'critchance' = Critical Chance
            -- 'attpow_const' = Attack Power constant (+)
            -- 'attpow_factor' = Attack Power factor (*)
            -- 'spepow_const = Spell Power constant (+)
            -- 'spepow_factor' = Spell Power factor (*)
            -- 'atkspeed' = Attack Speed (0 - 4.0) where numbers bellow 1 are slow and above 1 are boost
            -- 'movespeed_const' = Moving Speed constant (+)
            -- 'movespeed_factor' = Moving Speed factor (*)
            -- 'attdmg_const' = Attack Damage constant (+)
            -- 'attdmg_factor' = Attack Damage factor (*)
            -- 'hp_const' = Hit Points constant (+)
            -- 'hp_factor' = Hit Points factor (*)
            -- 'hpreg_const' = Hit Points Regeneration constant (+)
            -- 'hpreg_factor' = Hit Points Regeneration factor (*)
            -- 'ctime_const' = Casting Time constant (+)
            -- 'ctime_factor' = Casting Time factor (-)
    local buffs = {}

    function d:get_buff(b)
        return buffs[b]
    end
    
    OnInit.map(function()
        buffs['pwshield'] = {
            e = {
                {m = 'war3mapImported\\Sacred Guard Gold.mdx',a = 'chest'}
            }
            ,d = 30
            ,func_a = function(bt)
                bt.a_id = Absorbs:apply(bt.s,bt.u,SpellPower:get(bt.s) * 3.0)
            end
            ,func_q = function(bt)
                return not(Absorbs:exists(bt.u,bt.a_id))
            end
            ,func_e = function(bt)
                local av = Absorbs:exists(bt.u,bt.a_id)
                if av then
                    Absorbs:clear(bt.u,bt.a_id)
                    Heal:unit(bt.s,bt.u,av*2.5)
                else
                    Buffs:apply(bt.s,bt.u,'innerfire')
                end
            end
            ,tc = BlzConvertColor(255, 0, 0, 0)
            ,wp = true
            ,prio = 9
        }
        buffs['innerfire'] = {
            e = {
                {m = 'Abilities\\Spells\\Human\\InnerFire\\InnerFireTarget.mdl',a = 'overhead'}
            }
            ,d = 8
            ,st = {
                ['atkspeed'] = {2.0,true}
                ,['ctime_factor'] = {0.75,true}
                ,['resist'] = {20}
                ,['critchance'] = {25}
            }
            ,wp = true
            ,prio = 10
            ,tc = BlzConvertColor(255, 0, 0, 0)
        }
        buffs['bloodlust'] = {
            e = {
                {m = 'Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl',a = 'overhead'}
            }
            ,d = 30
            ,st = {
                ['ctime_factor'] = {0.8,true}
                ,['atkspeed'] = {1.35,true}
            }
            ,wp = true
            ,prio = 8
        }
        buffs['united'] = {
            e = {
                {m = 'Abilities\\Spells\\Orc\\CommandAura\\CommandAura.mdl',a = 'origin'}
            }
            ,nd = true
            ,ms = 1
        }
        buffs['empired'] = {
            e = {
                {m = 'Abilities\\Spells\\Other\\GeneralAuraTarget\\GeneralAuraTarget.mdl',a = 'origin'}
            }
            ,nd = true
            ,ms = 1
            ,d = 1.2
        }
        buffs['painsupression'] = {
            e = {
                {m = 'war3mapImported\\Sacred Guard Blue.mdx',a = 'chest',s = 1.1}
            }
            ,d = 8
            ,st = {
                ['resist'] = {60,true}
            }
            ,wp = true
            ,prio = 7
            ,tc = BlzConvertColor(255, 0, 0, 0)
        }
        buffs['defend'] = {
            d = 6
            ,st = {
                ['resist'] = {40,true}
            }
            ,func_a = function(bt)
                AddUnitAnimationProperties(bt.u, "Defend", true)
            end
            ,func_e = function(bt)
                AddUnitAnimationProperties(bt.u, "Defend", false)
            end
        }
        buffs['eyeofheaven'] = {
            e = {
                {m = 'war3mapImported\\Rejuvenation.mdx',a = 'chest'}
            }
            ,st = {
                ['resist'] = {30,true}
                ,['hpreg_const'] = {70.0,true}
            }
            ,wp = true
            ,prio = 6
            ,tc = BlzConvertColor(255, 0, 0, 0)
        }
        buffs['fireball'] = {
            e = {
                {m = 'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',a = 'chest'}
            }
            ,prio = 10
            ,d = 9
            ,is_d = true
            ,p = function(bt)
                return Utils:round(CastingTime:get(bt.s,Fireball:get_a_string()),2)
            end
            ,func_p = function(bt)
                DamageEngine:damage_unit(bt.s,bt.u,Utils:round(SpellPower:get(bt.s) * 0.25,0),ATTACK_TYPE_MAGIC,DAMAGE_TYPE_FIRE,Fireball:get_a_code())
            end
            ,func_a = function(bt)
                Buffs:refresh_duration_all_stacks(bt.u,bt.bn)
            end
        }
        buffs['ignited'] = {
            d = 8
            ,e = {
                {m = 'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',a = 'chest'}
            }
            ,es = true
            ,st = {
                ['resist'] = {-1,true}
            }
            ,is_d = true
            ,prio = 5
            ,p = function(bt)
                return Utils:round(CastingTime:get(bt.s,Ignite:get_a_string()),2)
            end
            ,func_p = function(bt)
                DamageEngine:damage_unit{
                        source = bt.s
                        ,target = bt.u
                        ,damage = bt.dmg
                        ,attack_type = ATTACK_TYPE_MAGIC
                        ,damage_type = DAMAGE_TYPE_FIRE
                        ,id = Ignite:get_a_code()
                    }
            end
        }
    end)    
end