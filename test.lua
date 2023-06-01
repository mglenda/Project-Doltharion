gg_trg_Untitled_Trigger_001 = nil
function InitGlobals()
end

function Trig_Untitled_Trigger_001_Actions()
    asd
DisplayTextToForce(GetPlayersAll(), I2S(GetHeroStatBJ(bj_HEROSTAT_STR, nil, false)))
ShowUnitShow(nil)
end

function InitTrig_Untitled_Trigger_001()
gg_trg_Untitled_Trigger_001 = CreateTrigger()
TriggerAddAction(gg_trg_Untitled_Trigger_001, Trig_Untitled_Trigger_001_Actions)
end

