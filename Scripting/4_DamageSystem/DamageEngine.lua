do
    DamageEngine = setmetatable({}, {})
    local de = getmetatable(DamageEngine)
    de.__index = de

    local records = {}

    function de:damage_event()
        local dmg = GetEventDamage() * GetRandomReal(0.99, 1.01)
        local s,t = GetEventDamageSource(),BlzGetEventDamageTarget()
        local id,ab = DamageEngine:get_id(s),false
        
        dmg = dmg * (1.0 - Resistance:get(t) / 100.0)

        dmg,ab = Absorbs:damage(t,dmg)

        BlzSetEventDamage(dmg < 0 and 0 or dmg)

        local msg = ab and 'Absorbed' or StringUtils:round(dmg,1)
        TextTag:create({u=t,s=msg})
    end

    function de:set_id(u,id)
        records[u] = records[u] or {}
        records[u].id = id
    end

    function de:get_id(u)
        return Utils:type(records[u]) == 'table' and records[u].id or FourCC('Aatk')
    end

    function de:damage_unit(s,t,d,at,dt,id)
        self:set_id(s,id)
        UnitDamageTargetBJ(s, t, d, at, dt)
    end

    OnInit.map(function()
        local t = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddAction(t, DamageEngine.damage_event)
    end)
end