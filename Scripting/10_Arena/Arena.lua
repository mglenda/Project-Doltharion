do
    Arena = setmetatable({}, {})
    local a = getmetatable(Arena)
    a.__index = a

    function a:register(arena)
        if Utils:type(self.arenas) ~= 'table' then self.arenas = {} end
        table.insert(self.arenas,arena:create())
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
        DamageEngine:clear_all_records()
        UI:hide_idle_panels()
        self.arenas[i]:start()
        AI:start()
    end

    function a:stop(i)
        DBM:destroy_all()
        AI:stop()
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