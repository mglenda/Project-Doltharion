gg_trg_Untitled_Trigger_001 = nil
function InitGlobals()
end

function Trig_Untitled_Trigger_001_Conditions()
if (not (GetAttacker() == nil)) then
return false
end
return true
end

function Trig_Untitled_Trigger_001_Actions()
SetCameraFieldForPlayer(Player(0), CAMERA_FIELD_FARZ, 5000.00, 0)
SetTerrainFogExBJ(0, 99999.00, 99999.00, 0, 100, 100, 100)
DisplayTextToForce(GetPlayersAll(), GetEventPlayerChatString())
ForceUICancelBJ(Player(0))
ForceUIKeyBJ(Player(0), "A")
SetUnitManaBJ(GetLeavingUnit(), GetUnitStateSwap(UNIT_STATE_MANA, GetTriggerUnit()))
AddLightningLoc("CLPB", GetUnitLoc(GetTriggerUnit()), GetRectCenter(GetPlayableMapRect()))
AddUnitAnimationPropertiesBJ(true, "Defend", nil)
    asd
DisplayTextToForce(GetPlayersAll(), I2S(GetHeroStatBJ(bj_HEROSTAT_STR, nil, false)))
SetUnitTimeScalePercent(GetLastReplacedUnitBJ(), 100)
end

function InitTrig_Untitled_Trigger_001()
gg_trg_Untitled_Trigger_001 = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(gg_trg_Untitled_Trigger_001, EVENT_PLAYER_UNIT_ISSUED_ORDER)
TriggerRegisterAnyUnitEventBJ(gg_trg_Untitled_Trigger_001, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
TriggerRegisterAnyUnitEventBJ(gg_trg_Untitled_Trigger_001, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
TriggerRegisterPlayerMouseEventBJ(gg_trg_Untitled_Trigger_001, Player(0), bj_MOUSEEVENTTYPE_MOVE)
TriggerAddCondition(gg_trg_Untitled_Trigger_001, Condition(Trig_Untitled_Trigger_001_Conditions))
TriggerAddAction(gg_trg_Untitled_Trigger_001, Trig_Untitled_Trigger_001_Actions)
end

