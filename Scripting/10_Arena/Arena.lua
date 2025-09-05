do
    Arena = setmetatable({}, {})
    local a = getmetatable(Arena)
    a.__index = a

    a.DIFFICULTY_NORMAL = 1
    a.DIFFICULTY_HEROIC = 2
    a.DIFFICULTY_MYTHIC = 3
    a.active_id = nil

    local a_triggers = {}
    local a_fog_modifiers = {}
    local a_bosses = {}

    function a:create_bosses()
        a_bosses = {}
        local arena = self:get_active_arena()
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
            TriggerAddAction(trigger, function()
                if not(Arena:are_bosses_alive()) then
                    Arena:victory()
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

    function a:create_trigger()
        local trigger = CreateTrigger()
        table.insert(a_triggers,trigger)
        return trigger
    end
    
    function a:flush_triggers()
        for i=#a_triggers,1,-1 do
            DestroyTrigger(a_triggers[i])
        end
        a_triggers = {}
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
        local arena = self:get_active_arena()
        for _,r in ipairs(arena.r_arena) do
            TriggerRegisterLeaveRectSimple(t, r)
            table.insert(a_fog_modifiers,CreateFogModifierRectBJ(true, Players:get_player(), FOG_OF_WAR_VISIBLE, r))
        end
        TriggerAddAction(t, function()
            if Hero:get() == GetLeavingUnit() and not(Arena:is_hero_in_arena()) then
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

    function a:set_difficulty(difficulty)
        self.difficulty = difficulty
    end

    function a:get_difficulty()
        return self.difficulty
    end

    function a:register(arena_class,i)
        if Utils:type(self.arenas) ~= 'table' then self.arenas = {} end
        arena = arena_class:create()
        arena.d_beaten = {}
        arena.d_avail = {}
        for d_id=1,3,1 do
            arena.d_beaten[d_id] = false
            arena.d_avail[d_id] = (i == 1 and d_id < self.DIFFICULTY_MYTHIC) and true or false
        end
        self.arenas[i or #self.arenas + 1] = arena
    end

    function a:get_arenas()
        return self.arenas
    end

    function a:get_active_arena()
        return self.arenas[self.active_id]
    end

    --AI:start()
    --AI:stop()
    function a:start(a_dif,a_id)
        self.active_id = a_id
        local arena = self:get_active_arena()
        if arena and Utils:type(arena.r_spawn) == 'rect' then 
            local spawn_x,spawn_y = GetRectCenterX(arena.r_spawn),GetRectCenterY(arena.r_spawn)
            UI:hide_idle_panels()
            Data:flush_all_abilities()
            MissileManager:destroy_all()
            Units:remove_all()
            Buffs:flush_all_buffs()
            Abilities:flush_all_cooldowns()
            Abilities:flush_all_silences()
            Hero:move(spawn_x,spawn_y,arena.spawn_angle or 90.0)
            DamageMeter:reset()
            self:create_flee_trigger()
            self:create_bosses()
            self:set_difficulty(a_dif or self.DIFFICULTY_NORMAL)
            if Utils:type(self:get_active_arena().start) == 'function' then self:get_active_arena():start() end
        end
    end

    function a:victory()
        for d = self:get_difficulty(),1,-1 do
            self:get_active_arena().d_beaten[d] = true
        end
        self:stop()
        if Utils:type(self:get_active_arena().victory) == 'function' then self:get_active_arena():victory() end
    end

    function a:stop()
        self:flush_triggers()
        DBM:pause_all()
        Units:pause_all()
        Data:flush_all_abilities()
        MissileManager:destroy_all()
        if Utils:type(self:get_active_arena().stop) == 'function' then self:get_active_arena():stop() end
    end

    function a:flee()
        self:stop()
        if Utils:type(self:get_active_arena().flee) == 'function' then self:get_active_arena():flee() end
    end

    function a:exit()
        if Utils:type(self:get_active_arena().exit) == 'function' then self:get_active_arena():exit() end
        DBM:destroy_all()
        Units:remove_all()
        Buffs:flush_all_buffs()
        Abilities:flush_all_cooldowns()
        Abilities:flush_all_silences()
        Hero:move()
        self:flush_fog_modifiers()
        UI:show_idle_panels()
    end
end