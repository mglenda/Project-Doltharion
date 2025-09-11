do
    Arena = setmetatable({}, {})
    local a = getmetatable(Arena)
    a.__index = a

    a.DIFFICULTY_NORMAL = 1
    a.DIFFICULTY_HEROIC = 2
    a.DIFFICULTY_MYTHIC = 3
    a.active_id = nil

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

    function a:recalculate_difficulties()
        for i,a in ipairs(self.arenas) do
            if i > 1 then
                self.arenas[i].d_avail[self.DIFFICULTY_NORMAL] = (self.arenas[i-1].d_beaten[self.DIFFICULTY_HEROIC] or self.arenas[i-1].d_beaten[self.DIFFICULTY_NORMAL]) and (i == 2 or self.arenas[i-2].d_beaten[self.DIFFICULTY_HEROIC])
                self.arenas[i].d_avail[self.DIFFICULTY_HEROIC] = self.arenas[i-1].d_beaten[self.DIFFICULTY_HEROIC]
            end
        end
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
            ArenaUtils:create_flee_trigger()
            ArenaUtils:create_bosses()
            IssueImmediateOrderById(Hero:get(), String2OrderIdBJ('stop'))
            Units:pause_all()
            self:set_difficulty(a_dif or self.DIFFICULTY_NORMAL)
            ArenaComponents:start()
            if Utils:type(self:get_active_arena().start) == 'function' then self:get_active_arena():start() end
            ArenaUtils:run_counter{duration = 5}
            ArenaUtils:play_boss_sound{key = 'start'}
        end
    end

    function a:victory()
        self:stop()
        if Utils:type(self:get_active_arena().victory) == 'function' then self:get_active_arena():victory() end
        ArenaUtils:play_boss_sound{key = 'victory'}
        self:exit_delay()
        for d = self:get_difficulty(),1,-1 do
            self:get_active_arena().d_beaten[d] = true
        end
        self:recalculate_difficulties()
    end

    function a:defeat()
        self:stop()
        if Utils:type(self:get_active_arena().defeat) == 'function' then self:get_active_arena():defeat() end
        ArenaUtils:play_boss_sound{key = 'defeat'}
        self:exit_delay()
    end

    function a:begin()
        Units:unpause_all()
        if Utils:type(self:get_active_arena().begin) == 'function' then self:get_active_arena():begin() end
    end

    function a:stop()
        ArenaUtils:flush_triggers()
        DBM:pause_all()
        Units:pause_all()
        Data:flush_all_abilities()
        MissileManager:destroy_all()
        if Utils:type(self:get_active_arena().stop) == 'function' then self:get_active_arena():stop() end
    end

    function a:flee()
        self:stop()
        local arena = self:get_active_arena()
        if Utils:type(arena.flee) == 'function' then arena:flee() end
        local x,y = GetRectCenterX(arena.r_spawn),GetRectCenterY(arena.r_spawn)
        PanCameraToTimedForPlayer(Players:get_player(), x, y, 4.5)
        ArenaUtils:play_boss_sound{key = 'flee'}
        self:exit_delay()
    end

    function a:exit_delay()
        ArenaUtils:wait_and_do{
            duration = 5.0
            ,on_end = {
                func = self.exit
                ,params = table.pack(self)
            }
        }
    end

    function a:exit()
        if Utils:type(self:get_active_arena().exit) == 'function' then self:get_active_arena():exit() end
        DBM:destroy_all()
        ArenaComponents:flush()
        Units:remove_all()
        Buffs:flush_all_buffs()
        Abilities:flush_all_cooldowns()
        Abilities:flush_all_silences()
        Hero:move()
        Units:unpause_all()
        ArenaUtils:flush_fog_modifiers()
        UI:show_idle_panels()
    end
end