do
    Beastmaster = setmetatable({}, {})
    local a = getmetatable(Beastmaster)
    a.__index = a

    local img = 'war3mapImported\\BeastmasterArena.dds'
    local name = 'Beastmaster'
    local order = 1

    local boss_type_id = FourCC('N006')
    local uid_wolf = FourCC('n007')
    local uid_direbeast = FourCC('n009')
    local uid_ragingbeast = FourCC('n008')
    local uid_bear = FourCC('n00A')

    function a:get_name()
        return name
    end

    function a:get_img()
        return img
    end

    function a:create()
        --Mandatory
        self.r_arena = {
            Rect(-6432.0, 8928.0, -6240.0, 10272.0)
            ,Rect(-4640.0, 8928.0, -4448.0, 10272.0)
            ,Rect(-6304.0, 8416.0, -4576.0, 10784.0)
        }
        self.r_spawn = Rect(-5504.0, 8896.0, -5376.0, 9056.0)
        self.b_data = {
            {id = boss_type_id,spawn = Rect(-5504.0, 10080.0, -5376.0, 10240.0)}
        }
        self.sounds = {
            start = {
                sound = gg_snd_BM_Init
                ,text = "That does it, i will hunt you down !"
            }
            ,flee = {
                sound = gg_snd_BM_Defeat
                ,text = "Phr, hardly a challenge it would seem."
            }
            ,enrage = {
                sound = gg_snd_BM_Enrage
                ,text = "Your head will soon be mounted on my wall !"
            }
            ,codowave = {
                sound = gg_snd_BM_CodoWave
                ,text = "My beasts will devour you !"
            }
            ,rage = {
                sound = gg_snd_BM_Raged
                ,text = "Raaaaaargh ... !!!"
            }
            ,summonbeast = {
                sound = gg_snd_BM_SummonBeasts
                ,text = "Come my pets, serve your master !"
            }
            ,defeat = {
                sound = gg_snd_BM_Flee
                ,text = "It is the law of the wild, the strong take from the weak."
            }
            ,victory = {
                sound = gg_snd_BM_Victory
                ,text = "At last, the hunt ... is oveeerghh ..."
            }
        }

        --Exclusive
        self.r_creep_spawns = {
            Rect(-6368.0, 8992.0, -6240.0, 10208.0)
            ,Rect(-4640.0, 8992.0, -4512.0, 10208.0)
        }
        self.c_spawn_groups = {
            {
                uid_wolf
                ,uid_wolf
                ,uid_wolf
                ,uid_wolf
                ,uid_wolf
                ,uid_direbeast
                ,uid_direbeast
                ,uid_direbeast
                ,uid_ragingbeast
                ,uid_ragingbeast
            }
            ,{
                uid_direbeast
                ,uid_direbeast
                ,uid_direbeast
                ,uid_direbeast
                ,uid_direbeast
                ,uid_direbeast
                ,uid_ragingbeast
                ,uid_ragingbeast
                ,uid_ragingbeast
            }
            ,{
                uid_wolf
                ,uid_wolf
                ,uid_wolf
                ,uid_wolf
                ,uid_wolf
                ,uid_wolf
                ,uid_bear
            }
        }

        self.codo_spawns = {
            Rect(-6208.0, 10624.0, -6112.0, 10720.0)
            ,Rect(-6048.0, 10624.0, -5952.0, 10720.0)
            ,Rect(-5888.0, 10624.0, -5792.0, 10720.0)
            ,Rect(-5728.0, 10624.0, -5632.0, 10720.0)
            ,Rect(-5568.0, 10624.0, -5472.0, 10720.0)
            ,Rect(-5408.0, 10624.0, -5312.0, 10720.0)
            ,Rect(-5248.0, 10624.0, -5152.0, 10720.0)
            ,Rect(-5088.0, 10624.0, -4992.0, 10720.0)
            ,Rect(-4928.0, 10624.0, -4832.0, 10720.0)
            ,Rect(-4768.0, 10624.0, -4672.0, 10720.0)
        }
        self.codo_clean_area = Rect(-6400.0, 8288.0, -4480.0, 8448.0)
        self.codo_table = {}

        return self
    end
    
    function a:start()
        self.c_spawn_count = 0
        self.enraged = false
        local e_trg = ArenaUtils:create_trigger()
        self.boss = ArenaUtils:get_boss()
        TriggerRegisterUnitLifeEvent(e_trg, self.boss, LESS_THAN_OR_EQUAL, HitPoints:get(self.boss) * 0.25)
        TriggerAddAction(e_trg, function()
            ArenaUtils:destroy_trigger(GetTriggeringTrigger())
            self:enrage()
        end)

        self.codo_trigger = ArenaUtils:create_trigger()
        DisableTrigger(self.codo_trigger)
        TriggerRegisterTimerEventPeriodic(self.codo_trigger, 0.01)
        TriggerAddAction(self.codo_trigger, function()
            self:codo_wave_periodic()
        end)
    end

    function a:begin()
        Units:freeze(self.boss)
        DBM:create({t=20.0,n='Call Beasts',t_bar=BarType:green(),f=function() self:spawn_creeps() end,t_icon='war3mapImported\\BTNSummonBeast.dds'})
    end

    function a:enrage()
        ArenaUtils:play_boss_sound{key = 'enrage'}
        Units:unfreeze(self.boss)
        self.enraged = true
        if self.codo_waving then
            DBM:destroy_by_name('Codo Wave')
            self:codo_wave_end()
        end
    end

    function a:spawn_creeps()
        if self.c_spawn_count < 1 or self.enraged then
            ArenaUtils:play_boss_sound{key = 'summonbeast'}
            DBM:create({t=20.0,n='Call Beasts',t_bar=BarType:green(),f=function() self:spawn_creeps() end,t_icon='war3mapImported\\BTNSummonBeast.dds'})
            self.c_spawn_count = self.c_spawn_count + 1
        else
            ArenaUtils:play_boss_sound{key = 'codowave'}
            self.c_spawn_count = 0
            self:codo_wave_start()
            DBM:create({t=15.0,n='Codo Wave',t_bar=BarType:red(),f=function() self:codo_wave_end() end,t_icon='war3mapImported\\BTNCodoWave.dds'})
        end

        local spawn_group = self.c_spawn_groups[GetRandomInt(1,#self.c_spawn_groups)]
        local hx,hy = Utils:GetUnitXY(Hero:get())
        for _,uid in ipairs(spawn_group) do
            local r = self.r_creep_spawns[GetRandomInt(1,#self.r_creep_spawns)]
            local x,y = Utils:get_rect_random_xy(r)
            local facing = Utils:get_angle_between_points(x,y,hx,hy)
            CreateUnit(Players:get_challengers(),uid,x,y,facing)
        end
    end

    function a:codo_wave_start()
        self.codo_spawn_count = 5
        self.period = 100
        self._period = 10
        self.codo_rad = 270.0 * bj_DEGTORAD
        self.codo_speed = 4
        self.codo_aoe = 120
        self.codo_impact_offset = 40.0
        self.codo_waving = true
        EnableTrigger(self.codo_trigger)
    end

    function a:codo_wave_periodic()
        if self.codo_waving then 
            if self._period <= 0 then
                self._period = self.period
                Utils:itable_shuffle(self.codo_spawns)
                for i=1,5 do
                    local x,y = GetRectCenterX(self.codo_spawns[i]),GetRectCenterY(self.codo_spawns[i])
                    local sx = Utils:move_x(x, self.codo_impact_offset, self.codo_rad)
                    local sy = Utils:move_y(y, self.codo_impact_offset, self.codo_rad)
                    local tbl = {
                        e = AddSpecialEffect('Abilities\\Spells\\Other\\Stampede\\StampedeMissile.mdl', x, y)
                        ,marker = SpellMarker:create{
                                    type = 'green'
                                    ,x = sx
                                    ,y = sy
                                    ,aoe = self.codo_aoe
                                }
                        ,x = x
                        ,y = y
                    }
                    BlzSetSpecialEffectScale(tbl.e, 1.25)
                    BlzSetSpecialEffectYaw(tbl.e, self.codo_rad)
                    table.insert(self.codo_table,tbl)
                end
            else
                self._period = self._period - 1
            end
        end

        for i=#self.codo_table,1,-1 do
            local codo_t = self.codo_table[i]
            local x,y = codo_t.x,codo_t.y

            local impact_unit = nil
            for u,_ in pairs(Units:get_all_units()) do
                if IsUnitAliveBJ(u) and not(u == self.boss) and Utils:get_unit_distance(x,y,u) <= self.codo_aoe then
                    impact_unit = u
                    break
                end
            end

            if Utils:is_point_in_rect(x,y,self.codo_clean_area) or impact_unit then
                table.remove(self.codo_table,i)
                DestroyEffect(codo_t.e)
                codo_t.marker:destroy()
                if impact_unit then
                    local e = AddSpecialEffect('Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl', codo_t.x , codo_t.y)
                    DestroyEffect(e)
                    DamageEngine:damage_unit{
                        source = self.boss
                        ,target = impact_unit
                        ,damage = 1500.0
                        ,attack_type = ATTACK_TYPE_HERO
                        ,damage_type = DAMAGE_TYPE_DEMOLITION
                        ,id = CodoWave:get_a_code()
                    }
                    Buffs:apply(self.boss
                            ,impact_unit
                            ,'crippled'
                    )
                end
            else
                codo_t.x = Utils:move_x(codo_t.x, self.codo_speed, self.codo_rad)
                codo_t.y = Utils:move_y(codo_t.y, self.codo_speed, self.codo_rad)
                BlzSetSpecialEffectX(codo_t.e, codo_t.x)
                BlzSetSpecialEffectY(codo_t.e, codo_t.y)
                codo_t.marker:move(self.codo_speed,self.codo_rad)
            end
        end
        if not(self.codo_waving) and #self.codo_table == 0 then
            DisableTrigger(self.codo_trigger)
        end
    end

    function a:codo_wave_end()
        self.codo_waving = false
        DBM:create({t=20.0,n='Call Beasts',t_bar=BarType:green(),f=function() self:spawn_creeps() end,t_icon='war3mapImported\\BTNSummonBeast.dds'})
    end

    function a:codo_wave_flush()
        for i=#self.codo_table,1,-1 do
            DestroyEffect(self.codo_table[i].e)
            self.codo_table[i].marker:destroy()
            table.remove(self.codo_table,i)
        end
    end

    function a:exit()
        self:codo_wave_flush()
    end

    OnInit.global(function()
        Arena:register(Beastmaster,order)
    end)
end