do
    ArenaJournal = setmetatable({}, {})
    local aj = getmetatable(ArenaJournal)
    aj.__index = aj

    local trg = CreateTrigger()

    function aj:create()
        self.main = BlzCreateSimpleFrame('arena_journal_container', UI:getConst('screen_frame'), 0)
        BlzFrameSetAbsPoint(self.main, FRAMEPOINT_TOPLEFT, 0.1, 0.5)

        self.widgets = {}
        for i,a in ipairs(Arena:get_arenas()) do
            local t = {}
            t.main = BlzCreateSimpleFrame('arena_journal_widget', self.main, i)
            local txt = BlzCreateSimpleFrame('arena_journal_caption', t.main, i)
            t.txt = BlzGetFrameByName('arena_journal_caption_text', i)
            t.btn = BlzCreateSimpleFrame('arena_journal_button', t.main, i)
            t.btn_img = BlzGetFrameByName('arena_journal_button_texture', i)

            BlzFrameSetPoint(txt, FRAMEPOINT_TOPLEFT, t.main, FRAMEPOINT_TOPLEFT, 0, 0)
            BlzFrameSetPoint(t.btn, FRAMEPOINT_BOTTOMLEFT, t.main, FRAMEPOINT_BOTTOMLEFT, 0, 0)
            BlzFrameSetText(t.txt, a:get_name())
            BlzFrameSetTexture(t.btn_img, a:get_img(), 0, true)

            if i == 1 then 
                BlzFrameSetPoint(t.main, FRAMEPOINT_TOPLEFT, self.main, FRAMEPOINT_TOPLEFT, 0, 0)
            else
                BlzFrameSetPoint(t.main, FRAMEPOINT_TOPLEFT, self.widgets[i-1].main, FRAMEPOINT_TOPRIGHT, 0, 0)
            end
            BlzTriggerRegisterFrameEvent(trg, t.btn, FRAMEEVENT_CONTROL_CLICK)
            table.insert(self.widgets,t)
        end
        TriggerAddAction(trg, self.on_click)
    end

    function aj:on_click()
        local w = ArenaJournal:get_widgets()
        if w and #w > 0 then 
            for i,v in ipairs(w) do
                if v.btn == BlzGetTriggerFrame() then 
                    Arena:start(i)
                    break
                end
            end
        end
    end

    function aj:get_widgets()
        return self.widgets
    end

    function aj:get()
        return self.main
    end

    function aj:show()
        if ArenaJournal:get() and not(BlzFrameIsVisible(ArenaJournal:get())) then 
            BlzFrameSetVisible(ArenaJournal:get(), true) 
            Controller:registerKeyboardEvent(ConvertOsKeyType(27),ArenaJournal.hide,'aj_hide')
        end
    end

    function aj:hide()
        if ArenaJournal:get() and BlzFrameIsVisible(ArenaJournal:get()) then 
            BlzFrameSetVisible(ArenaJournal:get(), false) 
            Controller:destroy('aj_hide')
        end
    end

    function aj:rescale(s)
        if ArenaJournal:get() then BlzFrameSetScale(ArenaJournal:get(), s) end
    end
end