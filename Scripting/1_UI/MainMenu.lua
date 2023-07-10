do
    MainMenu = setmetatable({}, {})
    local mm = getmetatable(MainMenu)
    mm.__index = mm

    local trg = CreateTrigger()

    function mm:create()
        self.main = BlzCreateSimpleFrame('main_menu_button_container', UI:getConst('screen_frame'), 0)
        BlzFrameSetAbsPoint(self.main, FRAMEPOINT_TOP, 0.4, 0.6)

        self.w_button = BlzCreateSimpleFrame('main_menu_button', self.main, 0)
        self.a_button = BlzCreateSimpleFrame('main_menu_button', self.main, 1)

        BlzFrameSetText(BlzGetFrameByName('main_menu_button_text', 0), 'Warband')
        BlzFrameSetText(BlzGetFrameByName('main_menu_button_text', 1), 'Challenges')

        BlzFrameSetPoint(self.w_button, FRAMEPOINT_TOP, self.main, FRAMEPOINT_TOP, 0, 0)
        BlzFrameSetPoint(self.a_button, FRAMEPOINT_TOP, self.w_button, FRAMEPOINT_BOTTOM, 0, 0)

        BlzTriggerRegisterFrameEvent(trg, self.w_button, FRAMEEVENT_CONTROL_CLICK)
        BlzTriggerRegisterFrameEvent(trg, self.a_button, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trg, MainMenu.on_click)
    end

    function mm:on_click()
        if BlzGetTriggerFrame() == MainMenu.w_button then 
            WarbandJournal:show()
        elseif BlzGetTriggerFrame() == MainMenu.a_button then 
            print('Challenges')
        end
    end

    function mm:get()
        return self.main
    end

    function mm:show()
        if self.main and not(BlzFrameIsVisible(self.main)) then 
            BlzFrameSetVisible(self.main, true) 
        end
    end

    function mm:hide()
        if self.main and BlzFrameIsVisible(self.main) then BlzFrameSetVisible(self.main, false) end
    end

    function mm:rescale(s)
        if self.main then BlzFrameSetScale(self.main, s) end
    end
end