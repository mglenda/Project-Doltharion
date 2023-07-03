do
    EmpireBanner = setmetatable({}, {})
    local eb = getmetatable(EmpireBanner)
    eb.__index = eb

    local a_code = 'A006'
    local trg = CreateTrigger()

    function eb:get_a_code()
        return FourCC(a_code)
    end

    function eb:get_s_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function eb:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function eb:aura_periodic()
        local ac = 0
        for u,_ in pairs(Units:get_all()) do
            if GetUnitAbilityLevel(u, FourCC(a_code)) > 0 then 
                ac = ac + 1
                if IsUnitAliveBJ(u) then 
                    local ut = {}
                    local aoe = BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, FourCC(a_code)), ABILITY_RLF_AREA_OF_EFFECT, 0)
                    local x,y = Utils:GetUnitXY(u)
                    for _,t in ipairs(Units:get_area_alive_ally(x,y,aoe,GetOwningPlayer(u))) do
                        table.insert(ut,t)
                    end
                    for _,t in ipairs(ut) do
                        Buffs:apply(u,t,'empired',{
                            e = t == u and {{m = 'Abilities\\Spells\\Human\\DevotionAura\\DevotionAura.mdl',a = 'origin'}} or nil 
                            ,st = {['attdmg_factor'] = {1 + (0.02 * #ut)},['spepow_factor'] = {1 + (0.02 * #ut)},['attpow_factor'] = {1 + (0.02 * #ut)}}
                        })
                    end
                end
            end
        end
        if ac == 0 then 
            DisableTrigger(trg)
        end
    end

    function eb:enable()
        EnableTrigger(trg)
    end

    function eb:disable()
        DisableTrigger(trg)
    end

    OnInit.map(function()
        Data:register_ability_class(EmpireBanner:get_a_code(),EmpireBanner)
        TriggerRegisterTimerEventPeriodic(trg, 1.0)
        TriggerAddAction(trg, EmpireBanner.aura_periodic)
        EmpireBanner:disable()
    end)
end