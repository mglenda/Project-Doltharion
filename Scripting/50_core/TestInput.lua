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
            WarbandJournal:show()
        end)
        trg = CreateTrigger()
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "h", true)
        TriggerAddAction(trg, function()
            WarbandJournal:hide()
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