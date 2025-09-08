do
    EffectAnimation = setmetatable({}, {})
    local ea = getmetatable(EffectAnimation)
    ea.__index = ea

    local trg = CreateTrigger()
    local sm_trg = CreateTrigger()
    local period = 0.01
    local tbl = {}
    local sm_tbl = {}

    --[[
        EffectAnimation:create_xyz{
            x = x
            ,y = y 
            ,em = 'war3mapImported\\Orb of Fire.mdx'

            ,z = z
            ,scale = 1.0
            ,time = 1.0

            ,is_marker = false
        }
    ]]--
    function ea:create_xyz(args)
        local x = args.x
        local y = args.y 
        local em = args.model
        if x and y and em then 
            local z = args.z or Utils:get_point_z(x,y)
            local s = args.scale or 1.0
            local t = args.time or 1.0
            local e = AddSpecialEffect(em, x, y)
            BlzSetSpecialEffectScale(e, 0.01)
            BlzSetSpecialEffectZ(e,z)
            table.insert(tbl,{
                e = e
                ,vr = (s / (t/period)) * (-1)
                ,p = Utils:round(t/period,0)
                ,is_marker = args.is_marker
            })
            EnableTrigger(trg)
            return e
        end
        return nil
    end

    --[[
        EffectAnimation:vanish{
            e = effect
            ,t = time

            ,is_marker = false
        }
    ]]--
    function ea:vanish(args)
        if Utils:type(args.e) == 'effect' then 
            local i = Utils:get_key_by_value(tbl,'e',args.e)
            if i then table.remove(tbl,i) end
            table.insert(tbl,{
                e = args.e
                ,vr = BlzGetSpecialEffectScale(args.e) / (args.t/period)
                ,p = Utils:round(args.t/period,0)
                ,d = true
                ,is_marker = args.is_marker
            })
            EnableTrigger(trg)
        end
    end

    function ea:animate()
        if #tbl > 0 then 
            for i=#tbl,1,-1 do
                if tbl[i].p > 0 then 
                    BlzSetSpecialEffectScale(tbl[i].e, BlzGetSpecialEffectScale(tbl[i].e) - tbl[i].vr)
                    if tbl[i].is_marker then
                        BlzSetSpecialEffectZ(tbl[i].e, SpellMarker:get_z(tbl[i].e))
                    end
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