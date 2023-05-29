do
    FrameFading = setmetatable({}, {})
    local ff = getmetatable(FrameFading)
    ff.__index = ff

    local list = {}
    
    function ff:fadeout(frame,dur,func)
        list[frame] = {
            func = func
            ,fade_rate = (BlzFrameGetAlpha(frame) / dur) / 100
            ,trg = CreateTrigger()
        }
        TriggerRegisterTimerEventPeriodic(list[frame].trg, 0.01)
        TriggerAddAction(list[frame].trg, self.progress)
    end

    function ff:progress()
        local frame = FrameFading:getFrameByTrigger(GetTriggeringTrigger())
        if BlzFrameIsVisible(frame) then 
            if BlzFrameGetAlpha(frame) > 0 then
                BlzFrameSetAlpha(frame, R2I(BlzFrameGetAlpha(frame) - list[frame].fade_rate))
            else
                BlzFrameSetVisible(frame, false)
                if Utils:type(list[frame].func) == 'function' then
                    list[frame].func()
                end
                FrameFading:stopfading(frame)
            end
        else --If frame is not visible means it was hidden by other action and fading should be stopped without executing potential func()
            FrameFading:stopfading(frame)
        end
    end

    function ff:getFrameByTrigger(trg)
        for f,t in pairs(list) do
            if t.trg == trg then
                return f
            end
        end
        return nil
    end

    function ff:stopfading(frame)
        if list[frame] then
            DestroyTrigger(list[frame].trg)
            list[frame] = nil
        end
    end

    oldBlzFrameSetVisible = BlzFrameSetVisible
    function BlzFrameSetVisible(frame,bool,alpha)
        if bool then
            FrameFading:stopfading(frame)
            BlzFrameSetAlpha(frame, alpha or 255)
        end
        oldBlzFrameSetVisible(frame,bool)
    end
end