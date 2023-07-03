do
    DBM = setmetatable({}, {})
    local dbm = getmetatable(DBM)
    dbm.__index = dbm

    local seed = 0
    local tbl = {}
    local trg = CreateTrigger()

    function dbm:reposition()
        if #tbl > 0 then 
            table.sort(tbl, function (k1, k2) return k1.t > k2.t end)
            BlzFrameClearAllPoints(tbl[1].main)
            BlzFrameSetAbsPoint(tbl[1].main, FRAMEPOINT_TOP, 0.934 - (BlzFrameGetWidth(tbl[1].main)/2), 0.6)
            for i=2,#tbl do
                BlzFrameSetPoint(tbl[i].main, FRAMEPOINT_TOP, tbl[i-1].main, FRAMEPOINT_BOTTOM, 0, 0)
            end
        end
    end

    function dbm:refresh()
        if #tbl > 0 then
            for i,d in ipairs(tbl) do
                if not(d.paused) then
                    local v = BlzFrameGetValue(d.bar)
                    if v < 100 then
                        d.t = d.t > 0 and d.t - 0.01 or 0
                        BlzFrameSetText(d.timeF, StringUtils:format_seconds(d.t))
                        BlzFrameSetValue(d.bar, v + d.p)
                    else
                        d:destroy()
                        if Utils:type(d.f) == 'function' then
                            d.f()
                        end
                    end
                end
            end
        else
            DisableTrigger(trg)
        end
    end

    function dbm:pause()
        self.paused = true
    end

    function dbm:resume()
        self.paused = nil
    end

    function dbm:destroy()
        self:pause()
        FrameFading:fadeout(self.main,1.0,function()
            DBM:flush(FrameFading:getFrameByTrigger(GetTriggeringTrigger()))
        end)
    end

    function dbm:flush(main)
        for i = #tbl,1,-1 do
            if tbl[i].main == main then table.remove(tbl,i) end
        end
        BlzDestroyFrame(main)
        self:reposition()
    end

    function dbm:destroy_all()
        for i = #tbl,1,-1 do
            tbl[i]:destroy()
        end
    end

    function dbm:pause_all()
        for _,d in ipairs(tbl) do
            d:pause()
        end
    end

    function dbm:resume_all()
        for _,d in ipairs(tbl) do
            d:resume()
        end
    end

    --t = duration
    --t_bar = BarType which will define font color and bar texture
    --f = function which will be executed on finish
    --n = name of timer, will be displayed on bar for user
    --t_icon = icon texture
    function dbm:create(data)
        local this = {}
        setmetatable(this, dbm)
        if Utils:type(data) == 'table' then Utils:table_merge(this,data) end
        if not(this.t) then 
            print('DBM [t] param was not passed') 
            return nil 
        end

        this.p = Utils:round(1/this.t,4)
        this.main = BlzCreateSimpleFrame('DBM_TimerFrame', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), seed)
        local icon = BlzCreateSimpleFrame('DBM_TimerFrameIcon', this.main, seed)
        this.icon = BlzGetFrameByName('DBM_TimerFrameIcon_Texture', seed)
        this.bar = BlzCreateSimpleFrame('DBM_TimerBar', this.main, seed)
        local name = BlzCreateSimpleFrame('DBM_TimerBar_Name', this.bar, seed)
        local time = BlzCreateSimpleFrame('DBM_TimerBar_Time', this.bar, seed)
        this.nameF = BlzGetFrameByName('DBM_TimerBar_Name_Text', seed)
        this.timeF = BlzGetFrameByName('DBM_TimerBar_Time_Text', seed)

        BlzFrameSetTexture(this.bar, Utils:type(this.t_bar) == 'table' and this.t_bar.t or BarType:green().t, 0, true)
        BlzFrameSetTexture(this.icon, tostring(this.t_icon), 0, true)
        BlzFrameSetText(this.timeF, StringUtils:format_seconds(this.t))
        BlzFrameSetText(this.nameF, tostring(this.n))
        BlzFrameSetTextColor(this.timeF, Utils:type(this.t_bar) == 'table' and this.t_bar.f or BarType:green().f)
        BlzFrameSetTextColor(this.nameF, Utils:type(this.t_bar) == 'table' and this.t_bar.f or BarType:green().f)
        BlzFrameSetValue(this.bar, 0)

        BlzFrameSetPoint(icon, FRAMEPOINT_LEFT, this.main, FRAMEPOINT_LEFT, 0, 0)
        BlzFrameSetPoint(this.bar, FRAMEPOINT_LEFT, icon, FRAMEPOINT_RIGHT, 0, 0)
        BlzFrameSetPoint(name, FRAMEPOINT_CENTER, this.bar, FRAMEPOINT_CENTER, 0, 0)
        BlzFrameSetPoint(time, FRAMEPOINT_CENTER, this.bar, FRAMEPOINT_CENTER, 0, 0)

        BlzFrameSetScale(this.main,UI:getConst('scale'))

        table.insert(tbl,this)

        seed = seed > 1000 and 0 or seed + 1
        self:reposition()
        EnableTrigger(trg)
        return this
    end

    OnInit.final(function()
        TriggerAddAction(trg, DBM.refresh)
        TriggerRegisterTimerEventPeriodic(trg, 0.01)
    end)
end