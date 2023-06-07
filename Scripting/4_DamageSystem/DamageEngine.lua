do
    DamageEngine = setmetatable({}, {})
    local de = getmetatable(DamageEngine)
    de.__index = de

    local records = {}
    local dcm = 1.5 --default crit multiplier

    function de:damage_event()
        local dmg = GetEventDamage() * GetRandomReal(0.99, 1.01)
        local s,t = GetEventDamageSource(),BlzGetEventDamageTarget()
        local id,ab = DamageEngine:get_id(s),false
        --Critical Strike
        local crit = CriticalChance:get(s) >= GetRandomInt(1, 100)
        if crit then dmg = dmg * dcm end
        --Resistance Apply
        dmg = dmg * (1.0 - Resistance:get(t) / 100.0)
        --Absorbs Apply
        dmg,ab = Absorbs:damage(t,dmg)

        BlzSetEventDamage(dmg < 0 and 0 or dmg)

        if GetOwningPlayer(s) == Players:get_player() or crit then
            local msg = ab and 'Absorbed' or (dmg > 0 and (crit and StringUtils:round(dmg,1) .. '!' or StringUtils:round(dmg,1)) or '')
            TextTag:create({u=t,s=msg,fs=crit and TextTag:defFontSize() * 1.2 or TextTag:defFontSize(),ls = crit and 2.5 or 1.0})
        end
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