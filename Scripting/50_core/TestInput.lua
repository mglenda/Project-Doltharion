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
        TriggerRegisterPlayerChatEvent(trg, Players:get_player(), "c", true)
        TriggerAddAction(trg, function()
            for u,_ in pairs(Units:get_all()) do
                if GetUnitTypeId(u) == FourCC('h003') then
                    print(tostring(Charge:ai_cast(u)))
                end
            end
        end)
    end)
end