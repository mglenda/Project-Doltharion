do
    DamageMeterPanel = setmetatable({}, {})
    local dmp = getmetatable(DamageMeterPanel)
    dmp.__index = dmp

    local trg = CreateTrigger()

    function dmp:create()
        self.main = BlzCreateSimpleFrame("damage_meter_main_frame", UI:getConst('screen_frame'), 0)
        self.caption = BlzGetFrameByName("damage_meter_main_frame_text",0)
        BlzFrameSetText(self.caption, 'Damage Meter')
        self.display_button = BlzCreateSimpleFrame('damage_meter_button', self.main, 0)
        self.display_button_texture = BlzGetFrameByName('damage_meter_button_texture', 0)
        self.reset_button = BlzCreateSimpleFrame('damage_meter_button', self.main, 1)
        self.toggled = true

        BlzFrameSetTexture(BlzGetFrameByName('damage_meter_button_texture', 1), 'war3mapImported\\BTN_DmgMeter_Cancel.dds', 0, true)
        BlzFrameSetTexture(self.display_button_texture, 'war3mapImported\\BTN_DmgMeter_DOWN.dds', 0, true)

        BlzFrameSetPoint(self.display_button, FRAMEPOINT_BOTTOMRIGHT, self.main, FRAMEPOINT_BOTTOMLEFT, 0, 0)
        BlzFrameSetPoint(self.reset_button, FRAMEPOINT_BOTTOMLEFT, self.main, FRAMEPOINT_BOTTOMRIGHT, 0, 0)

        self.total_frame = BlzCreateSimpleFrame('damage_meter_ability_frame', self.main, 0)
        local total_dmg_frame = BlzCreateSimpleFrame('damage_meter_ability_frame_dmg', self.total_frame, 0)
        local total_dps_frame = BlzCreateSimpleFrame('damage_meter_ability_frame_dps', self.total_frame, 0)
        self.total_dmg_text = BlzGetFrameByName('damage_meter_ability_frame_dmg_text', 0)
        self.total_dps_text = BlzGetFrameByName('damage_meter_ability_frame_dps_text', 0)

        local t_frame = BlzCreateSimpleFrame('damage_meter_ability_frame_total', self.total_frame, 0)

        BlzFrameSetText(BlzGetFrameByName("damage_meter_ability_frame_total_text", 0), "[Total]")

        BlzFrameSetPoint(t_frame, FRAMEPOINT_LEFT, self.total_frame, FRAMEPOINT_LEFT, 0.01, 0)
        BlzFrameSetPoint(total_dmg_frame, FRAMEPOINT_LEFT, self.total_frame, FRAMEPOINT_LEFT, 0.05, 0)
        BlzFrameSetPoint(total_dps_frame, FRAMEPOINT_LEFT, self.total_frame, FRAMEPOINT_LEFT, 0.125, 0)
        BlzFrameSetPoint(self.total_frame, FRAMEPOINT_TOP, self.main, FRAMEPOINT_BOTTOM, 0, 0)

        BlzFrameSetAbsPoint(self.main, FRAMEPOINT_BOTTOMRIGHT, UI:getConst('max_x') - BlzFrameGetWidth(self.reset_button), 0 + BlzFrameGetHeight(self.total_frame))

        BlzTriggerRegisterFrameEvent(trg, self.display_button, FRAMEEVENT_CONTROL_CLICK)
        BlzTriggerRegisterFrameEvent(trg, self.reset_button, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trg, DamageMeterPanel.on_click)

        self.ability_frames = {}
    end

    function dmp:on_click()
        if BlzGetTriggerFrame() == DamageMeterPanel.display_button then 
            DamageMeterPanel.toggled = not DamageMeterPanel.toggled
            BlzFrameSetTexture(DamageMeterPanel.display_button_texture, DamageMeterPanel.toggled and 'war3mapImported\\BTN_DmgMeter_DOWN.dds' or 'war3mapImported\\BTN_DmgMeter_UP.dds', 0, true)
            DamageMeterPanel:update()
        elseif BlzGetTriggerFrame() == DamageMeterPanel.reset_button then 
            DamageMeter:reset()
        end
    end

    function dmp:set_total(dmg,dps)
        BlzFrameSetText(self.total_dmg_text,'DMG: ' .. math.floor(dmg))
        BlzFrameSetText(self.total_dps_text,'DPS: ' .. math.floor(dps))
    end

    function dmp:show()
        if self.main and not(BlzFrameIsVisible(self.main)) then 
            BlzFrameSetVisible(self.main, true) 
        end
    end

    function dmp:hide()
        if self.main and BlzFrameIsVisible(self.main) then BlzFrameSetVisible(self.main, false) end
    end

    function dmp:rescale(s)
        if self.main then BlzFrameSetScale(self.main, s) end
    end

    function dmp:update()
        data,total_dmg,total_dps = DamageMeter:get_sorted_data()
        self:set_total(total_dmg,total_dps)

        if self.toggled then
            for i,t in ipairs(data) do
                if not(self.ability_frames[i]) then 
                    self.ability_frames[i] = self:create_ability_frame(i)
                    if i == 1 then 
                        BlzFrameSetPoint(self.ability_frames[i].main, FRAMEPOINT_TOP, self.total_frame, FRAMEPOINT_BOTTOM, 0, 0)
                    else
                        BlzFrameSetPoint(self.ability_frames[i].main, FRAMEPOINT_TOP, self.ability_frames[i-1].main, FRAMEPOINT_BOTTOM, 0, 0)
                    end
                end
                self:update_ability_frame(i,t.id,t.dmg,t.dps)
            end
            BlzFrameSetAbsPoint(self.main, FRAMEPOINT_BOTTOMRIGHT, UI:getConst('max_x') - BlzFrameGetWidth(self.reset_button), 0 + BlzFrameGetHeight(self.total_frame) * (#data + 1))
        else
            BlzFrameSetAbsPoint(self.main, FRAMEPOINT_BOTTOMRIGHT, UI:getConst('max_x') - BlzFrameGetWidth(self.reset_button), 0 + BlzFrameGetHeight(self.total_frame))
        end
    end
    
    function dmp:create_ability_frame(id)
        local tbl = {}
        tbl.main = BlzCreateSimpleFrame("damage_meter_ability_frame", self.main, id)
        
        local icon = BlzCreateSimpleFrame("damage_meter_ability_frame_icon", tbl.main, id)
        BlzFrameSetPoint(icon, FRAMEPOINT_LEFT, tbl.main, FRAMEPOINT_LEFT, 0.02, 0)

        local order = BlzCreateSimpleFrame("damage_meter_ability_frame_order", tbl.main, id)
        BlzFrameSetPoint(order, FRAMEPOINT_LEFT, tbl.main, FRAMEPOINT_LEFT, 0, 0)
        
        local dmg = BlzCreateSimpleFrame("damage_meter_ability_frame_dmg", tbl.main, id)
        BlzFrameSetPoint(dmg, FRAMEPOINT_LEFT, tbl.main, FRAMEPOINT_LEFT, 0.05, 0)

        local dps = BlzCreateSimpleFrame("damage_meter_ability_frame_dps", tbl.main, id)
        BlzFrameSetPoint(dps, FRAMEPOINT_LEFT, tbl.main, FRAMEPOINT_LEFT, 0.125, 0)

        tbl.icon = BlzGetFrameByName('damage_meter_ability_frame_icon_texture', id)
        tbl.order = BlzGetFrameByName('damage_meter_ability_frame_order_text', id)
        tbl.dmg = BlzGetFrameByName('damage_meter_ability_frame_dmg_text', id)
        tbl.dps = BlzGetFrameByName('damage_meter_ability_frame_dps_text', id)

        BlzFrameSetText(tbl.order, tonumber(id))

        return tbl
    end

    function dmp:update_ability_frame(id, a_id, dmg, dps)
        local icon_path = a_id == FourCC('Aatk') and 'war3mapImported\\BTN' .. GetUnitName(Hero:get()):gsub(" ","") .. 'Autoattack.dds' or 'war3mapImported\\BTN' .. GetAbilityName(a_id):gsub(" ","") .. '.dds'
        BlzFrameSetTexture(self.ability_frames[id].icon, icon_path, 0, true)
        BlzFrameSetText(self.ability_frames[id].dmg, 'DMG: ' .. math.floor(dmg))
        BlzFrameSetText(self.ability_frames[id].dps, 'DPS: ' .. math.floor(dps))
    end
end