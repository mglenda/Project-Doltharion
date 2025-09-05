do
    Abilities = setmetatable({}, {})
    local a = getmetatable(Abilities)
    a.__index = a

    local silences = {}
    local cooldowns = {}
    local highlighted = {}
    local counter = CreateTrigger()
    local refreshRate = 0.1

    --[[
        Abilities:add_silence{
            unit = unit
            ,s_key = 'my_key'

            --optional, silences all if skipped
            ,a_code = Ability:get_a_code()
        }
    ]]--
    function a:add_silence(args)
        local unit = args.unit
        local a_code = args.a_code or 'all'
        local s_key = args.s_key
        if unit and s_key then
            silences[unit] = silences[unit] or {}
            table.insert(silences[unit],{
                s_key = s_key
                ,a_code = a_code
            })
        end
    end

    function a:is_ability_silenced(unit,a_code)
        if Utils:type(silences[unit]) == 'table' then
            for i,t in ipairs(silences[unit]) do
                if t.a_code == 'all' or t.a_code == a_code then 
                    return true
                end    
            end
        end
        return false
    end

    function a:silence_with_key_exists(unit,s_key)
        if Utils:type(silences[unit]) == 'table' then
            for i,t in ipairs(silences[unit]) do
                if t.s_key == s_key then 
                    return true
                end
            end
        end
        return false
    end

    function a:clear_silence(args)
        local unit = args.unit
        local s_key = args.s_key

        if not(s_key) then
            silences[unit] = nil
            return
        end

        if unit and Utils:type(silences[unit]) == 'table' then
            for i=#silences[unit],1,-1 do
                if silences[unit][i].s_key == s_key then 
                    table.remove(silences[unit],i)
                end
            end
        end
    end

    function a:flush_all_silences()
        silences = {}
    end

    function a:refresh()
        local c = 0
        for u,cds in pairs(cooldowns) do
            if #cds > 0 then 
                for i=#cds,1,-1 do
                    if cds[i].d > 0 then
                        cds[i].d = Utils:round(cds[i].d - refreshRate,1)
                    else
                        table.remove(cds,i)
                    end
                end
                c = c + 1
            else
                cooldowns[u] = nil
            end
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
        return s-c <= 0 and 'cd' or (self:is_ability_silenced(u,ac) and 'silenced' or 'rdy'),s-c,mc,self:is_highlighted(u,ac)
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
        return s-c > 0 and not(self:is_ability_silenced(u,ac))
    end

    --[[
        Abilities:add_to_cooldown{
            unit = 
            ,ab_id = 
            ,value = 

            ,first_only = true
        }
    ]]--

    function a:add_to_cooldown(args)
        if Utils:type(cooldowns[args.unit]) == 'table' then
            table.sort(cooldowns[args.unit], function (k1, k2) return k1.d < k2.d end)
            for i,v in ipairs(cooldowns[args.unit]) do
                if v.ac == args.ab_id then 
                    v.d = v.d + args.value < 0 and 0 or v.d + args.value
                    if args.first_only then return end
                end
            end
        end
    end

    function a:is_ability_available(u,ac)
        return self:is_ability_ready(u,ac)
    end

    function a:reset_ability_cooldown(u,ac)
        if Utils:type(cooldowns[u]) == 'table' then
            for i=#cooldowns[u],1,-1 do 
                if cooldowns[u][i].ac == ac then table.remove(cooldowns[u],i) end
            end
        end
    end

    function a:enable_highlight(u,ac)
        highlighted[u] = Utils:type(highlighted[u]) == 'table' and highlighted[u] or {}
        highlighted[u][ac] = true
    end

    function a:disable_highlight(u,ac)
        highlighted[u] = Utils:type(highlighted[u]) == 'table' and highlighted[u] or {}
        highlighted[u][ac] = false
    end

    function a:is_highlighted(u,ac)
        if Utils:type(highlighted[u]) == 'table' then
            return highlighted[u][ac]
        end
        return false
    end

    function a:reset_all_cooldowns(u)
        cooldowns[u] = nil
    end

    function a:flush_all_cooldowns()
        cooldowns = {}
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

    function a:get_cast_range(u,ac)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u,ac), ABILITY_RLF_CAST_RANGE, 0)
    end

    OnInit(function()
        TriggerAddAction(counter, Abilities.refresh)
        TriggerRegisterTimerEventPeriodic(counter, refreshRate)
    end)
end