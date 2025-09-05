do
    WarbandJournal = setmetatable({}, {})
    local wj = getmetatable(WarbandJournal)
    wj.__index = wj

    local s_trg = CreateTrigger()
    local ic,si = nil,nil

    function wj:create()
        self.main = BlzCreateSimpleFrame('warband_journal_main', UI:getConst('screen_frame'), 0)
        BlzFrameSetAbsPoint(self.main, FRAMEPOINT_BOTTOM, 0.4, 0.2)

        self.slots = {}
        local pl = 1
        for l=1,5 do
            for i=1,4 do
                local f_id = l * 100 + i
                local b = BlzCreateSimpleFrame('warband_journal_slot', self.main, f_id)
                BlzTriggerRegisterFrameEvent(s_trg, b, FRAMEEVENT_CONTROL_CLICK)
                table.insert(self.slots,{i=BlzGetFrameByName('warband_journal_slot_icon', f_id),b=b})
                if l == 1 and i == 1 then 
                    BlzFrameSetPoint(b, FRAMEPOINT_TOPLEFT, self.main, FRAMEPOINT_TOPLEFT, 0.012, -0.01)
                else
                    if pl < l then 
                        BlzFrameSetPoint(b, FRAMEPOINT_TOP, self.slots[#self.slots - 4].b, FRAMEPOINT_BOTTOM, 0, -0.01)
                    else
                        BlzFrameSetPoint(b, FRAMEPOINT_LEFT, self.slots[#self.slots - 1].b, FRAMEPOINT_RIGHT, 0.012, 0)
                    end
                end
            end
            pl = l
        end
        TriggerAddAction(s_trg, self.on_slot_click)
    end

    function wj:get()
        return self.main
    end

    function wj:get_slot(b)
        for i,v in ipairs(self.slots) do
            if v.b == b then return v.i,i end
        end
        return nil,nil
    end

    function wj:add_unit(ut)
        if ic and si then 
            BlzFrameSetTexture(ic, 'ReplaceableTextures\\CommandButtons\\BTN' .. UnitType:get_name(ut):gsub(" ","") .. '.dds', 0, true)
            self.slots[si].ut = ut
            Warband:set_slot(si,ut)
            WarbandList:refresh_valor()
        end
    end

    function wj:remove_unit()
        if ic and si then
            BlzFrameSetTexture(ic, 'war3mapImported\\UnitSlotPushed.dds', 0, true)
            WarbandJournal:get_slots()[si].ut = nil
            Warband:set_slot(si,0)
            WarbandList:refresh_valor()
        end
    end

    function wj:load_warband()
        for i,ut in ipairs(Warband:get()) do
            if ut ~= 0 then 
                WarbandJournal:get_slots()[i].ut = ut
                BlzFrameSetTexture(WarbandJournal:get_slots()[i].i, 'ReplaceableTextures\\CommandButtons\\BTN' .. UnitType:get_name(ut):gsub(" ","") .. '.dds', 0, true)
            else
                WarbandJournal:get_slots()[i].ut = nil
                BlzFrameSetTexture(WarbandJournal:get_slots()[i].i, 'war3mapImported\\UnitSlot.dds', 0, true)
            end
        end
    end

    function wj:get_slots()
        return self.slots
    end

    function wj:on_slot_click()
        WarbandJournal:unselect_slot()
        ic,si = WarbandJournal:get_slot(BlzGetTriggerFrame())
        if ic and si and not(WarbandJournal:get_slots()[si].ut) then 
            BlzFrameSetTexture(ic, 'war3mapImported\\UnitSlotPushed.dds', 0, true)
        end
        WarbandList:show()
        Controller:registerKeyboardEvent(ConvertOsKeyType(9),WarbandJournal.remove_unit,'wl_rem_unit_tab')
    end
    
    function wj:unselect_slot()
        if (not(si) or not(self.slots[si].ut)) and ic then BlzFrameSetTexture(ic, 'war3mapImported\\UnitSlot.dds', 0, true) end
        ic,si = nil,nil
        Controller:destroy('wl_rem_unit_tab')
    end

    function wj:reset_all_slots()
        for i,v in ipairs(WarbandJournal:get_slots()) do
            Warband:set_slot(i,0)
            v.ut = nil
            if i == si then 
                BlzFrameSetTexture(v.i, 'war3mapImported\\UnitSlotPushed.dds', 0, true)
            else
                BlzFrameSetTexture(v.i, 'war3mapImported\\UnitSlot.dds', 0, true)
            end
        end
        WarbandList:refresh_valor()
    end

    function wj:rescale(s)
        if self.main then BlzFrameSetScale(self.main, s) end
    end

    function wj:hide()
        if WarbandJournal:get() and BlzFrameIsVisible(WarbandJournal:get()) then
            BlzFrameSetVisible(WarbandJournal:get(), false)
            WarbandJournal:unselect_slot()
            WarbandList:hide()
            Controller:destroy('wl_rem_unit_tab')
            Controller:destroy('wl_hide')
            Controller:destroy('wl_resetall_tab')
        end
    end

    function wj:show()
        if WarbandJournal:get() and not(BlzFrameIsVisible(WarbandJournal:get())) then 
            BlzFrameSetVisible(WarbandJournal:get(), true) 
            WarbandJournal:load_warband()
            Controller:registerKeyboardEvent(ConvertOsKeyType(27),WarbandJournal.hide,'wl_hide')
            Controller:registerKeyboardEvent(ConvertOsKeyType(9),WarbandJournal.reset_all_slots,'wl_resetall_tab',Clique:shift())
        end
    end
end