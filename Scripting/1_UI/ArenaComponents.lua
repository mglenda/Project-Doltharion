do
    ArenaComponents = setmetatable({}, {})
    local ac = getmetatable(ArenaComponents)
    ac.__index = ac

    local refresh_trg = CreateTrigger()

    function ac:create_boss_hp_bar()
        self.boss_hp_main = BlzCreateSimpleFrame('arena_hp_frame', UI:getConst('screen_frame'), 0)
        self.boss_hp_bar = BlzCreateSimpleFrame('arena_hp_bar', self.boss_hp_main, 0)
        self.boss_absorbs_bar = BlzCreateSimpleFrame('arena_absorbs_bar', self.boss_hp_bar, 0)
        local text_frame = BlzCreateSimpleFrame('arena_hp_bar_value', self.boss_absorbs_bar, 0) 
        self.boss_hp_text = BlzGetFrameByName('arena_hp_bar_value_text', 0)

        local percent_frame = BlzCreateSimpleFrame('arena_hp_bar_percent', self.boss_absorbs_bar, 0) 
        self.boss_hp_percent = BlzGetFrameByName('arena_hp_bar_percent_text', 0)

        
        BlzFrameSetPoint(self.boss_hp_bar, FRAMEPOINT_CENTER, self.boss_hp_main, FRAMEPOINT_CENTER, 0, 0)
        BlzFrameSetPoint(self.boss_absorbs_bar, FRAMEPOINT_CENTER, self.boss_hp_bar, FRAMEPOINT_CENTER, 0, 0)
        BlzFrameSetPoint(text_frame, FRAMEPOINT_CENTER, self.boss_absorbs_bar, FRAMEPOINT_CENTER, 0, 0)
        BlzFrameSetPoint(percent_frame, FRAMEPOINT_CENTER, self.boss_absorbs_bar, FRAMEPOINT_CENTER, 0, 0)

        BlzFrameSetAbsPoint(self.boss_hp_main, FRAMEPOINT_TOP, UI:getConst('center_x'), UI:getConst('max_y') - 0.005)
    end

    function ac:refresh()
        local boss = ArenaUtils:get_boss()
        if boss then
            local mana = math.floor(GetUnitStateSwap(UNIT_STATE_MANA, boss))
            local absorbs = mana <= 0 and 0 or math.floor((mana / GetUnitStateSwap(UNIT_STATE_LIFE, boss))*100)
            BlzFrameSetValue(self.boss_absorbs_bar, absorbs > 100 and 100 or absorbs)
            BlzFrameSetValue(self.boss_hp_bar, GetUnitLifePercent(boss))

            local cur_hp_text = '|c0017EF10' .. tostring(math.floor(GetUnitStateSwap(UNIT_STATE_LIFE, boss))) .. '|r'
            local max_hp_text = '|c0017EF10' .. tostring(math.floor(GetUnitStateSwap(UNIT_STATE_MAX_LIFE, boss))) .. '|r'
            local absorbs_text = mana <= 0 and '' or ' + |c0003E7FF' .. tostring(mana).. '|r'
            local absorbs_percent_text = absorbs <= 0 and '' or ' + |c0003E7FF' .. tostring(absorbs).. '%%|r'

            BlzFrameSetText(self.boss_hp_text, cur_hp_text .. absorbs_text ..'/' .. max_hp_text)
            BlzFrameSetText(self.boss_hp_percent, '|c00FFD700' .. StringUtils:round(GetUnitLifePercent(boss),1) .. '%%|r' .. absorbs_percent_text)
        end

        local arena = Arena:get_active_arena()
        if arena and Utils:type(arena.get_energy) == 'function' then
            local energy_data = arena:get_energy()
            if Utils:type(energy_data) == 'table' then
                BlzFrameSetValue(self.boss_energy_bar, energy_data.bar_value)
                BlzFrameSetText(self.boss_energy_text, energy_data.bar_text)
            end
        end
    end

    function ac:create_energy_bar()
        local arena = Arena:get_active_arena()
        local energy_preset = nil
        if arena and Utils:type(arena.get_energy_preset) == 'function' then
            energy_preset = arena:get_energy_preset()
        end

        if Utils:type(energy_preset) == 'table' then
            self.boss_energy_main = BlzCreateSimpleFrame('arena_energy_frame', UI:getConst('screen_frame'), 0)
            self.boss_energy_bar = BlzCreateSimpleFrame('arena_energy_bar', self.boss_energy_main, 0)
            local text_frame = BlzCreateSimpleFrame('arena_energy_bar_value', self.boss_energy_bar, 0) 
            self.boss_energy_text = BlzGetFrameByName('arena_energy_bar_value_text', 0)

            BlzFrameSetPoint(self.boss_energy_bar, FRAMEPOINT_CENTER, self.boss_energy_main, FRAMEPOINT_CENTER, 0, 0)
            BlzFrameSetPoint(text_frame, FRAMEPOINT_CENTER, self.boss_energy_bar, FRAMEPOINT_CENTER, 0, 0)

            if self.boss_hp_main then 
                BlzFrameSetPoint(self.boss_energy_main, FRAMEPOINT_TOP, self.boss_hp_main, FRAMEPOINT_BOTTOM, 0, 0)
            else
                BlzFrameSetAbsPoint(self.boss_energy_main, FRAMEPOINT_TOP, UI:getConst('center_x'), UI:getConst('max_y') - 0.005)
            end

            BlzFrameSetTexture(self.boss_energy_bar, energy_preset.bar_texture, 0, true)
            BlzFrameSetTextColor(self.boss_energy_text, energy_preset.font_color)
        end
    end

    function ac:start()
        self:create_boss_hp_bar()
        self:create_energy_bar()
        EnableTrigger(refresh_trg)
    end

    function ac:flush()
        DisableTrigger(refresh_trg)
        BlzDestroyFrame(self.boss_hp_main)
        if self.boss_energy_main then 
            BlzDestroyFrame(self.boss_energy_main)
            self.boss_energy_main = nil
        end 
    end

    OnInit.map(function()
        TriggerRegisterTimerEventPeriodic(refresh_trg, 0.05)
        TriggerAddAction(refresh_trg,function()
            ArenaComponents:refresh()
        end)
        DisableTrigger(refresh_trg)
    end)
end