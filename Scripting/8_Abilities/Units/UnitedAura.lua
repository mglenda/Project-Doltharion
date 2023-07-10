do
    UnitedAura = setmetatable({}, {})
    local ua = getmetatable(UnitedAura)
    ua.__index = ua

    local a_code = 'A004'
    local trg = CreateTrigger()

    function ua:get_a_code()
        return FourCC(a_code)
    end

    function ua:get_a_string()
        return a_code
    end

    function ua:get_s_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function ua:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function ua:aura_periodic()
        local ac = 0
        for u,_ in pairs(Units:get_all()) do
            if GetUnitAbilityLevel(u, FourCC(a_code)) > 0 then 
                ac = ac + 1
                if IsUnitAliveBJ(u) then 
                    local uc = 0
                    local aoe = BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, FourCC(a_code)), ABILITY_RLF_AREA_OF_EFFECT, 0)
                    local x,y = Utils:GetUnitXY(u)
                    for _,t in ipairs(Units:get_area_alive_ally(x,y,aoe,GetOwningPlayer(u))) do
                        if t ~= u then uc = uc + 1 end
                    end
                    if uc > 0 then
                        Buffs:apply(u,u,'united',{st = {['attdmg_const'] = {8 * (uc > 10 and 10 or uc)},['resist'] = {6 * (uc > 10 and 10 or uc)}}})
                    else
                        Buffs:clear_buff(u,'united')
                    end
                end
            end
        end
        if ac == 0 then 
            DisableTrigger(trg)
        end
    end

    function ua:enable()
        EnableTrigger(trg)
    end

    function ua:disable()
        DisableTrigger(trg)
    end

    OnInit.map(function()
        Data:register_ability_class(UnitedAura:get_a_code(),UnitedAura)
        TriggerRegisterTimerEventPeriodic(trg, 0.5)
        TriggerAddAction(trg, UnitedAura.aura_periodic)
        UnitedAura:disable()
    end)
end