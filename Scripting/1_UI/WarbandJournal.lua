do
    WarbandJournal = setmetatable({}, {})
    local wj = getmetatable(WarbandJournal)
    wj.__index = wj

    local s_trg = CreateTrigger()
    local l,s,i = nil,nil,nil

    function wj:create()
        self.main = BlzCreateSimpleFrame('warband_journal_main', UI:getConst('screen_frame'), 0)
        BlzFrameSetAbsPoint(self.main, FRAMEPOINT_BOTTOM, 0.4, 0.2)

        self.slots = {}
        for l=1,5 do
            for i=1,4 do
                local f_id = l * 100 + i
                local b = BlzCreateSimpleFrame('warband_journal_slot', self.main, f_id)
                BlzTriggerRegisterFrameEvent(s_trg, b, FRAMEEVENT_CONTROL_CLICK)
                table.insert(self.slots,{i=BlzGetFrameByName('warband_journal_slot_icon', f_id),b=b,l=l,s=i})
                if l == 1 and i == 1 then 
                    BlzFrameSetPoint(b, FRAMEPOINT_TOPLEFT, self.main, FRAMEPOINT_TOPLEFT, 0.012, -0.01)
                else
                    if self.slots[#self.slots - 1].l < l then 
                        BlzFrameSetPoint(b, FRAMEPOINT_TOP, self.slots[#self.slots - 4].b, FRAMEPOINT_BOTTOM, 0, -0.01)
                    else
                        BlzFrameSetPoint(b, FRAMEPOINT_LEFT, self.slots[#self.slots - 1].b, FRAMEPOINT_RIGHT, 0.012, 0)
                    end
                end
            end
        end
        TriggerAddAction(s_trg, self.on_slot_click)
    end

    function wj:get()
        return self.main
    end

    function wj:get_slot(b)
        for _,v in ipairs(self.slots) do
            if v.b == b then return v.l,v.s,v.i end
        end
        return nil,nil,nil
    end

    function wj:on_slot_click()
        if i then 
            BlzFrameSetTexture(i, 'war3mapImported\\UnitSlot.dds', 0, true)
        end
        l,s,i = WarbandJournal:get_slot(BlzGetTriggerFrame())
        if l and s and i then 
            BlzFrameSetTexture(i, 'war3mapImported\\UnitSlotPushed.dds', 0, true)
        end
        WarbandList:show()
    end

    function wj:unselect_slot()
        if i then BlzFrameSetTexture(i, 'war3mapImported\\UnitSlot.dds', 0, true) end
        l,s,i = nil,nil,nil
    end

    function wj:rescale(s)
        if self.main then BlzFrameSetScale(self.main, s) end
    end

    function wj:hide()
        if self.main then BlzFrameSetVisible(self.main, false) end
        self:unselect_slot()
        WarbandList:hide()
    end

    function wj:show()
        if self.main then BlzFrameSetVisible(self.main, true) end
    end
end