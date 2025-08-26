do
    DamageMeter = setmetatable({}, {})
    local dm = getmetatable(DamageMeter)
    dm.__index = dm

    function dm:create()
        self.data = {}
        self.combat_timer = CreateTrigger()
        self.combat_trigger = CreateTrigger()
        self.max_duration = 5
        self.current_duration = 0
        self.total_duration = 0

        TriggerAddAction(self.combat_timer, self.timer_tick)
        TriggerRegisterTimerEventPeriodic(self.combat_timer, 1.0)
        DisableTrigger(self.combat_timer)

        TriggerRegisterAnyUnitEventBJ(self.combat_trigger, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddCondition(self.combat_trigger, Condition(function() return GetOwningPlayer(GetEventDamageSource()) == Players:get_player() end))
        TriggerAddAction(self.combat_trigger, self.combat_init)
    end

    function dm:log(dmg,id)
        self.data[id] = self.data[id] or {
            dmg = 0
            ,dps = 0
        }
        self.data[id].dmg = self.data[id].dmg + dmg
        self.data[id].dps = self.data[id].dmg / self.total_duration
    end

    function dm:get_sorted_data()
        tbl = {}
        total_dmg = 0
        total_dps = 0
        for id,t in pairs(self.data) do
            table.insert( tbl,{
                id = id
                ,dmg = t.dmg
                ,dps = t.dps
            })
            total_dmg = total_dmg + t.dmg
            total_dps = total_dps + t.dps
        end
        table.sort(tbl, function (k1, k2) return k1.dmg > k2.dmg end )
        return tbl,total_dmg,total_dps
    end

    function dm:reset()
        DisableTrigger(self.combat_timer)
        self.data = {}
        self.total_duration = 0
        DamageMeterPanel:update()
    end

    function dm:timer_tick()
        DamageMeter.current_duration = DamageMeter.current_duration + 1
        DamageMeter.total_duration = DamageMeter.total_duration + 1
        if DamageMeter.current_duration > DamageMeter.max_duration then
            DisableTrigger(DamageMeter.combat_timer)
            DamageMeter.total_duration = (DamageMeter.total_duration > DamageMeter.max_duration) and DamageMeter.total_duration - DamageMeter.max_duration or 0
            DamageMeterPanel:update()
        end
    end

    function dm:combat_init()
        DamageMeter.current_duration = 0
        DamageMeterPanel:update()
        if not(IsTriggerEnabled(DamageMeter.combat_timer)) then
            EnableTrigger(DamageMeter.combat_timer)
        end
    end

    OnInit.final(function()
        DamageMeter:create()
    end)
end