do
    ArenaUtils = setmetatable({}, {})
    local a = getmetatable(ArenaUtils)
    a.__index = a

    local a_triggers = {}
    local a_timers = {}
    local a_fog_modifiers = {}
    local a_bosses = {}

    function a:create_bosses()
        a_bosses = {}
        local arena = Arena:get_active_arena()
        if arena then
            local trigger = self:create_trigger()
            for _,b_data in ipairs(arena.b_data) do
                local x,y = GetRectCenterX(b_data.spawn),GetRectCenterY(b_data.spawn)
                local hero_x,hero_y = GetRectCenterX(arena.r_spawn),GetRectCenterY(arena.r_spawn)
                local angle = b_data.angle or Utils:get_angle_between_points(x,y,hero_x,hero_y)
                local boss = CreateUnit(Players:get_challengers(),b_data.id, x, y, angle)
                table.insert(a_bosses, boss)
                TriggerRegisterUnitEvent(trigger, boss, EVENT_UNIT_DEATH)
            end
            TriggerRegisterUnitEvent(trigger, Hero:get(), EVENT_UNIT_DEATH)
            TriggerAddAction(trigger, function()
                if not(ArenaUtils:are_bosses_alive()) then
                    Arena:victory()
                elseif GetDyingUnit() == Hero:get() then
                    Arena:defeat()
                end
            end)
            Target:set(a_bosses[1])
        end
    end

    function a:are_bosses_alive()
        for _,b in ipairs(a_bosses) do
            if IsUnitAliveBJ(b) then return true end
        end
        return false
    end

    function a:is_unit_boss(u)
        for _,b in ipairs(a_bosses) do
            if b == u then return true end
        end
        return false
    end

    function a:get_boss(i)
        i = i or 1
        if #a_bosses >= i then
            return a_bosses[i]
        end
        return nil
    end

    function a:create_trigger()
        local trigger = CreateTrigger()
        table.insert(a_triggers,trigger)
        return trigger
    end

    function a:create_timer()
        local timer = CreateTimer()
        table.insert(a_timers,timer)
        return timer
    end
    
    function a:flush_triggers()
        for i=#a_triggers,1,-1 do
            DestroyTrigger(a_triggers[i])
        end
        a_triggers = {}

        for i=#a_timers,1,-1 do
            DestroyTimer(a_timers[i])
        end
        a_timers = {}

        local c_frame = BlzGetFrameByName('arena_counter', 0)
        if c_frame then
            BlzDestroyFrame(c_frame)
        end
    end

    function a:destroy_timer(timer)
        for i,t in ipairs(a_timers) do
            if t == timer then
                DestroyTimer(timer)
                table.remove(a_timers,i)
            end
        end
    end

    function a:destroy_trigger(trigger)
        for i,t in ipairs(a_triggers) do
            if t == trigger then
                DestroyTrigger(trigger)
                table.remove(a_triggers,i)
            end
        end
    end

    function a:create_flee_trigger()
        local t = self:create_trigger()
        local arena = Arena:get_active_arena()
        for _,r in ipairs(arena.r_arena) do
            TriggerRegisterLeaveRectSimple(t, r)
            table.insert(a_fog_modifiers,CreateFogModifierRectBJ(true, Players:get_player(), FOG_OF_WAR_VISIBLE, r))
        end
        TriggerAddAction(t, function()
            if Hero:get() == GetLeavingUnit() and not(ArenaUtils:is_hero_in_arena()) then
                Arena:flee()
            end
        end)
    end

    function a:flush_fog_modifiers()
        for i=#a_fog_modifiers,1,-1 do
            DestroyFogModifier(a_fog_modifiers[i])
        end
        a_fog_modifiers = {}
    end

    function a:is_hero_in_arena()
        local arena = Arena:get_active_arena()
        for _,r in ipairs(arena.r_arena) do
            if Utils:is_unit_in_rect(Hero:get(),r) then return true end
        end
        return false
    end

    --[[

        ArenaUtils:wait_and_do{
            duration =
            ,on_end = {
                func = function
                ,params = table.pack(...)
            }
        }
            
    ]]--

    function a:wait_and_do(args)
        local duration = args.duration
        local on_end = args.on_end
        if duration and on_end then
            local t = self:create_timer()
            TimerStart(t, duration, false, function()
                self:destroy_timer(t)
                on_end.func(table.unpack(on_end.params))
            end)
        end
    end

    --[[
        Params:
            duration
            ,on_end = {
                func = function
                ,params = table.pack(...)
            }
    ]]--
    function a:run_counter(args)
        local duration = args.duration
        if duration then
            local c_frame = BlzCreateSimpleFrame('arena_counter', UI:getConst('screen_frame'), 0)
            BlzFrameSetPoint(c_frame, FRAMEPOINT_CENTER, UI:getConst('screen_frame'), FRAMEPOINT_CENTER, 0, 0)
            local c_text = BlzGetFrameByName('arena_counter_text', 0)
            BlzFrameSetText(c_text, duration)

            local on_end = args.on_end or {func = Arena.begin, params = table.pack(Arena)}
            local t = self:create_timer()
            TimerStart(t, 1.0, true, function()
                duration = duration - 1 
                if duration <= 0 then
                    BlzDestroyFrame(c_frame)
                    self:destroy_timer(t)
                    on_end.func(table.unpack(on_end.params))
                else
                    BlzFrameSetText(c_text, duration)
                end
            end)
        end
    end

    --[[
        ArenaUtils:play_boss_sound{
            key = 'init'
        }
    ]]--
    function a:play_boss_sound(args)
        local key = args.key
        local arena = Arena:get_active_arena()

        if key and arena.sounds[key] then
            local unit_name = args.unit_name or arena:get_name()
            local message = arena.sounds[key].text
            local sound = arena.sounds[key].sound
            PlaySoundBJ(sound)
            DisplayTextToForce(Players:get_all_players(), '|c00FFD700' .. unit_name .. '|r: ' .. message)
        end
    end
end