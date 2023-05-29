do
    CastingBar = setmetatable({}, {})
    local cb = getmetatable(CastingBar)
    cb.__index = cb

    local font_colors = {
        ['war3mapImported\\DBM_BarFill_Blue.dds'] = BlzConvertColor(255, 255, 255, 255)
        ,['war3mapImported\\DBM_BarFill_Brown.dds'] = BlzConvertColor(255, 255, 255, 255)
        ,['war3mapImported\\DBM_BarFill_Gray.dds'] = BlzConvertColor(255, 21, 32, 212)
        ,['war3mapImported\\DBM_BarFill_Green.dds'] = BlzConvertColor(255, 255, 255, 255)
        ,['war3mapImported\\DBM_BarFill_Pink.dds'] = BlzConvertColor(255, 255, 255, 255)
        ,['war3mapImported\\DBM_BarFill_Red.dds'] = BlzConvertColor(255, 255, 255, 255)
        ,['war3mapImported\\DBM_BarFill_Yellow.dds'] = BlzConvertColor(255, 21, 162, 32)
        ,['war3mapImported\\DBM_BarFill_Orange.dds'] = BlzConvertColor(255, 255, 255, 255)
        ,['war3mapImported\\DBM_BarFill_DarkGreen.dds'] = BlzConvertColor(255, 255, 255, 255)
        ,['war3mapImported\\DBM_BarFill_LightBlue.dds'] = BlzConvertColor(255, 110, 84, 4)
        ,['war3mapImported\\DBM_BarFill_Gold.dds'] = BlzConvertColor(255, 100, 100, 100)
        ,['war3mapImported\\DBM_BarFill_Shadow.dds'] = BlzConvertColor(255, 255, 255, 255)
    }

    function cb:create()
        self.main = BlzCreateSimpleFrame("CastingBar_Texture_Frame", UI:getConst('screen_frame'), 0)
        self.timer = CreateTrigger()

        local icon = BlzCreateSimpleFrame("CastingBar_AbilityIcon_Frame", self.main, 0)
        local bar = BlzCreateSimpleFrame("CastingBar_Bar", self.main, 0)
        local text = BlzCreateSimpleFrame("CastingBar_BarText_Frame", bar, 0)
        local number = BlzCreateSimpleFrame("CastingBar_Number_Frame", bar, 0)
        
        BlzFrameSetPoint(icon, FRAMEPOINT_LEFT, self.main, FRAMEPOINT_LEFT, 0, 0)
        BlzFrameSetPoint(bar, FRAMEPOINT_LEFT, icon, FRAMEPOINT_RIGHT, 0, 0)
        BlzFrameSetPoint(text, FRAMEPOINT_LEFT, bar, FRAMEPOINT_LEFT, 0, 0)
        BlzFrameSetPoint(number, FRAMEPOINT_RIGHT, bar, FRAMEPOINT_RIGHT, 0, 0)

        self.icon = BlzGetFrameByName('CastingBar_AbilityIcon_Texture', 0)
        self.text = BlzGetFrameByName('CastingBar_BarText_Text', 0)
        self.number = BlzGetFrameByName('CastingBar_Number_Text', 0)
        self.bar = bar

        local x,y = 0.4,(3 * UI:getConst('ab_border_def_width'))
        BlzFrameSetAbsPoint(self.main, FRAMEPOINT_BOTTOM, x, y)

        TriggerRegisterTimerEventPeriodic(self.timer, 0.01)
        TriggerAddAction(self.timer, self.progress)
        DisableTrigger(self.timer)

        BlzFrameSetVisible(self.main, false)
    end

    function cb:getBar()
        return self.bar
    end

    function cb:getText()
        return self.text
    end

    function cb:getNumber()
        return self.number
    end

    function cb:getCastTime()
        return self.castTime
    end

    function cb:setCurTime(t)
        self.curTime = t
    end

    function cb:getCurTime()
        return self.curTime
    end

    function cb:start(u,a)
        self.castTime = BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, a), ABILITY_RLF_FOLLOW_THROUGH_TIME, GetUnitAbilityLevel(u, a)-1)
        self.curTime = self.castTime
        local texture = BlzGetAbilityStringField(BlzGetUnitAbility(u, a), ABILITY_SF_ICON_ACTIVATED)
        local fontColor = font_colors[texture]
        BlzFrameSetTexture(self.icon,'ReplaceableTextures\\CommandButtons\\BTN' .. GetAbilityName(a):gsub(" ","") .. '.dds', 0, true)
        BlzFrameSetTexture(self.bar, texture, 0, true)
        BlzFrameSetValue(self.bar, 0)
        BlzFrameSetTextColor(self.text, fontColor)
        BlzFrameSetTextColor(self.number, fontColor)
        BlzFrameSetText(self.text, GetAbilityName(a))
        BlzFrameSetVisible(self.main, true)
        if not(IsTriggerEnabled(self.timer)) then
            EnableTrigger(self.timer)
        end
    end

    function cb:stop()
        if self:getCurTime() <= 0 then
            BlzFrameSetTextColor(self:getText(), BlzConvertColor(255, 20, 255, 20))
            BlzFrameSetTextColor(self:getNumber(), BlzConvertColor(255, 20, 255, 20))
            BlzFrameSetValue(self:getBar(), 100)
            BlzFrameSetText(self:getText(), 'Completed')
            BlzFrameSetText(self:getNumber(), '0.0')
        else 
            BlzFrameSetTextColor(self:getText(), BlzConvertColor(255, 255, 20, 20))
            BlzFrameSetTextColor(self:getNumber(), BlzConvertColor(255, 255, 20, 20))
            BlzFrameSetText(self:getText(), 'Interrupted')
        end
        if IsTriggerEnabled(self.timer) then
            DisableTrigger(self.timer)
        end
        FrameFading:fadeout(self.main,1.0)
    end

    function cb:progress()
        if CastingBar:getCurTime() >= 0 then
            BlzFrameSetText(CastingBar:getNumber(), StringUtils:round(CastingBar:getCurTime(),1))
            BlzFrameSetValue(CastingBar:getBar(), 100-((CastingBar:getCurTime()/CastingBar:getCastTime())*100)+2)
        end
        CastingBar:setCurTime(CastingBar:getCurTime() - 0.01)
    end

    function cb:rescale(s)
        local x,y = 0.4,(3 * UI:getConst('ab_border_def_width'))
        BlzFrameSetScale(self.main, s)
        BlzFrameSetAbsPoint(self.main, FRAMEPOINT_BOTTOM, x, y)
    end

    function cb:getFontColor(barPath)
        return font_colors[barPath]
    end
end