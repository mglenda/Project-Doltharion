do
    OnInit.final(function()
        local trg = CreateTrigger()
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "start", true)
        TriggerAddAction(trg, function()
            Arena:start(1)
        end)
        trg = CreateTrigger()
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "stop", true)
        TriggerAddAction(trg, function()
            Arena:stop(1)
        end)
        trg = CreateTrigger()
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "s", true)
        TriggerAddAction(trg, function()
            Abilities:add_silence{
                unit = Hero:get()
                ,s_key = 'my_key'
            }
            --AnimationSeq:start(Hero:get(),AnimMage:seq_spellcast()) 
        end)
        trg = CreateTrigger()
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "h", true)
        TriggerAddAction(trg, function()
            Abilities:clear_silence{
                unit = Hero:get()
            }
        end)

        trg = CreateTrigger()
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "head", true)
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "origin", true)
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "left hand", true)
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "right hand", true)
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "right foot", true)
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "left foot", true)
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "chest", true)
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "weapon", true)
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "overhead", true)
        TriggerAddAction(trg, function()
            local eff = AddSpecialEffectTarget('Abilities\\Spells\\Human\\ManaFlare\\ManaFlareTarget.mdl', Hero:get(), GetEventPlayerChatString())
            BlzSetSpecialEffectScale(eff, 2)
        end)

        trg = CreateTrigger()
        for i=0,40,1 do
           TriggerRegisterPlayerChatEvent(trg, Players:get_player(), tostring(i), true) 
        end
        TriggerAddAction(trg, function()
            local index = S2I(GetEventPlayerChatString())
            --SetUnitAnimationByIndex(Hero:get(), index)
            AnimationSeq:start(Hero:get(),AnimMage:spell_combo_x_hits(index)) 
        end)
        

        --[[TimerStart(CreateTimer(),0,false, function()
            print("Create Keys")
            for index = 8,255 do
                local trigger = CreateTrigger()
                TriggerAddAction(trigger, function()
                    print("OsKey:",index, "meta",BlzGetTriggerPlayerMetaKey())
                end)
                local key = ConvertOsKeyType(index)
                for metaKey = 0,15,1 do
                    BlzTriggerRegisterPlayerKeyEvent(trigger, Player(0), key, metaKey, true)
                    BlzTriggerRegisterPlayerKeyEvent(trigger, Player(0), key, metaKey, false)
                end
            end
            print("Done")
        end)]]--
    end)
end