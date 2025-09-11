do
    DamageEngine = setmetatable({}, {})
    local de = getmetatable(DamageEngine)
    de.__index = de

    local dmg_id = {}
    local dcm = 1.5 --default crit multiplier
    local max_seed = 10000
    local seeds = {}

    function de:autoattack_handler()
        local s = GetEventDamageSource()
        dmg_id[s] = dmg_id[s] or FourCC('Aatk')
        if dmg_id[s] == FourCC('Aatk') then
            DamageEngine:new_seed(s)
        end
    end

    function de:damage_event()
        --Get Damage Ability ID and Damage Seed, must be asap for potential concurencies
        local s = GetEventDamageSource()
        local d_seed = seeds[s] and seeds[s].seed or nil
        local id = dmg_id[s]
        dmg_id[s] = nil

        if GetEventDamage() > 0 then 
            --Generic
            local dmg = GetEventDamage() * GetRandomReal(0.99, 1.01)
            local t = BlzGetEventDamageTarget()
            local ab = false
            local is_player_source = GetOwningPlayer(s) == Players:get_player()
            local a_data = {
                    damage_source = s
                    ,damage_target = t
                    ,damage_id = id
                    ,damage_absorbed = 0
                    ,custom_data = DamageEngine:get_seed_data(s,d_seed)
                }

            local db_factor,db_constant,db_value = DamageBonus:get(t,id)
            dmg = (dmg + db_value) * db_factor * db_constant

            --Critical Strike
            local crit = CriticalChance:get(s) >= GetRandomInt(1, 100)
            if crit then dmg = dmg * dcm end
            a_data.damage_was_crit = crit
            a_data.damage_before_resist = dmg

            --Resistance Apply
            dmg = dmg * (1.0 - Resistance:get(t) / 100.0)
            local dmg_done = dmg < 0 and 0 or dmg

            a_data.damage_done = dmg_done

            --Absorbs Apply
            if dmg > 0 then
                if is_player_source then DamageMeter:log(dmg,id) end
                dmg,ab = Absorbs:damage(t,dmg)
                a_data.damage_absorbed = dmg_done - dmg
            end

            --Abilities "on_damage"
            for _,a_class in ipairs(ObjectUtils:get_unit_on_damage_abilities(s)) do
                a_class:on_damage(a_data)
            end

            --Override damage
            if GetUnitAbilityLevel(t, FourCC('DUMM')) > 0 then
                BlzSetEventDamage(0)
            else
                BlzSetEventDamage(dmg < 0 and 0 or dmg)
            end

            --Text Tag
            local msg = ab and 'Absorbed' or (dmg > 0 and (crit and tostring(math.floor(dmg)) .. '!' or tostring(math.floor(dmg))) or 'Immune')
            local r,g,b = Data:get_dmg_color(id)
            TextTag:create({u=t,s=msg,fs=crit and TextTag:defFontSize() * 1.2 or TextTag:defFontSize(),ls = crit and 2.5 or 1.0,r=r,b=b,g=g})
            
            --Seed related functionality
            DamageEngine:clear_seed(s,d_seed)
        end
    end

    function de:new_seed(u,data)
        seeds[u] = seeds[u] or {seed = 0}
        local seed = seeds[u].seed + 1
        if seed > max_seed then seed = 0 end
        seeds[u][seed] = data
        seeds[u].seed = seed
        return seed
    end

    function de:clear_seed(u,seed)
        if Utils:type(seeds[u]) == 'table' and Utils:type(seeds[u][seed]) == 'table' then
            seeds[u][seed] = nil
        end 
    end

    function de:get_seed_data(u,seed)
        return seeds[u][seed] or {}
    end

    --[[
        DamageEngine{
            source =
            ,target =
            ,id = 
            ,damage = 

            ,custom_data = Custom user data which will be passed into ability functions:
                on_damage()
            ,attack_type = NORMAL if not defined
            ,damage_type = NORMAL if not defined
        }
    ]]--

    function de:damage_unit(args)
        dmg_id[args.source] = args.id
        if args.data then self:new_seed(args.source,args.data) end
        UnitDamageTargetBJ(args.source, args.target, args.damage, args.attack_type or ATTACK_TYPE_NORMAL, args.damage_type or DAMAGE_TYPE_NORMAL)
    end

    OnInit.map(function()
        local t = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddAction(t, DamageEngine.damage_event)
        t = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_DAMAGING)
        TriggerAddAction(t, DamageEngine.autoattack_handler)
    end)
end