do
    ArenaJournal = setmetatable({}, {})
    local aj = getmetatable(ArenaJournal)
    aj.__index = aj

    local book_trigger = CreateTrigger()

    function aj:create()
        self.book_button = BlzCreateSimpleFrame('arena_journal_button', UI:getConst('screen_frame'), 0)
        BlzFrameSetPoint(self.book_button, FRAMEPOINT_BOTTOMRIGHT, UI:get_h_panel(), FRAMEPOINT_BOTTOMLEFT, 0, 0)

        self.main = BlzCreateSimpleFrame('arena_journal_main_frame', UI:getConst('screen_frame'), 0)
        BlzFrameSetPoint(self.main, FRAMEPOINT_TOP, UI:getConst('screen_frame'), FRAMEPOINT_TOP, 0, -0.01)

        BlzTriggerRegisterFrameEvent(book_trigger, self.book_button, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(book_trigger, ArenaJournal.book_click_handler)

        self.widgets = {}
        
        if Utils:type(Arena:get_arenas()) == 'table' then
            for i,a in ipairs(Arena:get_arenas()) do
                local widget = ArenaJournalWidget:create(i,a)
                if i == 1 then 
                    BlzFrameSetPoint(widget:get(), FRAMEPOINT_TOPLEFT, self.main, FRAMEPOINT_TOPLEFT, 0.0565, -0.025)
                elseif (i-1) - math.floor((i-1)/3)*3 == 0 then 
                    BlzFrameSetPoint(widget:get(), FRAMEPOINT_TOP, self.widgets[i-3]:get(), FRAMEPOINT_BOTTOM, 0, 0)
                else
                    BlzFrameSetPoint(widget:get(), FRAMEPOINT_LEFT, self.widgets[i-1]:get(), FRAMEPOINT_RIGHT, 0, 0)
                end
                table.insert(self.widgets,widget)
            end
        end
    end

    function aj:get()
        return self.main
    end

    function aj:show()
        if ArenaJournal:get() and not(BlzFrameIsVisible(ArenaJournal:get())) then 
            BlzFrameSetVisible(ArenaJournal:get(), true)
            Controller:registerKeyboardEvent(ConvertOsKeyType(27),ArenaJournal.hide,'aj_hide')
            for _,w in ipairs(self.widgets) do
                w:show()
            end
        end
    end

    function aj:hide()
        if ArenaJournal:get() and BlzFrameIsVisible(ArenaJournal:get()) then 
            BlzFrameSetVisible(ArenaJournal:get(), false)
            Controller:destroy('aj_hide')
            for _,w in ipairs(self.widgets) do
                w:hide()
            end
        end
    end

    function aj:rescale(s)
        BlzFrameSetScale(self.book_button, s)
    end

    function aj:hide_book_button()
        BlzFrameSetVisible(self.book_button, false)
    end

    function aj:show_book_button()
        BlzFrameSetVisible(self.book_button, true)
    end

    function aj:book_click_handler()
        if not(BlzFrameIsVisible(ArenaJournal:get())) then
            ArenaJournal:show()
        else    
            ArenaJournal:hide()
        end
    end
end