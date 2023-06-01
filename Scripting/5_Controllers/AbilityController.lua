do
    AbilityController = setmetatable({}, {})
    local ac = getmetatable(AbilityController)
    ac.__index = ac

    local list = {}

    function ac:load()
        for _,v in ipairs(ObjectUtils:getUnitAbilities(Hero:get())) do
            if v ~= 'Aatk' then
                local d = BlzGetAbilityActivatedTooltip(FourCC(v), GetUnitAbilityLevel(Hero:get(),FourCC(v)))
                if d ~= 'Tool tip missing!' then
                    local castOsKey,castType,castForcedKey = ConvertOsKeyType(string.byte(d:sub(1,1))) ,d:sub(3,3),d:sub(5,5)
                    local tbl = {
                        trg = CreateTrigger()
                        ,order = String2OrderIdBJ(BlzGetAbilityStringLevelField(BlzGetUnitAbility(Hero:get(), FourCC(v)), ABILITY_SLF_BASE_ORDER_ID_NCL6, 0))
                        ,forcedKey = castForcedKey
                    }
                    local x = BlzGetAbilityIntegerField(BlzGetUnitAbility(Hero:get(), FourCC(v)), ABILITY_IF_BUTTON_POSITION_NORMAL_X)
                    local y = BlzGetAbilityIntegerField(BlzGetUnitAbility(Hero:get(), FourCC(v)), ABILITY_IF_BUTTON_POSITION_NORMAL_Y)

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

    function ac:flush()
        for i = #list,1,-1 do
            DestroyTrigger(list[i].trg)
            table.remove(list, i)
        end
    end

    function ac:getOrder(trg)
        for _,v in ipairs(list) do
            if v.trg == trg then
                return v.order
            end
        end
        return nil
    end

    function ac:getForcedKey(trg)
        for _,v in ipairs(list) do
            if v.trg == trg then
                return v.forcedKey
            end
        end
        return nil
    end

    function ac:reset()
        self:flush()
        self:load()
    end

    function ac:noTarget()
        local order = AbilityController:getOrder(GetTriggeringTrigger())
        if not(Hero:isCasting()) or order ~= Hero:isCasting() then
            CastingController:setOrder(order)
            IssueImmediateOrderById(Hero:get(),order)
        end
        if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
            BlzFrameSetEnable(BlzGetTriggerFrame(), false)
            BlzFrameSetEnable(BlzGetTriggerFrame(), true)
        end
    end

    function ac:unitTarget()
        local order = AbilityController:getOrder(GetTriggeringTrigger())
        if not(Hero:isCasting()) or order ~= Hero:isCasting() then
            CastingController:setOrder(order)
            IssueTargetOrderById(Hero:get(), order, BlzGetTriggerPlayerMetaKey() == 1 and Hero:get() or Target:get())
        end
        if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
            BlzFrameSetEnable(BlzGetTriggerFrame(), false)
            BlzFrameSetEnable(BlzGetTriggerFrame(), true)
        end
    end

    function ac:pointTarget()
        local order = AbilityController:getOrder(GetTriggeringTrigger())
        if not(Hero:isCasting()) or order ~= Hero:isCasting() then
            CastingController:setOrder(order)
            ForceUIKeyBJ(Players:get_player(), AbilityController:getForcedKey(GetTriggeringTrigger()))
        end
        if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
            BlzFrameSetEnable(BlzGetTriggerFrame(), false)
            BlzFrameSetEnable(BlzGetTriggerFrame(), true)
        end
    end
end