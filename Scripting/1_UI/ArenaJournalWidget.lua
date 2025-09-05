do
    ArenaJournalWidget = setmetatable({}, {})
    local ajw = getmetatable(ArenaJournalWidget)
    ajw.__index = ajw

    local path_active = 'war3mapImported\\ArenaWidgetActive.dds'
    local path_normal = 'war3mapImported\\ArenaWidgetEnabled.dds'
    local path_disabled = 'war3mapImported\\ArenaWidgetDisabled.dds'
    local path_focused = 'war3mapImported\\ArenaWidgetPushed.dds'

    local trigger = CreateTrigger()
    local d_listener = CreateTrigger()
    local widget_container = {}
    local active_widget = nil

    function ajw:hide()
        BlzFrameSetVisible(self.listener, false)
    end

    function ajw:show()
        BlzFrameSetVisible(self.listener, true)
        self:deactivate()
        if not(self.arena.d_avail[Arena.DIFFICULTY_NORMAL]) then 
            self:disable() 
        else
            self:enable()
        end
    end

    function ajw:get()
        return self.main
    end

    function ajw:get_listener()
        return self.listener
    end

    function ajw:get_normal_button()
        return self.normal_button
    end

    function ajw:get_heroic_button()
        return self.heroic_button
    end

    function ajw:get_mythic_button()
        return self.mythic_button
    end

    function ajw:enter()
        if active_widget ~= self then
            BlzFrameSetTexture(self.texture, path_focused, 0, true)
        end
    end

    function ajw:leave()
        if active_widget ~= self then
            BlzFrameSetTexture(self.texture, path_normal, 0, true)
        end
    end

    function ajw:click()
        self:activate()
    end

    function ajw:activate()
        if active_widget then
            active_widget:deactivate()
        end
        active_widget = self
        BlzFrameSetEnable(self.listener, false)
        BlzFrameSetTexture(self.texture, path_active, 0, true)
        BlzFrameSetVisible(self.difficulty_layer, true, 190)
        self:refresh_difficulties()
    end

    function ajw:refresh_difficulties()
        if self.arena then
            BlzFrameClearAllPoints(self.normal_button)
            BlzFrameClearAllPoints(self.heroic_button)
            BlzFrameClearAllPoints(self.mythic_button)
            BlzFrameSetAlpha(self.normal_button, 255)
            BlzFrameSetAlpha(self.heroic_button, 255)

            BlzFrameSetEnable(self.heroic_button, self.arena.d_avail[Arena.DIFFICULTY_HEROIC])
            BlzFrameSetEnable(self.normal_button, self.arena.d_avail[Arena.DIFFICULTY_NORMAL])

            if not(self.arena.d_avail[Arena.DIFFICULTY_HEROIC]) then
                BlzFrameSetTexture(self.heroic_button_texture, 'war3mapImported\\DISBTN_Heroic.dds', 0, true)
            else
                BlzFrameSetTexture(self.heroic_button_texture, self.arena.d_beaten[Arena.DIFFICULTY_HEROIC] and 'war3mapImported\\BTN_HeroicDone.dds' or 'war3mapImported\\BTN_Heroic.dds', 0, true)
            end

            if not(self.arena.d_avail[Arena.DIFFICULTY_NORMAL]) then
                BlzFrameSetTexture(self.normal_button_texture, 'war3mapImported\\DISBTN_Normal.dds', 0, true)
            else
                BlzFrameSetTexture(self.normal_button_texture, self.arena.d_beaten[Arena.DIFFICULTY_NORMAL] and 'war3mapImported\\BTN_NormalDone.dds' or 'war3mapImported\\BTN_Normal.dds', 0, true)
            end

            if self.arena.d_avail[Arena.DIFFICULTY_MYTHIC] then
                BlzFrameSetVisible(self.mythic_button, true)
                BlzFrameSetSize(self.normal_button, 0.025, 0.025)
                BlzFrameSetSize(self.heroic_button, 0.025, 0.025)
                BlzFrameSetSize(self.mythic_button, 0.045, 0.045)
                BlzFrameSetPoint(self.mythic_button, FRAMEPOINT_TOP, self.difficulty_layer, FRAMEPOINT_TOP, 0, -0.0125)
                BlzFrameSetPoint(self.normal_button, FRAMEPOINT_BOTTOMRIGHT, self.mythic_button, FRAMEPOINT_LEFT, -0.02125, 0)
                BlzFrameSetPoint(self.heroic_button, FRAMEPOINT_BOTTOMLEFT, self.mythic_button, FRAMEPOINT_RIGHT, 0.02125, 0)
                BlzFrameSetAlpha(self.mythic_button, 255)
            else
                BlzFrameSetVisible(self.mythic_button, false)
                BlzFrameSetSize(self.normal_button, 0.04, 0.04)
                BlzFrameSetSize(self.heroic_button, 0.04, 0.04)
                BlzFrameSetPoint(self.normal_button, FRAMEPOINT_TOPLEFT, self.difficulty_layer, FRAMEPOINT_TOPLEFT, 0.033, -0.015)
                BlzFrameSetPoint(self.heroic_button, FRAMEPOINT_TOPLEFT, self.normal_button, FRAMEPOINT_TOPRIGHT, 0.033, 0)
            end
        end
    end

    function ajw:deactivate()
        BlzFrameSetTexture(self.texture, path_normal, 0, true)
        BlzFrameSetEnable(self.listener, true)
        BlzFrameSetVisible(self.difficulty_layer, false)
        if self == active_widget then
            active_widget = nil
        end
    end

    function ajw:get_active_widget()
        return active_widget
    end

    function ajw:enable()
        BlzFrameSetVisible(self.disable_layer, false)
        BlzFrameSetEnable(self.listener, true)
    end

    function ajw:disable()
        self:deactivate()
        BlzFrameSetVisible(self.disable_layer, true, 230)
        BlzFrameSetEnable(self.listener, false)
    end

    function ajw:create(id,arena)
        local this = {}
        setmetatable(this, ajw)

        this.main = BlzCreateSimpleFrame('boss_widget_button', ArenaJournal:get(), id)
        this.texture = BlzGetFrameByName('boss_widget_button_texture', id)
        local theme = BlzCreateSimpleFrame('boss_widget_theme', this.main, id)
        this.theme = BlzGetFrameByName('boss_widget_theme_texture',id)
        this.difficulty_layer = BlzCreateSimpleFrame('boss_widget_difficulty_layer', theme, id)
        this.disable_layer = BlzCreateSimpleFrame('boss_widget_disable_layer', theme, id)

        this.listener = BlzCreateFrame('boss_widget_listener', UI:getConst('screen_frame'), 0, id)

        this.normal_button = BlzCreateSimpleFrame('boss_widget_difficulty_normal', this.difficulty_layer, id)
        this.heroic_button = BlzCreateSimpleFrame('boss_widget_difficulty_heroic', this.difficulty_layer, id)
        this.mythic_button = BlzCreateSimpleFrame('boss_widget_difficulty_mythic', this.difficulty_layer, id)

        this.normal_button_texture = BlzGetFrameByName('boss_widget_difficulty_normal_icon', id)
        this.heroic_button_texture = BlzGetFrameByName('boss_widget_difficulty_heroic_icon', id)
        this.mythic_button_texture = BlzGetFrameByName('boss_widget_difficulty_mythic_icon', id)

        BlzFrameSetPoint(theme, FRAMEPOINT_CENTER, this.main, FRAMEPOINT_CENTER, 0, 0)
        BlzFrameSetPoint(this.difficulty_layer, FRAMEPOINT_CENTER, theme, FRAMEPOINT_CENTER, 0, 0)
        BlzFrameSetPoint(this.disable_layer, FRAMEPOINT_CENTER, theme, FRAMEPOINT_CENTER, 0, 0)
        BlzFrameSetPoint(this.listener, FRAMEPOINT_CENTER, this.main, FRAMEPOINT_CENTER, 0, 0)

        BlzFrameSetVisible(this.difficulty_layer, false)
        BlzFrameSetVisible(this.disable_layer, false)

        BlzTriggerRegisterFrameEvent(trigger, this.listener, FRAMEEVENT_CONTROL_CLICK)
        BlzTriggerRegisterFrameEvent(trigger, this.listener, FRAMEEVENT_MOUSE_ENTER)
        BlzTriggerRegisterFrameEvent(trigger, this.listener, FRAMEEVENT_MOUSE_LEAVE)

        BlzTriggerRegisterFrameEvent(d_listener, this.normal_button, FRAMEEVENT_CONTROL_CLICK)
        BlzTriggerRegisterFrameEvent(d_listener, this.heroic_button, FRAMEEVENT_CONTROL_CLICK)
        BlzTriggerRegisterFrameEvent(d_listener, this.mythic_button, FRAMEEVENT_CONTROL_CLICK)

        this.arena = arena
        this.id = id
        BlzFrameSetTexture(this.theme, arena:get_img(), 0, true)

        table.insert(widget_container,this)

        return this
    end

    function ajw:get_event_widget(event_frame)
        for _,w in ipairs(widget_container) do
            if w:get_listener() == event_frame or w:get_normal_button() == event_frame or w:get_heroic_button() == event_frame or w:get_mythic_button() == event_frame then
                return w
            end
        end
        return nil
    end

    --Difficulty Chosen
    function ajw:d_listener_func()
        local frame = BlzGetTriggerFrame()
        local widget = ArenaJournalWidget:get_event_widget(frame)

        if not(widget) then
            return
        end

        if frame == widget:get_normal_button() then
            Arena:start(Arena.DIFFICULTY_NORMAL,widget.id)
        elseif frame == widget:get_heroic_button() then
            Arena:start(Arena.DIFFICULTY_HEROIC,widget.id)
        else
            Arena:start(Arena.DIFFICULTY_MYTHIC,widget.id)
        end
    end

    function ajw:event_listener()
        local frame = BlzGetTriggerFrame()
        local evt = BlzGetTriggerFrameEvent()
        local widget = ArenaJournalWidget:get_event_widget(frame)

        if not(widget) then
            return
        end

        if evt == FRAMEEVENT_MOUSE_ENTER then
            widget:enter()
        elseif evt == FRAMEEVENT_MOUSE_LEAVE then
            widget:leave()
        else
            BlzFrameSetEnable(frame, false)
            BlzFrameSetEnable(frame, true)
            widget:click()
        end
    end

    OnInit(function()
        TriggerAddAction(trigger,ArenaJournalWidget.event_listener)
        TriggerAddAction(d_listener, ArenaJournalWidget.d_listener_func)
    end)
end