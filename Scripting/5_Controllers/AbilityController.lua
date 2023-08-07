do
    AbilityController = setmetatable({}, {})
    local ac = getmetatable(AbilityController)
    ac.__index = ac

    local list = {}
    local trg = CreateTrigger()

    function ac:load()
        for _,v in ipairs(ObjectUtils:getUnitAbilities(Hero:get())) do
            if v.ac ~= 'Aatk' then
                local d = BlzGetAbilityActivatedTooltip(FourCC(v.ac), GetUnitAbilityLevel(Hero:get(),FourCC(v.ac)))
                if d ~= 'Tool tip missing!' then
                    local castOsKey,castType,castForcedKey,cliqueKey = ConvertOsKeyType(string.byte(d:sub(1,1))) ,d:sub(3,3),d:sub(5,5),d:sub(9,9)
                    local tbl = {
                        trg = CreateTrigger()
                        ,order = String2OrderIdBJ(BlzGetAbilityStringLevelField(BlzGetUnitAbility(Hero:get(), FourCC(v.ac)), ABILITY_SLF_BASE_ORDER_ID_NCL6, 0))
                        ,forcedKey = castForcedKey
                        ,ac = FourCC(v.ac)
                        ,cliqueKey = tonumber(cliqueKey)
                    }
                    local x = BlzGetAbilityIntegerField(BlzGetUnitAbility(Hero:get(), FourCC(v.ac)), ABILITY_IF_BUTTON_POSITION_NORMAL_X)
                    local y = BlzGetAbilityIntegerField(BlzGetUnitAbility(Hero:get(), FourCC(v.ac)), ABILITY_IF_BUTTON_POSITION_NORMAL_Y)

                    BlzTriggerRegisterFrameEvent(tbl.trg, BlzGetFrameByName('AbilityButton_Listener', tonumber(x .. y)), FRAMEEVENT_CONTROL_CLICK)
                    BlzTriggerRegisterPlayerKeyEvent(tbl.trg, Players:get_player(), castOsKey, 0, true)
                    BlzTriggerRegisterPlayerKeyEvent(tbl.trg, Players:get_player(), castOsKey, 1, true)
                    if castType == 'I' then
                        TriggerAddAction(tbl.trg, self.noTarget)
                    elseif castType == 'U' then
                        TriggerAddAction(tbl.trg, self.unitTarget)
                    elseif castType == 'P' then
                        TriggerAddAction(tbl.trg, self.pointTarget)
                    end
                    table.insert(list,tbl)
                end
            end
        end
    end

    function ac:get_clique_data(cliqueKey)
        for _,v in ipairs(list) do
            if v.cliqueKey == cliqueKey then return v.order,v.ac end
        end
        return nil,nil
    end

    function ac:flush()
        for i = #list,1,-1 do
            DestroyTrigger(list[i].trg)
            table.remove(list, i)
        end
    end

    function ac:getData(trg)
        for _,v in ipairs(list) do
            if v.trg == trg then
                return v.order,v.forcedKey,v.ac
            end
        end
        return nil,nil,nil
    end

    function ac:reset()
        self:flush()
        self:load()
    end

    function ac:noTarget()
        local order,fKey,ac = AbilityController:getData(GetTriggeringTrigger())
        if Abilities:is_ability_available(Hero:get(),ac) and (not(Hero:isCasting()) or order ~= Hero:isCasting()) then
            CastingController:setOrder(order)
            IssueImmediateOrderById(Hero:get(),order)
        end
    end

    function ac:unitTarget()
        local order,fKey,ac = AbilityController:getData(GetTriggeringTrigger())
        local t = BlzGetTriggerPlayerMetaKey() == 1 and Hero:get() or Target:get()
        if Abilities:is_ability_available(Hero:get(),ac) and (not(Hero:isCasting()) or order ~= Hero:isCasting()) and (not(CastingController:getOrder()) or order ~= CastingController:getOrder() or t ~= CastingController:getTarget()) then
            CastingController:setOrder(order, t)
            IssueTargetOrderById(Hero:get(), order, t)
        end
    end

    function ac:pointTarget()
        local order,fKey,ac = AbilityController:getData(GetTriggeringTrigger())
        if Abilities:is_ability_available(Hero:get(),ac) and (not(Hero:isCasting()) or order ~= Hero:isCasting()) then
            CastingController:setOrder(order)
            ForceUIKeyBJ(Players:get_player(), fKey)
        end
    end

    OnInit.final(function()
        TriggerRegisterAnyUnitEventBJ(trg,EVENT_PLAYER_UNIT_ISSUED_ORDER)
        TriggerRegisterAnyUnitEventBJ(trg,EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
        TriggerRegisterAnyUnitEventBJ(trg,EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
        TriggerAddAction(trg, function()
            if GetOrderedUnit() == Hero:get() and GetIssuedOrderId() ~= CastingController:getOrder() then
                CastingController:clearOrder()
            end
        end)
    end)
end