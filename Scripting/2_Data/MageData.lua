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
                ,es = true
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
    end)
end