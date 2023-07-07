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

        self.slots = {}
        for l=1,5 do
            for i=1,3 do
                local f_id = l * 100 + i
                local b = BlzCreateSimpleFrame('warband_list_slot', self.main, f_id)
                BlzTriggerRegisterFrameEvent(s_trg, b, FRAMEEVENT_CONTROL_CLICK)
                table.insert(self.slots,{i=BlzGetFrameByName('warband_list_slot_icon', f_id),b=b,l=l,s=i})
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
    end

    function wl:load_unit_data()
        for _,v in ipairs(Data:get_warband_list_data()) do
            print(UnitType:get_unit_name(v.ut))
        end
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