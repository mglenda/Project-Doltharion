do
    DamageEngine = setmetatable({}, {})
    local de = getmetatable(DamageEngine)
    de.__index = de

    local records = {}

    function de:damage_event()
        local dmg = GetEventDamage() * GetRandomReal(0.99, 1.01)
        local s,t = GetEventDamageSource(),BlzGetEventDamageTarget()
        local id = DamageEngine:get_id(s)
        print(id)
        BlzSetEventDamage(dmg)
        TextTag:create({u=t,s=StringUtils:round(dmg,1)})
    end

    function de:set_id(u,id)
        records[u] = records[u] or {}
        records[u].id = id
    end

    function de:get_id(u)
        return Utils:type(records[u]) == 'table' and records[u].id or FourCC('Aatk')
    end

    function de:damage_unit(s,t,d,at,dt,id)
        UnitDamageTargetBJ(s, t, d, at, dt)
        self:set_id(s,id)
    end

    OnInit.map(function()
        local t = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddAction(t, DamageEngine.damage_event)
    end)
end