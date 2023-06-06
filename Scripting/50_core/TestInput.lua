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
    end)
end