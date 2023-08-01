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
                ,d = true
            })
            EnableTrigger(trg)
        end
    end

    function ea:create_xyz(em,x,y,z,s,t)
        local e = AddSpecialEffect(em, x, y)
        BlzSetSpecialEffectZ(e, z)
        BlzSetSpecialEffectScale(e, 0.01)
        table.insert(tbl,{
            e = e
            ,vr = (s / (t/period)) * (-1)
            ,p = Utils:round(t/period,0)
        })
        EnableTrigger(trg)
        return e
    end

    function ea:animate()
        if #tbl > 0 then 
            for i=#tbl,1,-1 do
                if tbl[i].p > 0 then 
                    BlzSetSpecialEffectScale(tbl[i].e, BlzGetSpecialEffectScale(tbl[i].e) - tbl[i].vr)
                    tbl[i].p = tbl[i].p - 1
                else
                    if tbl[i].d then oldDestroyEffect(tbl[i].e) end
                    table.remove(tbl,i)
                end
            end
        else
            DisableTrigger(trg)
        end
    end

    oldDestroyEffect = DestroyEffect
    function DestroyEffect(e)
        local i = Utils:get_key_by_value(tbl,'e',e)
        if i then table.remove(tbl,i) end
        oldDestroyEffect(e)
    end

    OnInit.map(function()
        TriggerRegisterTimerEventPeriodic(trg, period)
        TriggerAddAction(trg, EffectAnimation.animate)
    end)
end