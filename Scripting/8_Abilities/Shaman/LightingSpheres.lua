do
    LightingSpheres = setmetatable({}, {})
    local ls = getmetatable(LightingSpheres)
    ls.__index = ls

    local a_code = 'A014'
    local trg = CreateTrigger()
    local t = {}

    function ls:get_a_code()
        return FourCC(a_code)
    end

    function ls:get_a_string()
        return a_code
    end

    function ls:get_s_color()
        return BlzConvertColor(255, 0, 0, 0)
    end

    function ls:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function ls:refresh()
        if Utils:table_length(t) <= 0 then DisableTrigger(trg) end
        for u,tbl in pairs(t) do 
            local x,y,z = Utils:GetUnitXYZ(u)
            for j,s in ipairs(tbl) do
                
            end
            if #tbl == 0 then tbl[u] = nil end
        end
    end

    function ls:add(u)
        local mc = BlzGetAbilityIntegerField(BlzGetUnitAbility(u, FourCC(a_code)), ABILITY_IF_MISSILE_SPEED)
        t[u] = t[u] or {}
        if #t[u] < mc then
            local x,y = Utils:GetUnitXY(u)
            table.insert(t[u],AddSpecialEffect('Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl', x, y))
            BlzSetSpecialEffectScale(t[u][#t[u]], 0.8)
            EnableTrigger(trg)
        end
        if #t[u] >= mc then 
            Abilities:enable_highlight(u,self:get_a_code())
        else
            Abilities:disable_highlight(u,self:get_a_code())
        end
    end

    function ls:consume(x)
        
    end

    OnInit.map(function()
        Data:register_ability_class(LightingSpheres:get_a_code(),LightingSpheres)
        TriggerRegisterTimerEventPeriodic(trg, 0.01)
        TriggerAddAction(trg, LightingSpheres.refresh)
    end)
end