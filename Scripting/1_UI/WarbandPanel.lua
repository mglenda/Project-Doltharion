do
    WarbandPanel = setmetatable({}, {})
    local wp = getmetatable(WarbandPanel)
    wp.__index = wp

    local trg = CreateTrigger()
    local widgets = {}

    function wp:refresh()
        for i,u in ipairs(Warband:get()) do
            if Units:exists(u) and IsUnitAliveBJ(u) and not(Utils:get_key_by_value(widgets,'u',u)) then WarbandPanel:create_widget(u) end
        end

        BlzFrameSetAbsPoint(widgets[#widgets].main, FRAMEPOINT_TOPLEFT, -0.1325, 0.595)
        for i = #widgets,1,-1 do
            if i ~= #widgets then 
                if Utils:mod(i,2) == Utils:mod(#widgets,2) then 
                    BlzFrameSetPoint(widgets[i].main, FRAMEPOINT_TOPLEFT, widgets[i+2].main, FRAMEPOINT_BOTTOMLEFT, 0, 0)
                else
                    BlzFrameSetPoint(widgets[i].main, FRAMEPOINT_TOPLEFT, widgets[i+1].main, FRAMEPOINT_TOPRIGHT, 0.002, 0)
                end
            end
            if not(Units:exists(widgets[i].u)) or not(IsUnitAliveBJ(widgets[i].u)) then 
                BlzDestroyFrame(widgets[i].main)
                table.remove(widgets,i)
            else
                BlzFrameSetValue(widgets[i].bar, GetUnitLifePercent(widgets[i].u))
                BlzFrameSetText(widgets[i].text, StringUtils:round(GetUnitLifePercent(widgets[i].u),1) .. '%%')
                local bt = Buffs:get_ui_tbl(widgets[i].u,true)
                for j=1,3 do
                    if bt[j] then
                        if not(BlzFrameIsVisible(widgets[i].buffs[j].m)) then BlzFrameSetVisible(widgets[i].buffs[j].m, true) end
                        BlzFrameSetTexture(widgets[i].buffs[j].i, 'war3mapImported\\' .. (bt[j].is_d and 'debuff_' or 'buff_') .. bt[j].bn .. '.dds', 0, true)
                        BlzFrameSetText(widgets[i].buffs[j].t,tostring(bt[j].sc > 1 and bt[j].sc or ''))
                        BlzFrameSetTextColor(widgets[i].buffs[j].t, bt[j].tc or BlzConvertColor(255, 255, 255, 255))
                    else
                        BlzFrameSetVisible(widgets[i].buffs[j].m, false)
                    end 
                end
            end
        end
    end

    function wp:clear()
        DestroyTrigger(self.b_trg)
        self.b_trg = nil
    end

    function wp:bind_to_trigger(w)
        if not(self.b_trg) then 
            self.b_trg = CreateTrigger() 
            TriggerAddAction(self.b_trg, self.on_click)
        end
        BlzTriggerRegisterFrameEvent(self.b_trg, w.listener, FRAMEEVENT_CONTROL_CLICK)
    end

    function wp:on_click()
        local w_e = Utils:get_key_by_value(widgets,'listener',BlzGetTriggerFrame())
        if widgets[w_e].u then 
            Clique:on_click(widgets[w_e].u)
            Target:set(widgets[w_e].u) 
        end
    end

    function wp:create_widget(u)
        local f_id = GetHandleIdBJ(u)
        local this = {}
        this.main = BlzCreateSimpleFrame('warband_panel_frame', UI:getConst('screen_frame'), f_id)
        this.u = u

        local bar = BlzCreateSimpleFrame('warband_panel_hpbar_frame', this.main, f_id)
        this.bar = BlzCreateSimpleFrame('warband_panel_hpbar', bar, f_id)
        icon = BlzCreateSimpleFrame('warband_panel_icon', this.main, f_id)
        this.icon = BlzGetFrameByName('warband_panel_icon_texture', f_id)
        local text = BlzCreateSimpleFrame('warband_panel_hpbar_text', bar, f_id)
        this.text = BlzGetFrameByName('warband_panel_hpbar_text_string', f_id)
        this.listener = BlzCreateSimpleFrame('warband_panel_listener', this.bar, f_id)

        BlzFrameSetPoint(icon, FRAMEPOINT_TOPLEFT, this.main, FRAMEPOINT_TOPLEFT, 0, 0)
        BlzFrameSetPoint(bar, FRAMEPOINT_TOPLEFT, icon, FRAMEPOINT_TOPRIGHT, 0, 0)
        BlzFrameSetPoint(this.bar, FRAMEPOINT_CENTER, bar, FRAMEPOINT_CENTER, 0, 0)
        BlzFrameSetPoint(text, FRAMEPOINT_CENTER, bar, FRAMEPOINT_CENTER, 0, 0)
        BlzFrameSetPoint(this.listener, FRAMEPOINT_CENTER, this.main, FRAMEPOINT_CENTER, 0, 0)

        BlzFrameSetTexture(this.icon, 'ReplaceableTextures\\CommandButtons\\BTN' .. GetUnitName(this.u):gsub(" ","") .. '.dds', 0, true)
        BlzFrameSetValue(this.bar, GetUnitLifePercent(this.u))
        BlzFrameSetText(this.text, StringUtils:round(GetUnitLifePercent(this.u),1) .. '%%')

        this.buffs = {}
        for i=1,3 do
            local bf = BlzCreateSimpleFrame('warband_panel_buff', this.bar, f_id-(1000*i))
            table.insert(this.buffs,{m=bf,i=BlzGetFrameByName('warband_panel_buff_icon', f_id-(1000*i)),t=BlzGetFrameByName('warband_panel_buff_text', f_id-(1000*i))})
            if i == 1 then
                BlzFrameSetPoint(bf, FRAMEPOINT_BOTTOMRIGHT, this.bar, FRAMEPOINT_BOTTOMRIGHT, -0.001, 0.001)
            else
                BlzFrameSetPoint(bf, FRAMEPOINT_BOTTOMRIGHT, this.buffs[i-1].m, FRAMEPOINT_BOTTOMLEFT, -0.001, 0)
            end
        end

        BlzFrameSetScale(this.main,UI:getConst('scale'))

        self:bind_to_trigger(this)

        table.insert(widgets,this)
    end

    OnInit.final(function()
        TriggerRegisterTimerEventPeriodic(trg, 0.1)
        TriggerAddAction(trg, WarbandPanel.refresh)
    end)
end