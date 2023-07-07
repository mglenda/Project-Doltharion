do
    WarbandList = setmetatable({}, {})
    local wl = getmetatable(WarbandList)
    wl.__index = wl
    

    local s_trg = CreateTrigger()
    --Width 0.18,
	--Height 0.26,
    --0.04
    --0.04

    function wl:create()
        self.main = BlzCreateSimpleFrame('warband_list_main', UI:getConst('screen_frame'), 0)
        BlzFrameSetPoint(self.main, FRAMEPOINT_TOPRIGHT, WarbandJournal:get(), FRAMEPOINT_TOPLEFT, 0, 0)
        local mvp = BlzCreateSimpleFrame('warband_list_v_panel', self.main, 0)
        local mvi = BlzCreateSimpleFrame('warband_list_v_panel_icon', mvp, 0)
        local mvt = BlzCreateSimpleFrame('warband_list_v_panel_text', mvp, 0)
        BlzFrameSetPoint(mvp, FRAMEPOINT_BOTTOMLEFT, self.main, FRAMEPOINT_TOPLEFT, 0, 0)
        BlzFrameSetPoint(mvt, FRAMEPOINT_CENTER, mvp, FRAMEPOINT_CENTER, 0, 0)
        BlzFrameSetPoint(mvi, FRAMEPOINT_BOTTOMRIGHT, mvt, FRAMEPOINT_BOTTOMLEFT, 0, 0)
        self.vt = BlzGetFrameByName('warband_list_v_panel_string', 0)
        
        self.slots = {}
        for l=1,5 do
            for i=1,3 do
                local f_id = l * 100 + i
                local b = BlzCreateSimpleFrame('warband_list_slot', self.main, f_id)
                BlzTriggerRegisterFrameEvent(s_trg, b, FRAMEEVENT_CONTROL_CLICK)
                local vp = BlzCreateSimpleFrame('warband_list_valor_panel', b, f_id)
                local vi = BlzCreateSimpleFrame('warband_list_valor_panel_icon', vp, f_id)
                local vt = BlzCreateSimpleFrame('warband_list_valor_panel_text', vp, f_id)
                BlzFrameSetPoint(vp, FRAMEPOINT_BOTTOMLEFT, b, FRAMEPOINT_BOTTOMLEFT, 0, 0)
                BlzFrameSetPoint(vi, FRAMEPOINT_BOTTOMLEFT, vp, FRAMEPOINT_BOTTOMLEFT, 0, 0)
                BlzFrameSetPoint(vt, FRAMEPOINT_BOTTOMRIGHT, vp, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
                table.insert(self.slots,{i=BlzGetFrameByName('warband_list_slot_icon', f_id),b=b,l=l,s=i,vt=BlzGetFrameByName('warband_list_valor_panel_text_string', f_id)})
                if l == 1 and i == 1 then 
                    BlzFrameSetPoint(b, FRAMEPOINT_TOPLEFT, self.main, FRAMEPOINT_TOPLEFT, 0.015, -0.01)
                else
                    if self.slots[#self.slots - 1].l < l then 
                        BlzFrameSetPoint(b, FRAMEPOINT_TOP, self.slots[#self.slots - 3].b, FRAMEPOINT_BOTTOM, 0, -0.01)
                    else
                        BlzFrameSetPoint(b, FRAMEPOINT_LEFT, self.slots[#self.slots - 1].b, FRAMEPOINT_RIGHT, 0.015, 0)
                    end
                end
            end
        end
        TriggerAddAction(s_trg, self.on_slot_click)
    end

    function wl:get_slot(b)
        for _,v in ipairs(self.slots) do
            if v.b == b then return v end
        end
        return nil
    end

    function wl:refresh_valor()
        local v = Valor:recalculate()
        return BlzFrameSetText(self.vt,StringUtils:round(Valor:get() - v,0) .. '/'.. StringUtils:round(Valor:get(),0))
    end

    function wl:on_slot_click()
        local t = WarbandList:get_slot(BlzGetTriggerFrame())
        if Utils:type(t) == 'table' and Valor:is_affordable(t.ut) then 
            WarbandJournal:add_unit(t.ut) 
        end
    end

    function wl:load_unit_data()
        local ud = Data:get_warband_list_data()
        for i,v in ipairs(self.slots) do
            if Utils:type(ud[i]) == 'table' then
                BlzFrameSetVisible(v.b, true)
                BlzFrameSetTexture(v.i, 'ReplaceableTextures\\CommandButtons\\BTN' .. UnitType:get_name(ud[i].ut):gsub(" ","") .. '.dds', 0, true)
                BlzFrameSetText(v.vt, StringUtils:round(UnitType:get_valor_cost(ud[i].ut),0))
                v.ut = ud[i].ut
            else
                BlzFrameSetVisible(v.b, false)
            end
        end
        self:refresh_valor()
    end

    function wl:rescale(s)
        if self.main then BlzFrameSetScale(self.main, s) end
    end

    function wl:hide()
        if self.main and BlzFrameIsVisible(self.main) then BlzFrameSetVisible(self.main, false) end
    end

    function wl:show()
        if self.main and not(BlzFrameIsVisible(self.main)) then 
            BlzFrameSetVisible(self.main, true) 
            self:load_unit_data()
        end
    end
    
end