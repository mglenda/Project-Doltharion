do
    Abilities = setmetatable({}, {})
    local a = getmetatable(Abilities)
    a.__index = a

    local cooldowns = {}
    local counter = CreateTrigger()
    local refreshRate = 0.1

    function a:refresh()
        local c = 0
        for u,cds in pairs(cooldowns) do
            for i=#cds,1,-1 do
                if cds[i].d > 0 then
                    cds[i].d = Utils:round(cds[i].d - refreshRate,1)
                else
                    table.remove(cds,i)
                end
            end
            c = c + 1
        end
        if c == 0 then DisableTrigger(counter) end
    end

    function a:start_ability_cooldown(u,ac)
        local d = self:get_ability_cooldown(u,ac)
        if d > 0 then 
            if Utils:type(cooldowns[u]) ~= 'table' then cooldowns[u] = {} end
            table.insert(cooldowns[u],{
                ac = ac
                ,d = d
            })
            if not(IsTriggerEnabled(counter)) then EnableTrigger(counter) end
        end
    end

    function a:get_ability_status(u,ac)
        local mc,c,s = 999,0,self:get_stack_count(u,ac)
        if Utils:type(cooldowns[u]) == 'table' then
            for i,v in ipairs(cooldowns[u]) do
                if v.ac == ac then 
                    c = c + 1 
                    mc = mc > v.d and v.d or mc
                end
            end
        end
        return s-c <= 0 and 'cd' or 'rdy',s-c,mc
    end

    function a:is_ability_ready(u,ac)
        local c,s = 0,self:get_stack_count(u,ac)
        if Utils:type(cooldowns[u]) == 'table' then
            for i,v in ipairs(cooldowns[u]) do
                if v.ac == ac then 
                    c = c + 1 
                end
            end
        end
        return s-c > 0
    end

    function a:reset_ability_cooldown(u,ac)
        if Utils:type(cooldowns[u]) == 'table' then
            for i=#cooldowns[u],1,-1 do 
                if cooldowns[u][i].ac == ac then table.remove(cooldowns[u],i) end
            end
        end
    end

    function a:reset_all_cooldowns(u)
        cooldowns[u] = nil
    end

    function a:get_stack_count(u,ac)
        return BlzGetAbilityIntegerField(BlzGetUnitAbility(u, ac), ABILITY_IF_PRIORITY)
    end

    function a:set_stack_count(u,ac,sc)
        BlzSetAbilityIntegerField(BlzGetUnitAbility(u, ac), ABILITY_IF_PRIORITY, sc)
    end

    function a:get_ability_cooldown(u,ac)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u,ac), ABILITY_RLF_DURATION_HERO, 0)
    end

    function a:set_ability_cooldown(u,ac,v)
        BlzSetAbilityRealLevelField(BlzGetUnitAbility(u,ac), ABILITY_RLF_DURATION_HERO, 0, v)
    end

    OnInit(function()
        TriggerAddAction(counter, Abilities.refresh)
        TriggerRegisterTimerEventPeriodic(counter, refreshRate)
    end)
end