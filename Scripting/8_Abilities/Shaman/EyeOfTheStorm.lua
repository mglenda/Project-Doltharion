do
    EyeOfTheStorm = setmetatable({}, {})
    local eots = getmetatable(EyeOfTheStorm)
    eots.__index = eots

    local a_code = 'A012'
    local trg = CreateTrigger()
    local t = {}

    function eots:get_a_code()
        return FourCC(a_code)
    end

    function eots:get_a_string()
        return a_code
    end

    function eots:get_s_color()
        return BlzConvertColor(255, 0, 0, 0)
    end

    function eots:get_c_color()
        return BlzConvertColor(255, 255, 255, 255)
    end

    function eots:on_start()
        local c = GetTriggerUnit()
        local p = Utils:round(CastingTime:get(c,a_code) / BlzGetAbilityIntegerField(BlzGetUnitAbility(c, FourCC(a_code)), ABILITY_IF_MISSILE_SPEED) - 0.01,2)
        local tx,ty,x,y = Units:get_cast_point_x(c),Units:get_cast_point_y(c),GetUnitX(c),GetUnitY(c)
        table.insert(t, {
            c=c
            ,p=p
            ,cp=p
            ,tx=tx
            ,ty=ty
            ,aoe=BlzGetAbilityRealLevelField(BlzGetUnitAbility(c, FourCC(a_code)), ABILITY_RLF_AREA_OF_EFFECT, 0) 
            ,e=EffectAnimation:create_xyz('Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl',x,y,450.0,5.0,1.5)
            ,lc=0
        })
        EnableTrigger(trg)
    end

    function eots:on_end()
        local c = GetTriggerUnit()
        for i=#t,1,-1 do
            if t[i].c == c then 
                DestroyEffect(t[i].e)
                if t[i].l then DestroyLightning(t[i].l) end
                table.remove(t,i) 
            end
        end
    end

    function eots:damage_area(i)
        DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl', t[i].tx, t[i].ty))
        for _,u in ipairs(Units:get_area_alive_enemy(t[i].tx,t[i].ty,t[i].aoe,GetOwningPlayer(t[i].c))) do
            DamageEngine:damage_unit(t[i].c,u,SpellPower:get(t[i].c) * 0.5,ATTACK_TYPE_MAGIC,DAMAGE_TYPE_LIGHTNING,FourCC(a_code))
        end
    end

    function eots:channeling()
        for i=#t,1,-1 do
            if BlzGetSpecialEffectScale(t[i].e) >= 5 then 
                if t[i].lc >= 40 then 
                    if t[i].l then 
                        DestroyLightning(t[i].l)
                        t[i].l = nil
                    end
                    t[i].lc = 0
                else 
                    t[i].lc = t[i].lc + 1 
                end
                if not(t[i].l) then 
                    t[i].l = AddLightningEx('PURP', false, BlzGetLocalSpecialEffectX(t[i].e), BlzGetLocalSpecialEffectY(t[i].e), BlzGetLocalSpecialEffectZ(t[i].e), t[i].tx, t[i].ty, 30.0) 
                    EyeOfTheStorm:damage_area(i)
                end
                if t[i].cp <= 0 then 
                    t[i].cp = t[i].p
                    EyeOfTheStorm:damage_area(i)
                else
                    t[i].cp = Utils:round(t[i].cp - 0.01,2)
                end
                local x,y = MouseCoords:get_xy()
                if Utils:get_distance(t[i].tx,t[i].ty,x,y) > 5.0 then 
                    local r = Utils:get_rad_between_points(t[i].tx,t[i].ty,x,y)
                    t[i].tx = Utils:move_x(t[i].tx,3.0,r)
                    t[i].ty = Utils:move_y(t[i].ty,3.0,r)
                    r = Utils:get_angle_between_points(GetUnitX(t[i].c),GetUnitY(t[i].c),t[i].tx,t[i].ty)
                    SetUnitFacing(t[i].c, r)
                    if t[i].l then 
                        MoveLightningEx(t[i].l, true, BlzGetLocalSpecialEffectX(t[i].e), BlzGetLocalSpecialEffectY(t[i].e), BlzGetLocalSpecialEffectZ(t[i].e), t[i].tx, t[i].ty, 30.0)
                    end
                end
            end
        end
        if #t == 0 then DisableTrigger(trg) end
    end

    OnInit.map(function()
        Data:register_ability_class(EyeOfTheStorm:get_a_code(),EyeOfTheStorm)
        TriggerRegisterTimerEventPeriodic(trg, 0.01)
        TriggerAddAction(trg, EyeOfTheStorm.channeling)
    end)
end