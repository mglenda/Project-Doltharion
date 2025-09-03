do
    AbilitiesPanel = setmetatable({}, {})
    local ap = getmetatable(AbilitiesPanel)
    ap.__index = ap

    function ap:hide()
        DisableTrigger(self.trg)
        if BlzFrameIsVisible(self.listenerCont) then BlzFrameSetVisible(self.listenerCont, false) end
        if BlzFrameIsVisible(self.main) then BlzFrameSetVisible(self.main, false) end
    end

    function ap:show()
        if not(BlzFrameIsVisible(self.listenerCont)) then BlzFrameSetVisible(self.listenerCont, true) end
        if not(BlzFrameIsVisible(self.main)) then BlzFrameSetVisible(self.main, true) end
        EnableTrigger(self.trg)
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
                BlzFrameSetScale(BlzGetFrameByName('AbilityButton_Sprite', tonumber(f_id)), Utils:round(UI:getConst('ab_sprite_def_scale') * (((UI:getConst('ab_border_def_width') * 4) / #tbl) / UI:getConst('ab_border_def_width')),2))
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
        this.trg = CreateTrigger()
        TriggerRegisterTimerEventPeriodic(this.trg, 0.1)
        DisableTrigger(this.trg)
        TriggerAddAction(this.trg, function()
            if UI.a_panel then UI.a_panel:refresh_ability_status_all() end
        end)
        
        local x,y = 0.4 - (2 * UI:getConst('ab_border_def_width')),0.0

        this.main = BlzCreateSimpleFrame('AbilityContainer', UI:getConst('screen_frame'), 0)
        this.listenerCont = BlzCreateFrame('AbilityListenerContainer', UI:getConst('screen_frame'), 0, 0)
        --HOVERING BEHAVIOR UNCOMMENT WHEN/IF ACTIZZARD FIX FRAMEEVENT_MOUSE_ENTER BUG https://us.forums.blizzard.com/en/warcraft3/t/jasslua-frameeventmouseenter-infinite-loop/28659
        this.hoverListener = CreateTrigger()
        
        local prev,cur = nil,nil
        for i,tbl in ipairs(this.predef) do
            for j,f_id in ipairs(tbl) do
                cur = BlzCreateSimpleFrame('AbilityButton_Border', this.main, tonumber(f_id))
                local icon = BlzCreateSimpleFrame('AbilityButton_Icon', cur, tonumber(f_id))
                local shortcut = BlzCreateSimpleFrame('AbilityButton_Shortcut', icon, tonumber(f_id))
                BlzFrameSetPoint(icon, FRAMEPOINT_CENTER, cur, FRAMEPOINT_CENTER, 0, 0)
                BlzFrameSetPoint(shortcut, FRAMEPOINT_BOTTOMRIGHT, icon, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
                local sprite = BlzCreateFrameByType('SPRITE', 'AbilityButton_Sprite', this.listenerCont, "", tonumber(f_id))
                BlzFrameClearAllPoints(sprite)
                BlzFrameSetPoint(sprite, FRAMEPOINT_BOTTOMLEFT, cur, FRAMEPOINT_BOTTOMLEFT, 0, 0)
                BlzFrameSetSize(sprite, 0.00001, 0.00001)
                BlzFrameSetModel(sprite, 'war3mapImported\\neon_sprite.mdx', 0)
                local listener = BlzCreateFrame('AbilityButton_Listener', sprite, 0, tonumber(f_id))
                BlzFrameSetPoint(listener, FRAMEPOINT_CENTER, cur, FRAMEPOINT_CENTER, 0, 0)
                if i == 1 and j == 1 then
                    BlzFrameSetAbsPoint(cur, FRAMEPOINT_BOTTOMLEFT, x, y)
                else
                    BlzFrameSetPoint(cur,j == 1 and FRAMEPOINT_BOTTOMLEFT or FRAMEPOINT_LEFT,j == 1 and BlzGetFrameByName('AbilityButton_Border', tonumber(this.predef[i-1][1])) or prev, j == 1 and FRAMEPOINT_TOPLEFT or FRAMEPOINT_RIGHT, 0, 0)
                    BlzFrameSetScale(cur, ((UI:getConst('ab_border_def_width') * 4) / #tbl) / UI:getConst('ab_border_def_width'))
                    BlzFrameSetScale(listener, ((UI:getConst('ab_border_def_width') * 4) / #tbl) / UI:getConst('ab_border_def_width'))
                    BlzFrameSetScale(sprite, Utils:round(UI:getConst('ab_sprite_def_scale') * (((UI:getConst('ab_border_def_width') * 4) / #tbl) / UI:getConst('ab_border_def_width')),2))
                end

                --HOVERING BEHAVIOR UNCOMMENT WHEN/IF ACTIZZARD FIX FRAMEEVENT_MOUSE_ENTER BUG https://us.forums.blizzard.com/en/warcraft3/t/jasslua-frameeventmouseenter-infinite-loop/28659
                --[[BlzTriggerRegisterFrameEvent(this.hoverListener, listener, FRAMEEVENT_MOUSE_ENTER)
                BlzTriggerRegisterFrameEvent(this.hoverListener, listener, FRAMEEVENT_MOUSE_LEAVE)]]--
                BlzTriggerRegisterFrameEvent(this.hoverListener, listener, FRAMEEVENT_CONTROL_CLICK)
                prev = cur
            end
        end
        TriggerAddAction(this.hoverListener, function()
            --HOVERING BEHAVIOR UNCOMMENT WHEN/IF ACTIZZARD FIX FRAMEEVENT_MOUSE_ENTER BUG https://us.forums.blizzard.com/en/warcraft3/t/jasslua-frameeventmouseenter-infinite-loop/28659
            --[[local x = BlzGetAbilityIntegerField(BlzGetUnitAbility(Hero:get(), this:getAbilityByListener(BlzGetTriggerFrame())), ABILITY_IF_BUTTON_POSITION_NORMAL_X)
            local y = BlzGetAbilityIntegerField(BlzGetUnitAbility(Hero:get(), this:getAbilityByListener(BlzGetTriggerFrame())), ABILITY_IF_BUTTON_POSITION_NORMAL_Y)
            if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_ENTER then
                BlzFrameSetVisible(BlzGetFrameByName('AbilityButton_FocusLayer', tonumber(x .. y)), true)
            elseif BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_LEAVE then
                BlzFrameSetVisible(BlzGetFrameByName('AbilityButton_FocusLayer', tonumber(x .. y)), false)
            end]]--
            if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
                BlzFrameSetEnable(BlzGetTriggerFrame(), false)
                BlzFrameSetEnable(BlzGetTriggerFrame(), true)
            end
        end)

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
                BlzFrameSetVisible(BlzGetFrameByName("AbilityButton_Sprite", tonumber(f_id)), false)
                BlzFrameSetVisible(BlzGetFrameByName(string.sub(f_id, -1) == '2' and "AbilityButton_Border" or "AbilityButton_Icon", tonumber(f_id)), false)
            end
        end
    end

    function ap:reset()
        self.list = {}
        self:hideIcons()
    end

    function ap:setNormal(ac)
        if Utils:type(self.list[ac]) == 'table' then 
            self.list[ac][2] = false
            self.list[ac][3] = false
            BlzFrameSetTexture(self.list[ac][1], 'war3mapImported\\BTN' .. GetAbilityName(ac):gsub(" ","") .. '.dds', 0, true)
            BlzFrameSetTextColor(self.list[ac][4], Data:get_ability_class(ac):get_s_color())
        end
    end

    function ap:setPushed(ac)
        if Utils:type(self.list[ac]) == 'table' then 
            self.list[ac][3] = false
            if not(self.list[ac][2]) then
                self:refresh_ability_status(ac)
                BlzFrameSetTexture(self.list[ac][1], 'war3mapImported\\BTN' .. GetAbilityName(ac):gsub(" ","") .. 'Pushed.dds', 0, true)
            end
            self.list[ac][2] = true
        end
    end

    function ap:setDisabled(ac)
        if Utils:type(self.list[ac]) == 'table' then 
            self.list[ac][2] = false
            if not(self.list[ac][3]) then 
                BlzFrameSetTexture(self.list[ac][1], 'war3mapImported\\BTN' .. GetAbilityName(ac):gsub(" ","") .. 'Disabled.dds', 0, true) 
                BlzFrameSetTextColor(self.list[ac][4], Data:get_ability_class(ac):get_c_color())
            end
            self.list[ac][3] = true
        end
    end

    function ap:getAbilityByListener(frame)
        return self.listeners[frame]
    end

    function ap:getListenerByAbility(abCode)
        for frame,v in pairs(self.listeners) do
            if v == abCode then return frame end
        end
        return nil
    end

    function ap:refresh_ability_status_all()
        if self.list then 
            for ac,v in pairs(self.list) do
                self:refresh_ability_status(ac)
            end
        end
    end

    function ap:refresh_ability_status(ac)
        local s,st,c,ih = Abilities:get_ability_status(Hero:get(),ac)
        if not(self.list[ac][2]) then
            if s == 'rdy' then 
                self:setNormal(ac)
                BlzFrameSetText(self.list[ac][4], st > 1 and StringUtils:round(st,0) or '')
            elseif s == 'cd' then 
                self:setDisabled(ac) 
                BlzFrameSetText(self.list[ac][4], StringUtils:round(c,1))
            elseif s == 'silenced' then
                self:setDisabled(ac)
                BlzFrameSetText(self.list[ac][4], '')
            end
        end
        BlzFrameSetVisible(self.list[ac][5], ih and s == 'rdy')
    end
    
    function ap:loadUnit(u)
        self:reset()
        for _,v in ipairs(ObjectUtils:getUnitAbilities(u)) do
            if v.ac ~= 'Aatk' then
                local x = BlzGetAbilityIntegerField(BlzGetUnitAbility(u, FourCC(v.ac)), ABILITY_IF_BUTTON_POSITION_NORMAL_X)
                local y = BlzGetAbilityIntegerField(BlzGetUnitAbility(u, FourCC(v.ac)), ABILITY_IF_BUTTON_POSITION_NORMAL_Y)
                if BlzGetFrameByName('AbilityButton_Icon', tonumber(x .. y)) then
                    BlzFrameSetVisible(BlzGetFrameByName(y == 2 and "AbilityButton_Border" or "AbilityButton_Icon", tonumber(x .. y)), true)
                    BlzFrameSetVisible(BlzGetFrameByName('AbilityButton_Listener', tonumber(x .. y)), true)
                    local sc = BlzGetAbilityActivatedTooltip(FourCC(v.ac), GetUnitAbilityLevel(u,FourCC(v.ac)))
                    BlzFrameSetVisible(BlzGetFrameByName('AbilityButton_Shortcut', tonumber(x .. y)), not(sc == 'Tool tip missing!' or sc:sub(1, 1) == '_'))
                    BlzFrameSetText(BlzGetFrameByName('AbilityButton_Shortcut_Text', tonumber(x .. y)), sc == 'Tool tip missing!' and '' or sc:sub(1, 1))
                    BlzFrameSetText(BlzGetFrameByName('AbilityButton_Icon_Text', tonumber(x .. y)),'')
                    BlzFrameSetTexture(BlzGetFrameByName('AbilityButton_Icon_Texture', tonumber(x .. y)), 'war3mapImported\\BTN' .. GetAbilityName(FourCC(v.ac)):gsub(" ","") .. '.dds', 0, true)
                    self.list[FourCC(v.ac)] = {BlzGetFrameByName('AbilityButton_Icon_Texture', tonumber(x .. y)),false,false,BlzGetFrameByName('AbilityButton_Icon_Text', tonumber(x .. y)),BlzGetFrameByName('AbilityButton_Sprite', tonumber(x .. y))}
                    self.listeners[BlzGetFrameByName('AbilityButton_Listener', tonumber(x .. y))] = FourCC(v.ac)
                end 
            end
        end
        self:show()
    end
end