do
    BuffPanelButton = setmetatable({}, {})
    local bpb = getmetatable(BuffPanelButton)
    bpb.__index = bpb

    function bpb:create(b_data)
        local this = {}
        setmetatable(this, bpb)

        this.main = BlzCreateSimpleFrame('buff_panel_button', BuffPanel:get(), 0)
        this.time = BlzCreateSimpleFrame('buff_panel_time', this.main, 0)
        this.stack_text = BlzGetFrameByName('buff_panel_button_text', 0)
        this.texture = BlzGetFrameByName('buff_panel_button_texture', 0)
        this.time_text = BlzGetFrameByName('buff_panel_time_text', 0)
        this.buff_name = b_data.bn

        BlzFrameSetPoint(this.time, FRAMEPOINT_TOP, this.main, FRAMEPOINT_BOTTOM, 0, -0.006)

        return this
    end

    function bpb:get_name()
        return self.buff_name
    end

    function bpb:destroy()
        BlzDestroyFrame(self.main)
    end

    function bpb:reload(b_data)
        BlzFrameSetTexture(self.texture, 'war3mapImported\\' .. (b_data.is_d and 'debuff_' or 'buff_') .. b_data.bn .. '.dds', 0, true)
        BlzFrameSetTextColor(self.stack_text, b_data.tc or BlzConvertColor(255, 255, 255, 255))
        BlzFrameSetText(self.stack_text, b_data.sc > 1 and tostring(b_data.sc) or '')
        BlzFrameSetText(self.time_text, (b_data.rem_dur and b_data.rem_dur > 0) and StringUtils:format_seconds_minutes(b_data.rem_dur) or '')
    end

    function bpb:get()
        return self.main
    end
end