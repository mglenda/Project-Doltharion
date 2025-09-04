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

            local db_factor,db_constant,db_value = DamageBonus:get(t,id)
            dmg = (dmg + db_value) * db_factor * db_constant

            --Critical Strike
            local crit = CriticalChance:get(s) >= GetRandomInt(1, 100)
            if crit then dmg = dmg * dcm end

            --Resistance Apply
            dmg = dmg * (1.0 - Resistance:get(t) / 100.0)
            local dmg_done = dmg < 0 and 0 or dmg

            --Absorbs Apply
            if dmg > 0 then
                if is_player_source then DamageMeter:log(dmg,id) end
                dmg,ab = Absorbs:damage(t,dmg)
            end

            --Override damage
            if GetUnitAbilityLevel(t, FourCC('DUMM')) > 0 then
                BlzSetEventDamage(0)
            else
                BlzSetEventDamage(dmg < 0 and 0 or dmg)
            end

            --Text Tag
            if is_player_source or crit then
                local msg = ab and 'Absorbed' or (dmg > 0 and (crit and tostring(math.floor(dmg)) .. '!' or tostring(math.floor(dmg))) or '')
                local r,g,b = Data:get_dmg_color(id)
                TextTag:create({u=t,s=msg,fs=crit and TextTag:defFontSize() * 1.2 or TextTag:defFontSize(),ls = crit and 2.5 or 1.0,r=r,b=b,g=g})
            end
            
            --Seed related functionality
            if crit then DamageEngine:on_crit(s,d_seed,dmg_done) end
            DamageEngine:after_damage(s,d_seed,dmg_done)
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

    --[[
        Damage seeding provides possibility of handeling dynamic behavior related to damage events.
        Let's say you want to do damage and do something if that damage fulfill certain condition ("for example if damage was critical hit, add debuff to victim")
        We will call these various scenarios Snippets.
        Snippets can be defined in data argument of DamageEngine:damage_unit function.

        Keep in mind that data argument is fully optional, if not provided means damage event just won't have any snippets.
        All snippets has parameterized values which are either User-Defined or Injected.
        User-Defined parameters are provided by user, upon calling DamageEngine:damage_unit function.
        Injected params are automatically inserted into function arguments after User-Defined parameters in the exact order as written bellow.

        Available Snippets:
            on_crit -> (trigger when damage done was critical hit, after all damage calculations)
                    -> User-Defined Params:
                        1. f => function (function you want to run)
                        2. (optional) params => values of function parameters packed via table.pack(...)
                    -> Injected Params:
                        1. dmg_done => value of damage done during damage event

            after_damage -> (trigger whenever damage done, after all damage calculations)
                    -> User-Defined Params:
                        1. f => function (function you want to run)
                        2. (optional) params => values of function parameters packed via table.pack(...)
                    -> Injected Params:
                        1. dmg_done => value of damage done during damage event

        Examples:
            on_crit-> Let's say we want to deal damage and also call Ingnite:apply function if the damage was critical
                   DamageEngine:damage_unit(
                            damage_source,damage_target,damage_value,attack_type,damage_type -- these are just standard damage parameters
                            --Last one is our data argument which should contain all Snippets, for our scenario on_crit Snippet will do the work
                            ,{ --data table
                                on_crit = { --on_crit snippet definition
                                    f = Ignite.apply --our function
                                    ,params=table.pack(Ignite,damage_source,damage_target) --function parameters, first is always class reference if it's a class function
                                }
                            }
                   )
        IMPORTANT:
            Now if you check Ignite.apply function has 3 parameters (excluding class ref), but we provided only 2. 3rd parameter is damage. For our scenario we want to use value of damage done during damage event.
            This value will be provided via Injected dmg_done parameter automatically.
            The crucial part is to have these arguments in correct order. Ignite.apply(source,target,damage) since Injected parameters are always pasted in the end after User-Provided ones.
            Ignite.apply(source,damage,target) -> wouldn't work, since after parameter unpacking, damage_target value would be assigned into "damage" and damage_done would be assigned into target.

            It's not mandatory to have Injected params included in the function if you don't need them for your logic. 
            They are always provided by the api, but if function doesn't have them defined, parameter count won't fit and Lua just ignores them.
            So having Ignite.apply(source,target) would work without any issues.

        NOTE: Always provide User-Defined params of a snippet. Those are mandatory. Optionally if you want to also use Injected parameters, make sure you include them in function definition in correct order.
    ]]--

    function de:after_damage(u,seed,dmg_done)
        if seed and Utils:type(seeds[u]) == 'table' and Utils:type(seeds[u][seed]) == 'table' then
            local data = seeds[u][seed]
            if data.after_damage then
                local params = Utils:type(data.after_damage.params) == 'table' and data.after_damage.params or {}
                params[#params + 1] = dmg_done
                data.after_damage.f(table.unpack(params))
            end
        end
    end

    function de:on_crit(u,seed,dmg_done)
        if seed and Utils:type(seeds[u]) == 'table' and Utils:type(seeds[u][seed]) == 'table' then
            local data = seeds[u][seed]
            if data.on_crit then
                local params = Utils:type(data.on_crit.params) == 'table' and data.on_crit.params or {}
                params[#params + 1] = dmg_done
                data.on_crit.f(table.unpack(params))
            end
        end
    end

    function de:damage_unit(args)
        dmg_id[args.source] = args.id
        if args.data then self:new_seed(args.source,args.data) end
        UnitDamageTargetBJ(args.source, args.target, args.damage, args.attack_type, args.damage_type)
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