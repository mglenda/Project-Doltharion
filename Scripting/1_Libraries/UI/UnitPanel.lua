do
    UI_STAT_DMG = 1
    UI_STAT_POWER = 2
    UI_STAT_CRIT = 3
    UI_STAT_RESIST = 4

    UnitPanel = setmetatable({}, {})
    local up = getmetatable(UnitPanel)
    up.__index = up

    local refreshTrigger = CreateTrigger()

    function up:hide()
        if BlzFrameIsVisible(self.main) then
            BlzFrameSetVisible(self.main, false)
        end
    end

    function up:show()
        if not(BlzFrameIsVisible(self.main)) then
            BlzFrameSetVisible(self.main, true)
        end
    end

    function up:loadUnit(unit)
        self.unit = unit
        BlzFrameSetTexture(BlzGetFrameByName('Details_UnitIconTexture', self.f_id), 'ReplaceableTextures\\CommandButtons\\BTN' .. GetUnitName(self.unit):gsub(" ","") .. '.dds', 0, true)
        BlzFrameSetText(BlzGetFrameByName('Details_Bar_Name_Text', self.f_id), GetUnitName(self.unit))
        self:refresh()
    end

    function up:refresh()
        if self.unit and BlzFrameIsVisible(self.main) then
            BlzFrameSetValue(BlzGetFrameByName('Details_Bar', self.f_id), GetUnitLifePercent(self.unit))
            BlzFrameSetText(BlzGetFrameByName('Details_Bar_HP_Text', self.f_id), tostring(math.floor(GetUnitStateSwap(UNIT_STATE_LIFE, self.unit)))..'/'..tostring(math.floor(GetUnitStateSwap(UNIT_STATE_MAX_LIFE, self.unit))))
            BlzFrameSetText(BlzGetFrameByName('Details_Bar_HPReg_Text', self.f_id), StringUtils:round(GetUnitLifePercent(self.unit),1) .. '%%'.. ' (' .. BlzGetUnitRealField(self.unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE)..'/sec)')
            BlzFrameSetText(BlzGetFrameByName('Stats_StatText', (self.f_id*10) + UI_STAT_CRIT),'15'..'%%')
            BlzFrameSetText(BlzGetFrameByName('Stats_StatText', (self.f_id*10) + UI_STAT_POWER),'58')
            BlzFrameSetText(BlzGetFrameByName('Stats_StatText', (self.f_id*10) + UI_STAT_RESIST),math.floor(BlzGetUnitArmor(self.unit))..'%%')
            BlzFrameSetText(BlzGetFrameByName('Stats_StatText', (self.f_id*10) + UI_STAT_DMG),BlzGetUnitWeaponIntegerField(self.unit, UNIT_WEAPON_IF_ATTACK_DAMAGE_BASE, 0))
        end
        return nil
    end

    function up:rescale(s)
        local x,y = self.f_id == 0 and 0.4 - (2 * UI:getConst('ab_border_def_width')) or 0.4 + (2 * UI:getConst('ab_border_def_width')),0.0
        BlzFrameSetScale(self.main, s)
        BlzFrameSetAbsPoint(self.main, self.f_id == 0 and FRAMEPOINT_BOTTOMRIGHT or FRAMEPOINT_BOTTOMLEFT, x, y)
    end
    
    -- unit panel constructor
    -- @param f_id parameter 0 for player 1 for target
    function up:create(f_id)
        local this = {}
        setmetatable(this, up)

        local x,y = f_id == 0 and 0.4 - (2 * UI:getConst('ab_border_def_width')) or 0.4 + (2 * UI:getConst('ab_border_def_width')),0.0

        this.main = BlzCreateSimpleFrame('Details_Frame', UI:getConst('screen_frame'), f_id)
        this.f_id = f_id

        local barFrame = BlzCreateSimpleFrame('Details_BarFrame', this.main, f_id)
        local bar = BlzCreateSimpleFrame('Details_Bar', barFrame, f_id)
        local barName = BlzCreateSimpleFrame('Details_Bar_Name', bar, f_id)
        local barHP = BlzCreateSimpleFrame('Details_Bar_HP', bar, f_id)
        local barReg = BlzCreateSimpleFrame('Details_Bar_HPReg', bar, f_id)
        local unitIcon = BlzCreateSimpleFrame('Details_UnitIcon', barFrame, f_id)

        local statsFrame = BlzCreateSimpleFrame('Stats_Frame', this.main, f_id)
        local stat_dmg = BlzCreateSimpleFrame('Stats_StatFrame', statsFrame, (f_id*10) + UI_STAT_DMG)
        local stat_power = BlzCreateSimpleFrame('Stats_StatFrame', statsFrame, (f_id*10) + UI_STAT_POWER)
        local stat_resist = BlzCreateSimpleFrame('Stats_StatFrame', statsFrame, (f_id*10) + UI_STAT_RESIST)
        local stat_crit = BlzCreateSimpleFrame('Stats_StatFrame', statsFrame, (f_id*10) + UI_STAT_CRIT)

        BlzFrameSetPoint(barFrame, FRAMEPOINT_BOTTOM, this.main, FRAMEPOINT_TOP, 0, 0)
        BlzFrameSetPoint(unitIcon, FRAMEPOINT_LEFT, barFrame, FRAMEPOINT_LEFT, 0, 0)
        BlzFrameSetPoint(bar, FRAMEPOINT_LEFT, unitIcon, FRAMEPOINT_RIGHT, 0, 0)
        BlzFrameSetPoint(barName, FRAMEPOINT_LEFT, bar, FRAMEPOINT_LEFT, 0, 0)
        BlzFrameSetPoint(barHP, FRAMEPOINT_BOTTOMRIGHT, bar, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
        BlzFrameSetPoint(barReg, FRAMEPOINT_TOPRIGHT, bar, FRAMEPOINT_TOPRIGHT, 0, 0)
        BlzFrameSetPoint(statsFrame, f_id == 0 and FRAMEPOINT_BOTTOMRIGHT or FRAMEPOINT_BOTTOMLEFT, this.main, f_id == 0 and FRAMEPOINT_BOTTOMRIGHT or FRAMEPOINT_BOTTOMLEFT, 0, 0)

        BlzFrameSetPoint(stat_dmg, FRAMEPOINT_TOPLEFT, statsFrame, FRAMEPOINT_TOPLEFT, 0.01, -0.005)
        BlzFrameSetPoint(stat_power, FRAMEPOINT_LEFT, stat_dmg, FRAMEPOINT_RIGHT, 0.01, 0)
        BlzFrameSetPoint(stat_crit, FRAMEPOINT_BOTTOMLEFT, statsFrame, FRAMEPOINT_BOTTOMLEFT, 0.01, 0.013)
        BlzFrameSetPoint(stat_resist, FRAMEPOINT_LEFT, stat_crit, FRAMEPOINT_RIGHT, 0.01, 0)

        BlzFrameSetTexture(BlzGetFrameByName('Stats_StatTexture', (f_id*10) + UI_STAT_DMG), 'war3mapImported\\STAT_AttackDmg.dds', 0, true)
        BlzFrameSetTexture(BlzGetFrameByName('Stats_StatTexture', (f_id*10) + UI_STAT_CRIT), 'war3mapImported\\STAT_CriticalChance.dds', 0, true)
        BlzFrameSetTexture(BlzGetFrameByName('Stats_StatTexture', (f_id*10) + UI_STAT_RESIST), 'war3mapImported\\STAT_Resistance.dds', 0, true)
        BlzFrameSetTexture(BlzGetFrameByName('Stats_StatTexture', (f_id*10) + UI_STAT_POWER), 'war3mapImported\\STAT_AttackPower.dds', 0, true)

        BlzFrameSetAbsPoint(this.main, f_id == 0 and FRAMEPOINT_BOTTOMRIGHT or FRAMEPOINT_BOTTOMLEFT, x, y)

        TriggerAddCondition(refreshTrigger, Filter(function()
            this:refresh()
        end))

        return this
    end

    OnInit(function()
        TriggerRegisterTimerEventPeriodic(refreshTrigger, 0.1)
    end)
end