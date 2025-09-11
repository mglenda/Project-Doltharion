do
    WaitAndDo = setmetatable({}, {})
    local u = getmetatable(WaitAndDo)
    u.__index = u

    --[[
        WaitAndDo:register{
            duration =
            ,on_end = {
                func = function
                ,params = table.pack(...)
            }
        }
    ]]--

    function u:register(args)
        local duration = args.duration
        local on_end = args.on_end
        if duration and on_end then
            local t = CreateTimer()
            TimerStart(t, duration, false, function()
                DestroyTimer(t)
                if on_end.params then
                    on_end.func(table.unpack(on_end.params))
                else
                    on_end.func()
                end
            end)
        end
    end
end