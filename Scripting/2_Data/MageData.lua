do
    OnInit.map(function()
        -----------------------------------------
        ----------------Modifiers----------------
        -----------------------------------------
        --use mod_ for modifiers naming, stats recalculations are combining buffs with modifiers and uses their names as identificator for stack logic
        --make sure none of buffs / mods use same name
        Data:register_modifier(
            'mod_test' 
            ,{
                m_stats = {
                    ['resist'] = {40}
                    ,['critchance'] = {25}
                    ,['spepow_const'] = {50}
                    ,['ctime_factor'] = {0.5,{CatalyticIncineration:get_a_string()}}
                }
                ,m_prio = 1
                ,m_effects = {
                    {e_model = 'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',e_attpoint = 'right hand'}
                    ,{e_model = 'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',e_attpoint = 'left hand'}
                }
            }
        )


        -----------------------------------------
        -----------------Buffs-------------------
        -----------------------------------------
        Data:register_buff(
            'ignited'
            ,{
                e = {
                    {m = 'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',a = 'chest'}
                }
                ,st = {
                    --['dmg_bonus_value'] = {500,true,{Firebolt:get_a_string()}}
                    --['dmg_bonus_factor'] = {2.5,true,{Firebolt:get_a_string()}}
                    ['dmg_bonus_const'] = {0.1,true,{PhoenixBarrage:get_a_string()}}
                }
                ,is_d = true
                ,prio = 5
                ,ms = 10
            }
        )
        Data:register_buff(
            'cataclysed'
            ,{
                prio = 2
                ,ms = 1
                ,func_a = function(bt)
                    Abilities:add_silence{
                        unit = bt.u
                        ,s_key = 'cataclysed'
                        ,a_code = CatalyticIncineration:get_a_code()
                    }
                end
                ,func_e = function(bt)
                    Abilities:clear_silence{
                        unit = bt.u
                        ,s_key = 'cataclysed'
                    }
                end
            }
        )
        Data:register_buff(
            'melted'
            ,{
                prio = 4
                ,ms = 2
                ,d = 10.0
                ,e = {
                    {m = 'Abilities\\Spells\\Other\\Doom\\DoomTarget.mdl',a = 'origin'}
                }
                ,is_d = true
                ,st = {
                    ['movespeed_factor'] = {0.5,true}
                }
            }
        )
        Data:register_buff(
            'flameguard'
            ,{
                prio = 2
                ,ms = 1
                ,d = 4.0
                ,e = {
                    {m = 'Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedTarget.mdl',a = 'chest'}
                }
                ,st = {
                    ['resist'] = {80}
                    ,['hpreg_const'] = {200}
                }
            }
        )
        Data:register_buff(
            'hophoenix'
            ,{
                prio = 4
                ,ms = 5
                ,d = 6.0
                ,st = {
                    ['hpreg_const'] = {20,true}
                }
                ,e = {
                    {m = 'Abilities\\Spells\\Other\\Incinerate\\IncinerateBuff.mdl',a = 'chest'}
                }
                ,es = true
            }
        )
        Data:register_buff(
            'sophoenix'
            ,{
                e = {
                    {m = 'war3mapImported\\Sacred Guard Fire.mdx',a = 'chest'}
                }
                ,d = 30
                ,func_a = function(bt)
                    bt.a_id = Absorbs:apply(bt.s,bt.u,500.0)
                end
                ,func_q = function(bt)
                    return not(Absorbs:exists(bt.u,bt.a_id))
                end
                ,func_e = function(bt)
                    local av = Absorbs:exists(bt.u,bt.a_id)
                    if av then
                        Absorbs:clear(bt.u,bt.a_id)
                    end
                end
                ,st = {
                    ['spepow_factor'] = {1.25}
                    ,['hpreg_const'] = {10,true}
                }
                ,prio = 3
            }
        )
    end)
end