do
    Arena = setmetatable({}, {})
    local a = getmetatable(Arena)
    a.__index = a

    a.d_normal = 1
    a.d_heroic = 2
    a.d_mythic = 3

    function a:set_difficulty(difficulty)
        self.difficulty = difficulty
        print(self.difficulty)
    end

    function a:get_difficulty()
        return self.difficulty
    end

    function a:register(arena_class)
        if Utils:type(self.arenas) ~= 'table' then self.arenas = {} end
        arena = arena_class:create()
        arena.d_normal_avail = true
        arena.d_normal_beaten = false
        arena.d_heroic_avail = true
        arena.d_heroic_beaten = false
        arena.d_mythic_avail = false
        arena.d_mythic_beaten = false
        table.insert(self.arenas,arena)
    end

    function a:get_arenas()
        return self.arenas
    end

    function a:create_trigger()
        local trg = CreateTrigger()
        self.triggers = self.triggers or {}
        table.insert(self.triggers,trg)
        return trg 
    end

    function a:flush_triggers()
        if Utils:type(self.triggers) == 'table' then 
            for i=#self.triggers,1,-1 do
                DestroyTrigger(self.triggers[i])
                table.remove(self.triggers,i)
            end
        end
    end

    function a:set(k,v)
        self.data = self.data or {}
        self.data[k] = v
    end

    function a:get(k)
        if Utils:type(self.data) == 'table' then
            return self.data[k]
        else
            return nil
        end
    end

    function a:start(i)
        Abilities:reset_all_cooldowns(Hero:get())
        DamageMeter:reset()
        UI:hide_idle_panels()
        self.arenas[i]:start()
        --AI:start()
    end

    function a:stop(i)
        DBM:destroy_all()
        --AI:stop()
        self:flush_triggers()
        self.arenas[i]:stop()
        self.data = {}
        Warband:clear()
        WarbandPanel:clear()
        UI:show_idle_panels()
        Abilities:reset_all_cooldowns(Hero:get())
        Hero:move()
    end
end