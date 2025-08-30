do
    MissileManager = setmetatable({}, {})
    local mm = getmetatable(MissileManager)
    mm.__index = mm

    local max_missiles_per_trigger = 50

    function mm:load()
        self.containers = {}
        self.triggers = {}
    end

    function mm:destroy_all()
        for trg,_ in pairs(self.triggers) do
            DestroyTrigger(trg)
        end
        self.triggers = {}

        for _,tbl in ipairs(self.containers) do
            for _,m in ipairs(tbl) do
                m:destroy()
            end
        end
        self.containers = {}
    end

    function mm:get_free_container()
        for i,tbl in ipairs(self.containers) do
            if #tbl < max_missiles_per_trigger then return tbl,i end
        end
        table.insert(self.containers,{})
        return self.containers[#self.containers],#self.containers
    end

    function mm:register(missile)
        local container,index = self:get_free_container()
        table.insert(container,missile)
        for t,i in pairs(self.triggers) do
            if i == index then 
                EnableTrigger(t)
                return 
            end
        end

        local trg = CreateTrigger()
        self.triggers[trg] = index
        TriggerAddAction(trg,function() 
            MissileManager:missile_fly(GetTriggeringTrigger())
        end)
        TriggerRegisterTimerEventPeriodic(trg, 0.01)
    end

    function mm:missile_fly(trg)
        --Identification
        local index = self.triggers[trg]
        local tbl = self.containers[index]
        --Missile Moving Logic
        for i=#tbl,1,-1 do
            if not tbl[i]:move() then
                table.remove(tbl,i)
            end
        end
        --Flush Trigger + Storage
        if #tbl == 0 then 
            DisableTrigger(trg)
        end
    end

    OnInit.map(function()
        MissileManager:load()
    end)
end