do
    EffectAnimation = setmetatable({}, {})
    local ea = getmetatable(EffectAnimation)
    ea.__index = ea

    local trg = CreateTrigger()
    local period = 0.01
    local tbl = {}

    function ea:vanish(e,t)
        if Utils:type(e) == 'effect' then 
            local i = Utils:get_key_by_value(tbl,'e',e)
            if i then table.remove(tbl,i) end
            table.insert(tbl,{
                e = e
                ,vr = BlzGetSpecialEffectScale(e) / (t/period)
                ,p = Utils:round(t/period,0)
            })
            EnableTrigger(trg)
        end
    end

    function ea:animate()
        if #tbl > 0 then 
            for i=#tbl,1,-1 do
                if tbl[i].p > 0 then 
                    BlzSetSpecialEffectScale(tbl[i].e, BlzGetSpecialEffectScale(tbl[i].e) - tbl[i].vr)
                    tbl[i].p = tbl[i].p - 1
                else
                    oldDestroyEffect(tbl[i].e)
                    table.remove(tbl,i)
                end
            end
        else
            DisableTrigger(trg)
        end
    end

    oldDestroyEffect = DestroyEffect
    function DestroyEffect(e)
        if not(Utils:get_key_by_value(tbl,'e',e)) then
            oldDestroyEffect(e)
        end
    end

    OnInit.map(function()
        TriggerRegisterTimerEventPeriodic(trg, period)
        TriggerAddAction(trg, EffectAnimation.animate)
    end)
end