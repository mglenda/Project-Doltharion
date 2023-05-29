do
    AbilitiesPanel = setmetatable({}, {})
    local ap = getmetatable(AbilitiesPanel)
    ap.__index = ap

    function ap:hide()
        if BlzFrameIsVisible(self.listenerCont) then BlzFrameSetVisible(self.listenerCont, false) end
        if BlzFrameIsVisible(self.main) then BlzFrameSetVisible(self.main, false) end
    end

    function ap:show()
        if not(BlzFrameIsVisible(self.listenerCont)) then BlzFrameSetVisible(self.listenerCont, true) end
        if not(BlzFrameIsVisible(self.main)) then BlzFrameSetVisible(self.main, true) end
    end

    function ap:rescale()
        local x,y,s = 0.4 - (2 * UI:getConst('ab_border_def_width')),0.0,1.0
        for i,tbl in ipairs(self.predef) do
            for j,f_id in ipairs(tbl) do
                if i == 1 and j == 1 then
                    BlzFrameSetAbsPoint(BlzGetFrameByName('AbilityButton_Border', tonumber(f_id)), FRAMEPOINT_BOTTOMLEFT, x, y)
                    s = UI:getConst('ab_border_def_width') / BlzFrameGetWidth(BlzGetFrameByName('AbilityButton_Border', tonumber(f_id)))
                end
                BlzFrameSetScale(BlzGetFrameByName('AbilityButton_Border', tonumber(f_id)), (s * 4) / #tbl)
                BlzFrameSetScale(BlzGetFrameByName('AbilityButton_Listener', tonumber(f_id)), (s * 4) / #tbl)
            end
        end
    end

    function ap:create()
        local this = {}
        setmetatable(this, ap)

        this.predef = {
            {'00','10','20','30'} --BOTTOM ROW
            ,{'01','11','21','31'} -- MIDDLE ROW
            ,{'02','12','22','32','42'} -- TOP ROW
        }
        this.list = {}
        this.listeners = {}
        
        local x,y = 0.4 - (2 * UI:getConst('ab_border_def_width')),0.0

        this.main = BlzCreateSimpleFrame('AbilityContainer', UI:getConst('screen_frame'), 0)
        this.listenerCont = BlzCreateFrame('AbilityListenerContainer', UI:getConst('screen_frame'), 0, 0)
        --HOVERING BEHAVIOR UNCOMMENT WHEN/IF ACTIZZARD FIX FRAMEEVENT_MOUSE_ENTER BUG https://us.forums.blizzard.com/en/warcraft3/t/jasslua-frameeventmouseenter-infinite-loop/28659
        --this.hoverListener = CreateTrigger()
        
        local prev,cur = nil,nil
        for i,tbl in ipairs(this.predef) do
            for j,f_id in ipairs(tbl) do
                cur = BlzCreateSimpleFrame('AbilityButton_Border', this.main, tonumber(f_id))
                local icon = BlzCreateSimpleFrame('AbilityButton_Icon', cur, tonumber(f_id))
                local focus = BlzCreateSimpleFrame('AbilityButton_FocusLayer', cur, tonumber(f_id))
                local shortcut = BlzCreateSimpleFrame('AbilityButton_Shortcut', icon, tonumber(f_id))
                local listener = BlzCreateFrame('AbilityButton_Listener', this.listenerCont, 0, tonumber(f_id))
                BlzFrameSetPoint(icon, FRAMEPOINT_CENTER, cur, FRAMEPOINT_CENTER, 0, 0)
                BlzFrameSetPoint(shortcut, FRAMEPOINT_BOTTOMRIGHT, icon, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
                BlzFrameSetPoint(listener, FRAMEPOINT_CENTER, cur, FRAMEPOINT_CENTER, 0, 0)
                BlzFrameSetPoint(focus, FRAMEPOINT_CENTER, cur, FRAMEPOINT_CENTER, 0, 0)
                BlzFrameSetVisible(focus, false)
                if i == 1 and j == 1 then
                    BlzFrameSetAbsPoint(cur, FRAMEPOINT_BOTTOMLEFT, x, y)
                else
                    BlzFrameSetPoint(cur,j == 1 and FRAMEPOINT_BOTTOMLEFT or FRAMEPOINT_LEFT,j == 1 and BlzGetFrameByName('AbilityButton_Border', tonumber(this.predef[i-1][1])) or prev, j == 1 and FRAMEPOINT_TOPLEFT or FRAMEPOINT_RIGHT, 0, 0)
                    BlzFrameSetScale(cur, ((UI:getConst('ab_border_def_width') * 4) / #tbl) / UI:getConst('ab_border_def_width'))
                    BlzFrameSetScale(listener, ((UI:getConst('ab_border_def_width') * 4) / #tbl) / UI:getConst('ab_border_def_width'))
                end

                --HOVERING BEHAVIOR UNCOMMENT WHEN/IF ACTIZZARD FIX FRAMEEVENT_MOUSE_ENTER BUG https://us.forums.blizzard.com/en/warcraft3/t/jasslua-frameeventmouseenter-infinite-loop/28659
                --[[BlzTriggerRegisterFrameEvent(this.hoverListener, listener, FRAMEEVENT_MOUSE_ENTER)
                BlzTriggerRegisterFrameEvent(this.hoverListener, listener, FRAMEEVENT_MOUSE_LEAVE)]]--
                prev = cur
            end
        end
        --HOVERING BEHAVIOR UNCOMMENT WHEN/IF ACTIZZARD FIX FRAMEEVENT_MOUSE_ENTER BUG https://us.forums.blizzard.com/en/warcraft3/t/jasslua-frameeventmouseenter-infinite-loop/28659
        --[[TriggerAddAction(this.hoverListener, function()
            local x = BlzGetAbilityIntegerField(BlzGetUnitAbility(Hero:get(), this:getAbilityByListener(BlzGetTriggerFrame())), ABILITY_IF_BUTTON_POSITION_NORMAL_X)
            local y = BlzGetAbilityIntegerField(BlzGetUnitAbility(Hero:get(), this:getAbilityByListener(BlzGetTriggerFrame())), ABILITY_IF_BUTTON_POSITION_NORMAL_Y)
            if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_ENTER then
                BlzFrameSetVisible(BlzGetFrameByName('AbilityButton_FocusLayer', tonumber(x .. y)), true)
            elseif BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_LEAVE then
                BlzFrameSetVisible(BlzGetFrameByName('AbilityButton_FocusLayer', tonumber(x .. y)), false)
            end
        end)]]--

        this:hideIcons()

        return this
    end

    function ap:disableHovering()
        if IsTriggerEnabled(self.hoverListener) then
            DisableTrigger(self.hoverListener)
        end
    end

    function ap:enableHovering()
        if not(IsTriggerEnabled(self.hoverListener)) then
            EnableTrigger(self.hoverListener)
        end
    end

    function ap:hideIcons()
        for i,tbl in ipairs(self.predef) do
            for j,f_id in ipairs(tbl) do
                BlzFrameSetVisible(BlzGetFrameByName("AbilityButton_Listener", tonumber(f_id)), false)
                BlzFrameSetVisible(BlzGetFrameByName(string.sub(f_id, -1) == '2' and "AbilityButton_Border" or "AbilityButton_Icon", tonumber(f_id)), false)
            end
        end
    end

    function ap:reset()
        self:hideIcons()
        Controller:destroy('ui_abilities')
        self.list = {}
    end

    function ap:setNormal(frame)
        BlzFrameSetTexture(frame, 'ReplaceableTextures\\CommandButtons\\BTN' .. GetAbilityName(self:getAbilityByFrame(frame)):gsub(" ","") .. '.dds', 0, true)
    end

    function ap:setPushed(frame)
        BlzFrameSetTexture(frame, 'ReplaceableTextures\\CommandButtons\\BTN' .. GetAbilityName(self:getAbilityByFrame(frame)):gsub(" ","") .. 'Pushed.dds', 0, true)
    end

    function ap:getAbilityByFrame(frame)
        return self.list[frame]
    end

    function ap:getAbilityByListener(frame)
        return self.listeners[frame]
    end

    function ap:getFrameByAbility(abCode)
        for frame,v in pairs(self.list) do
            if v == abCode then return frame end
        end
        return nil
    end

    function ap:getListenerByAbility(abCode)
        for frame,v in pairs(self.listeners) do
            if v == abCode then return frame end
        end
        return nil
    end
    
    function ap:loadUnit(u)
        self:reset()
        for _,v in ipairs(ObjectUtils:getUnitAbilities(u)) do
            if v ~= 'Aatk' then
                local x = BlzGetAbilityIntegerField(BlzGetUnitAbility(u, FourCC(v)), ABILITY_IF_BUTTON_POSITION_NORMAL_X)
                local y = BlzGetAbilityIntegerField(BlzGetUnitAbility(u, FourCC(v)), ABILITY_IF_BUTTON_POSITION_NORMAL_Y)
                if BlzGetFrameByName('AbilityButton_Icon', tonumber(x .. y)) then
                    BlzFrameSetVisible(BlzGetFrameByName(y == 2 and "AbilityButton_Border" or "AbilityButton_Icon", tonumber(x .. y)), true)
                    BlzFrameSetVisible(BlzGetFrameByName('AbilityButton_Listener', tonumber(x .. y)), true)
                    local sc = BlzGetAbilityActivatedTooltip(FourCC(v), GetUnitAbilityLevel(u,FourCC(v)))
                    BlzFrameSetVisible(BlzGetFrameByName('AbilityButton_Shortcut', tonumber(x .. y)), not(sc == 'Tool tip missing!'))
                    BlzFrameSetText(BlzGetFrameByName('AbilityButton_Shortcut_Text', tonumber(x .. y)), sc == 'Tool tip missing!' and '' or sc:sub(1, 1))
                    BlzFrameSetTexture(BlzGetFrameByName('AbilityButton_Icon_Texture', tonumber(x .. y)), 'ReplaceableTextures\\CommandButtons\\BTN' .. GetAbilityName(FourCC(v)):gsub(" ","") .. '.dds', 0, true)
                    self.list[BlzGetFrameByName('AbilityButton_Icon_Texture', tonumber(x .. y))] = FourCC(v)
                    self.listeners[BlzGetFrameByName('AbilityButton_Listener', tonumber(x .. y))] = FourCC(v)
                end 
            end
        end
    end
end