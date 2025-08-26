do
    BuffPanel = setmetatable({}, {})
    local bp = getmetatable(BuffPanel)
    bp.__index = bp

    function bp:create()
        self.main = BlzCreateSimpleFrame('buff_panel_button_container',UI:getConst('screen_frame'), 0)
        self.trigger = CreateTrigger()
        self.container = {}
    end

    function bp:refresh(b_table)
        if #b_table < #self.container then
            for i=#self.container,#b_table,-1 do
                self.container[i]:destroy()
                table.remove(self.container,i)
            end
        end

        for i,b_data in ipairs(b_table) do
            local button = self.container[i]
            if not(button) then
                button = BuffPanelButton:create(b_data)
                if i == 1 then
                    BlzFrameSetAbsPoint(button:get(), FRAMEPOINT_BOTTOMLEFT, -0.125, 0.56) 
                else
                    BlzFrameSetPoint(button:get(), FRAMEPOINT_LEFT, self.container[i-1]:get(), FRAMEPOINT_RIGHT, 0.008, 0)
                end
                table.insert(self.container,button)
            end
            button:reload(b_data)
        end
    end

    function bp:get()
        return self.main
    end

    function bp:show()
        if BuffPanel:get() and not(BlzFrameIsVisible(BuffPanel:get())) then 
            BlzFrameSetVisible(BuffPanel:get(), true)
        end
    end

    function bp:hide()
        if BuffPanel:get() and BlzFrameIsVisible(BuffPanel:get()) then 
            BlzFrameSetVisible(BuffPanel:get(), false)
        end
    end

    function bp:rescale(s)
        BlzFrameSetScale(self.main, s)
    end
end