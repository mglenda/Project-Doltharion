do
    AbilitiesPanel = setmetatable({}, {})
    local ap = getmetatable(AbilitiesPanel)
    ap.__index = ap

    local tooltip_width = 0.22
    local tooltip_height = 0.23
    local tooltip_x = 0.4
    local tooltip_y = 0.13

    local section_styles = {
        damage = {label = 'Damage', label_color = '|cffff6b35', value_color = '|cffffc38a'},
        pulse_damage = {label = 'Pulse Damage', label_color = '|cffff6b35', value_color = '|cffffc38a'},
        missile_damage = {label = 'Missile Damage', label_color = '|cffff6b35', value_color = '|cffffc38a'},
        firebolt_damage = {label = 'Firebolt Damage', label_color = '|cffff6b35', value_color = '|cffffc38a'},
        phoenix_damage = {label = 'Phoenix Damage', label_color = '|cffff6b35', value_color = '|cffffc38a'},
        cast_time = {label = 'Cast Time', label_color = '|cff4fc3f7', value_color = '|cffb3e5fc'},
        damage_period = {label = 'Damage Period', label_color = '|cff4fc3f7', value_color = '|cffb3e5fc'},
        missile_period = {label = 'Missile Period', label_color = '|cff4fc3f7', value_color = '|cffb3e5fc'},
        duration = {label = 'Duration', label_color = '|cffb388ff', value_color = '|cffe1bee7'},
        range = {label = 'Range', label_color = '|cff64d8cb', value_color = '|cffb2f5ea'},
        radius = {label = 'Radius', label_color = '|cff64d8cb', value_color = '|cffb2f5ea'},
        missiles = {label = 'Missiles', label_color = '|cffffca5c', value_color = '|cffffe0a3'},
        attack_speed = {label = 'Attack Speed', label_color = '|cffffca5c', value_color = '|cffffe0a3'},
        cast_speed = {label = 'Casting Speed', label_color = '|cff4fc3f7', value_color = '|cffb3e5fc'},
        resistance = {label = 'Resistance', label_color = '|cff55d6be', value_color = '|cffb2f5ea'},
        health_regen = {label = 'Health Regeneration', label_color = '|cff72d572', value_color = '|cffc8f7c5'},
        max_stacks = {label = 'Maximum Stacks', label_color = '|cff72d572', value_color = '|cffc8f7c5'},
        shield = {label = 'Shield', label_color = '|cff55d6be', value_color = '|cffb2f5ea'},
        spell_power = {label = 'Spell Power', label_color = '|cffb388ff', value_color = '|cffe1bee7'},
        trigger = {label = 'Trigger', label_color = '|cffffca5c', value_color = '|cffffe0a3'},
        critical = {value_color = '|cff00ff00'},
        effect = {value_color = '|cffffcc00'},
        stacks = {label_color = '|cff72d572', value_color = '|cffc8f7c5'},
        resource = {label_color = '|cffffca5c', value_color = '|cffffe0a3'}
    }

    local percent_placeholders = {
        attack_speed = true,
        cast_speed = true,
        resistance = true,
        spell_power = true
    }

    local seconds_placeholders = {
        cast_time = true,
        cooldown = true,
        damage_period = true,
        missile_period = true,
        duration = true,
        phoenix_duration = true
    }

    local damage_placeholders = {
        damage = true,
        pulse_damage = true,
        missile_damage = true,
        firebolt_damage = true,
        phoenix_damage = true,
        shield = true,
        health_regen = true,
        stack_regen = true
    }

    local function format_number(value)
        local result = tostring(math.floor(value + 0.5))
        while true do
            local updated,count = result:gsub('^(-?%d+)(%d%d%d)', '%1 %2')
            result = updated
            if count == 0 then return result end
        end
    end

    local function format_decimal(value)
        local rounded = Utils:round(value, 2)
        return tostring(tonumber(rounded) or rounded)
    end

    local function format_placeholder(key,value)
        if Utils:type(value) ~= 'number' then return tostring(value) end
        if percent_placeholders[key] then return format_decimal(value) .. '%' end
        if seconds_placeholders[key] then return format_decimal(value) .. ' seconds' end
        if damage_placeholders[key] then return format_number(value) end
        if key == 'range' or key == 'radius' then return format_number(value) end
        return format_decimal(value)
    end

    local function resolve_placeholders(text,values)
        local resolved = text:gsub('%$([%w_]+)%$', function(key)
            return values[key] == nil and ('$' .. key .. '$') or format_placeholder(key,values[key])
        end)
        return resolved
    end

    local function render_section(key,content,values)
        local style = section_styles[key] or {
            label = key:gsub('_', ' '),
            label_color = '|cffffffff',
            value_color = '|cffffffff'
        }
        content = resolve_placeholders(content,values)
        if style.label then
            return style.label_color .. style.label .. ':|r ' .. style.value_color .. content .. '|r'
        end
        return style.value_color .. content .. '|r'
    end

    function ap:hide()
        DisableTrigger(self.trg)
        if BlzFrameIsVisible(self.listenerCont) then BlzFrameSetVisible(self.listenerCont, false) end
        if BlzFrameIsVisible(self.main) then BlzFrameSetVisible(self.main, false) end
    end

    function ap:show()
        if not(BlzFrameIsVisible(self.listenerCont)) then BlzFrameSetVisible(self.listenerCont, true) end
        if not(BlzFrameIsVisible(self.main)) then BlzFrameSetVisible(self.main, true) end
        EnableTrigger(self.trg)
    end

    function ap:rescale()
        local x,y,s = 0.4 - (2 * UI:getConst('ab_border_def_width')),0.0,1.0
        for i,tbl in ipairs(self.predef) do
            for j,f_id in ipairs(tbl) do
                if i == 1 and j == 1 then
                    BlzFrameSetAbsPoint(BlzGetFrameByName('AbilityButton_Border', tonumber(f_id)), FRAMEPOINT_BOTTOMLEFT, x, y)
                    s = UI:getConst('ab_border_def_width') / BlzFrameGetWidth(BlzGetFrameByName('AbilityButton_Border', tonumber(f_id)))
                end
                BlzFrameSetScale(BlzGetFrameByName('AbilityButton_Border', tonumber(f_id)), (s * 4) / #tbl)
                BlzFrameSetScale(BlzGetFrameByName('AbilityButton_Sprite', tonumber(f_id)), Utils:round(UI:getConst('ab_sprite_def_scale') * (((UI:getConst('ab_border_def_width') * 4) / #tbl) / UI:getConst('ab_border_def_width')),2))
            end
        end
    end

    function ap:create()
        local this = {}
        setmetatable(this, ap)

        this.predef = {
            {'00','10','20','30'} --BOTTOM ROW
            ,{'01','11','21','31'} -- MIDDLE ROW
            ,{'02','12','22','32','42'} -- TOP ROW
        }
        this.list = {}
        this.listeners = {}
        this.buttons = {}
        this.tooltips = {}
        this.tooltipData = {}
        this.trg = CreateTrigger()
        TriggerRegisterTimerEventPeriodic(this.trg, 0.1)
        DisableTrigger(this.trg)
        TriggerAddAction(this.trg, function()
            if UI.a_panel then UI.a_panel:refresh_ability_status_all() end
        end)
        
        local x,y = 0.4 - (2 * UI:getConst('ab_border_def_width')),0.0

        this.main = BlzCreateSimpleFrame('AbilityContainer', UI:getConst('screen_frame'), 0)
        this.listenerCont = BlzCreateFrame('AbilityListenerContainer', UI:getConst('screen_frame'), 0, 0)
        
        local prev,cur = nil,nil
        for i,tbl in ipairs(this.predef) do
            for j,f_id in ipairs(tbl) do
                cur = BlzCreateSimpleFrame('AbilityButton_Border', this.main, tonumber(f_id))
                local icon = BlzCreateSimpleFrame('AbilityButton_Icon', cur, tonumber(f_id))
                local shortcut = BlzCreateSimpleFrame('AbilityButton_Shortcut', icon, tonumber(f_id))
                BlzFrameSetPoint(icon, FRAMEPOINT_CENTER, cur, FRAMEPOINT_CENTER, 0, 0)
                BlzFrameSetPoint(shortcut, FRAMEPOINT_BOTTOMRIGHT, icon, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
                this.buttons[tonumber(f_id)] = icon
                local sprite = BlzCreateFrameByType('SPRITE', 'AbilityButton_Sprite', this.listenerCont, "", tonumber(f_id))
                BlzFrameClearAllPoints(sprite)
                BlzFrameSetPoint(sprite, FRAMEPOINT_BOTTOMLEFT, cur, FRAMEPOINT_BOTTOMLEFT, 0, 0)
                BlzFrameSetSize(sprite, 0.00001, 0.00001)
                BlzFrameSetModel(sprite, 'war3mapImported\\neon_sprite.mdx', 0)
                if i == 1 and j == 1 then
                    BlzFrameSetAbsPoint(cur, FRAMEPOINT_BOTTOMLEFT, x, y)
                else
                    BlzFrameSetPoint(cur,j == 1 and FRAMEPOINT_BOTTOMLEFT or FRAMEPOINT_LEFT,j == 1 and BlzGetFrameByName('AbilityButton_Border', tonumber(this.predef[i-1][1])) or prev, j == 1 and FRAMEPOINT_TOPLEFT or FRAMEPOINT_RIGHT, 0, 0)
                    BlzFrameSetScale(cur, ((UI:getConst('ab_border_def_width') * 4) / #tbl) / UI:getConst('ab_border_def_width'))
                    BlzFrameSetScale(sprite, Utils:round(UI:getConst('ab_sprite_def_scale') * (((UI:getConst('ab_border_def_width') * 4) / #tbl) / UI:getConst('ab_border_def_width')),2))
                end
                prev = cur
            end
        end

        this:hideIcons()

        return this
    end

    function ap:createTooltips()
        local tooltip_parent = UI:getConst('screen_frame')

        for _,tbl in ipairs(self.predef) do
            for _,f_id in ipairs(tbl) do
                local context = tonumber(f_id)
                local icon = self.buttons[context]
                local tooltip = BlzCreateSimpleFrame('AbilityButton_Tooltip', tooltip_parent, context)
                if not(tooltip) then
                    print('Unable to create AbilityButton_Tooltip: ' .. f_id)
                    return false
                end
                BlzFrameSetAbsPoint(tooltip, FRAMEPOINT_BOTTOM, tooltip_x, tooltip_y)
                BlzFrameSetSize(tooltip, 0.00001, 0.00001)
                BlzFrameSetLevel(tooltip, 100)
                BlzFrameSetVisible(tooltip, false)
                BlzFrameSetTooltip(icon, tooltip)
                local tooltip_header = BlzGetFrameByName('AbilityButton_Tooltip_Header', context)
                if not(tooltip_header) then
                    print('Unable to find AbilityButton_Tooltip_Header: ' .. f_id)
                    return false
                end
                self.tooltips[context] = {
                    frame = tooltip,
                    header = tooltip_header,
                    lore = BlzGetFrameByName('AbilityButton_Tooltip_Lore', context),
                    description = BlzGetFrameByName('AbilityButton_Tooltip_Description', context),
                    special = BlzGetFrameByName('AbilityButton_Tooltip_Special', context),
                    stats = BlzGetFrameByName('AbilityButton_Tooltip_Stats', context),
                    cooldown = BlzGetFrameByName('AbilityButton_Tooltip_Cooldown', context)
                }
            end
        end
        return true
    end

    function ap:hideIcons()
        for i,tbl in ipairs(self.predef) do
            for j,f_id in ipairs(tbl) do
                BlzFrameSetVisible(BlzGetFrameByName("AbilityButton_Sprite", tonumber(f_id)), false)
                BlzFrameSetVisible(BlzGetFrameByName(string.sub(f_id, -1) == '2' and "AbilityButton_Border" or "AbilityButton_Icon", tonumber(f_id)), false)
            end
        end
    end

    function ap:reset()
        self.list = {}
        self.tooltipData = {}
        for _,tooltip in pairs(self.tooltips) do
            BlzFrameSetText(tooltip.header, '')
            BlzFrameSetText(tooltip.lore, '')
            BlzFrameSetText(tooltip.description, '')
            BlzFrameSetText(tooltip.special, '')
            BlzFrameSetText(tooltip.stats, '')
            BlzFrameSetText(tooltip.cooldown, '')
            BlzFrameSetSize(tooltip.frame, 0.00001, 0.00001)
        end
        self:hideIcons()
    end

    function ap:setNormal(ac)
        if Utils:type(self.list[ac]) == 'table' then 
            local state_changed = self.list[ac][2] or self.list[ac][3]
            self.list[ac][2] = false
            self.list[ac][3] = false
            if state_changed then
                BlzFrameSetEnable(self.list[ac][6], true)
                BlzFrameSetTexture(self.list[ac][1], 'war3mapImported\\BTN' .. GetAbilityName(ac):gsub(" ","") .. '.dds', 0, true)
                BlzFrameSetTextColor(self.list[ac][4], Data:get_ability_class(ac):get_s_color())
            end
        end
    end

    function ap:setPushed(ac)
        if Utils:type(self.list[ac]) == 'table' then 
            self.list[ac][3] = false
            if not(self.list[ac][2]) then
                self:refresh_ability_status(ac)
                BlzFrameSetTexture(self.list[ac][1], 'war3mapImported\\BTN' .. GetAbilityName(ac):gsub(" ","") .. 'Pushed.dds', 0, true)
            end
            self.list[ac][2] = true
        end
    end

    function ap:setDisabled(ac)
        if Utils:type(self.list[ac]) == 'table' then 
            self.list[ac][2] = false
            if not(self.list[ac][3]) then 
                BlzFrameSetEnable(self.list[ac][6], true)
                BlzFrameSetTexture(self.list[ac][1], 'war3mapImported\\BTN' .. GetAbilityName(ac):gsub(" ","") .. 'Disabled.dds', 0, true) 
                BlzFrameSetTextColor(self.list[ac][4], Data:get_ability_class(ac):get_c_color())
            end
            self.list[ac][3] = true
        end
    end

    function ap:getAbilityByListener(frame)
        return self.listeners[frame]
    end

    function ap:getListenerByAbility(abCode)
        for frame,v in pairs(self.listeners) do
            if v == abCode then return frame end
        end
        return nil
    end

    function ap:refresh_ability_status_all()
        if self.list then 
            for ac,v in pairs(self.list) do
                self:refresh_ability_status(ac)
                -- Mutating a visible native tooltip cancels SIMPLEBUTTON's hover state.
                -- Refresh it while hidden so its values are current before the next hover.
                if self.tooltipData[ac] and not(BlzFrameIsVisible(self.tooltipData[ac].tooltip.frame)) then
                    local ok = pcall(function() self:refreshTooltip(ac) end)
                    if not(ok) then
                        BlzFrameSetText(self.tooltipData[ac].tooltip.header,'|cffffcc00' .. GetAbilityName(ac) .. '|r')
                    end
                end
            end
        end
    end

    function ap:getTooltipValues(u,ac)
        local ability = BlzGetUnitAbility(u,ac)
        local class = Data:get_ability_class(ac)
        local values = {
            cast_time = class and CastingTime:get(u,class:get_a_string()) or 0,
            cooldown = Abilities:get_ability_cooldown(u,ac),
            range = Abilities:get_cast_range(u,ac),
            radius = BlzGetAbilityRealLevelField(ability,ABILITY_RLF_AREA_OF_EFFECT,0)
        }
        if class and Utils:type(class.get_tooltip_values) == 'function' then
            values = Utils:table_merge(values,class:get_tooltip_values(u))
        end
        return values
    end

    function ap:refreshTooltip(ac)
        local data = self.tooltipData[ac]
        if not(data) then return end

        local values = self:getTooltipValues(data.unit,ac)
        local description_lines,specials,stats,cooldown = {},{},{},''
        for line in (data.template .. '\n'):gmatch('(.-)\n') do
            local section,content = line:match('^@([%w_]+)%s*(.*)$')
            if section == 'cooldown' then
                cooldown = values.cooldown > 0
                    and '|cff9aa4b2Cooldown:|r |cffffffff' .. format_placeholder('cooldown',values.cooldown) .. '|r'
                    or '|cff9aa4b2No Cooldown|r'
            elseif section == 'critical' or section == 'effect' then
                table.insert(specials,render_section(section,content,values))
            elseif section then
                table.insert(stats,render_section(section,content,values))
            elseif line ~= '' then
                table.insert(description_lines,resolve_placeholders(line,values))
            end
        end

        local shortcut = data.shortcut ~= '_' and data.shortcut or ''
        local suffix = data.is_interactive
            and (shortcut ~= '' and ' |cffff9f43[' .. shortcut .. ']|r' or '')
            or ' |cff55d6be[Passive]|r'
        BlzFrameSetSize(data.tooltip.frame,tooltip_width,tooltip_height)
        BlzFrameSetText(data.tooltip.header,'|cffffcc00' .. GetAbilityName(ac) .. '|r' .. suffix)
        BlzFrameSetText(data.tooltip.lore,data.lore)
        BlzFrameSetText(data.tooltip.description,table.concat(description_lines,'|n'))
        BlzFrameSetText(data.tooltip.special,table.concat(specials,'|n'))
        BlzFrameSetText(data.tooltip.stats,table.concat(stats,'|n'))
        BlzFrameSetText(data.tooltip.cooldown,cooldown)
    end

    function ap:refresh_ability_status(ac)
        local s,st,c,ih = Abilities:get_ability_status(Hero:get(),ac)
        if not(self.list[ac][2]) then
            if s == 'rdy' then 
                self:setNormal(ac)
                BlzFrameSetText(self.list[ac][4], st > 1 and StringUtils:round(st,0) or '')
            elseif s == 'cd' then 
                self:setDisabled(ac) 
                BlzFrameSetText(self.list[ac][4], StringUtils:round(c,1))
            elseif s == 'silenced' then
                self:setDisabled(ac)
                BlzFrameSetText(self.list[ac][4], '')
            end
        end
        BlzFrameSetVisible(self.list[ac][5], ih and s == 'rdy')
    end
    
    function ap:loadUnit(u)
        self:reset()
        for _,ac in ipairs(ObjectUtils:get_unit_ability_codes{unit = u}) do
            if ac ~= 'Aatk' then
                local x = BlzGetAbilityIntegerField(BlzGetUnitAbility(u, FourCC(ac)), ABILITY_IF_BUTTON_POSITION_NORMAL_X)
                local y = BlzGetAbilityIntegerField(BlzGetUnitAbility(u, FourCC(ac)), ABILITY_IF_BUTTON_POSITION_NORMAL_Y)
                if BlzGetFrameByName('AbilityButton_Icon', tonumber(x .. y)) then
                    BlzFrameSetVisible(BlzGetFrameByName(y == 2 and "AbilityButton_Border" or "AbilityButton_Icon", tonumber(x .. y)), true)
                    local sc = BlzGetAbilityActivatedTooltip(FourCC(ac), GetUnitAbilityLevel(u,FourCC(ac)))
                    local cast_type = sc:sub(3, 3)
                    local is_interactive = cast_type == 'I' or cast_type == 'U' or cast_type == 'P' or cast_type == 'S'
                    BlzFrameSetVisible(BlzGetFrameByName('AbilityButton_Shortcut', tonumber(x .. y)), is_interactive and not(sc == 'Tool tip missing!' or sc:sub(1, 1) == '_'))
                    BlzFrameSetText(BlzGetFrameByName('AbilityButton_Shortcut_Text', tonumber(x .. y)), sc == 'Tool tip missing!' and '' or sc:sub(1, 1))
                    BlzFrameSetText(BlzGetFrameByName('AbilityButton_Icon_Text', tonumber(x .. y)),'')
                    local icon_path = 'war3mapImported\\BTN' .. GetAbilityName(FourCC(ac)):gsub(" ","") .. '.dds'
                    local icon_texture = BlzGetFrameByName('AbilityButton_Icon_Texture', tonumber(x .. y))
                    BlzFrameSetTexture(icon_texture,icon_path,0,true)
                    local button = BlzGetFrameByName('AbilityButton_Icon', tonumber(x .. y))
                    BlzFrameSetEnable(button, true)
                    local tooltip = self.tooltips[tonumber(x .. y)]
                    local ability_code = FourCC(ac)
                    local level = GetUnitAbilityLevel(u,ability_code)
                    if tooltip then
                        self.tooltipData[ability_code] = {
                            unit = u,
                            tooltip = tooltip,
                            shortcut = sc:sub(1,1),
                            is_interactive = is_interactive,
                            lore = BlzGetAbilityResearchTooltip(ability_code,level) or '',
                            template = BlzGetAbilityResearchExtendedTooltip(ability_code,level) or ''
                        }
                        BlzFrameSetSize(tooltip.frame,tooltip_width,tooltip_height)
                        local tooltip_ok = pcall(function()
                            self:refreshTooltip(ability_code)
                        end)
                        if not(tooltip_ok) then
                            print('Tooltip data failed for ability ' .. ac)
                            BlzFrameSetText(tooltip.header,'|cffffcc00' .. GetAbilityName(ability_code) .. '|r')
                        end
                        -- Attach only after the tooltip has its final size and text. Warcraft
                        -- otherwise keeps the initial zero-sized/hidden tooltip state cached.
                        BlzFrameSetTooltip(button,tooltip.frame)
                    end
                    self.list[ability_code] = {icon_texture,false,false,BlzGetFrameByName('AbilityButton_Icon_Text', tonumber(x .. y)),BlzGetFrameByName('AbilityButton_Sprite', tonumber(x .. y)),button,is_interactive}
                    self.listeners[button] = ability_code
                end 
            end
        end
        self:show()
    end
end
