do
    ForestAmbush = setmetatable({}, {})
    local fa = getmetatable(ForestAmbush)
    fa.__index = fa

    local img = 'war3mapImported\\ForestAmbush.dds'
    local name = 'Forest Ambush'

    function fa:get_name()
        return name 
    end

    function fa:get_img()
        return img
    end

    function fa:create()
        self.arena = Rect(-7456.0, -11808.0, -5504.0, -9184.0)
        self.spawn = Rect(-6528.0, -11456.0, -6432.0, -11360.0)
        self.visions = {
                CreateFogModifierRectBJ(false, Players:get_player(), FOG_OF_WAR_VISIBLE, self.arena)
                ,CreateFogModifierRectBJ(false, Players:get_bandits(), FOG_OF_WAR_VISIBLE, self.arena)
        }
        self.boss_spawn = Rect(-6464.0, -9664.0, -6368.0, -9568.0)
        self.boss_id = 'n005'
        self.r_spawns = {Rect(-7392.0, -10592.0, -7264.0, -9536.0)
                        ,Rect(-7072.0, -9376.0, -5536.0, -9248.0)
                        ,Rect(-5664.0, -10720.0, -5536.0, -9440.0)}
        return self
    end

    function fa:initial_spawn()
        local facing = 270.0
        Arena:set('boss',CreateUnit(Players:get_bandits(), FourCC(self.boss_id), GetRectCenterX(self.boss_spawn),GetRectCenterY(self.boss_spawn), facing))

        local x,y = Utils:move_xy(GetUnitX(Arena:get('boss')),GetUnitY(Arena:get('boss')),150.0,Deg2Rad(facing-90.0))
        local u = CreateUnit(Players:get_bandits(), FourCC('n004'),x,y,facing)

        x,y = Utils:move_xy(GetUnitX(Arena:get('boss')),GetUnitY(Arena:get('boss')),150.0,Deg2Rad(facing+90.0))
        u = CreateUnit(Players:get_bandits(), FourCC('n004'),x,y,facing)

        x,y = Utils:move_xy(GetUnitX(u),GetUnitY(u),212.0,Deg2Rad(facing+45.0))
        for i=1,5 do
            u = CreateUnit(Players:get_bandits(), FourCC(Utils:mod(i,2) == 0 and 'n003' or 'n001'),x,y,facing)
            x,y = Utils:move_xy(GetUnitX(u),GetUnitY(u),150.0,Deg2Rad(facing-90.0))
        end

        x,y = Utils:move_xy(GetUnitX(u),GetUnitY(u),150.0,Deg2Rad(facing))
        for i=1,5 do
            u = CreateUnit(Players:get_bandits(), FourCC(Utils:mod(i,2) == 0 and 'n004' or 'n000'),x,y,facing)
            x,y = Utils:move_xy(GetUnitX(u),GetUnitY(u),150.0,Deg2Rad(facing+90.0))
        end

        x,y = Utils:move_xy(GetUnitX(u),GetUnitY(u),150.0,Deg2Rad(facing))
        for i=1,5 do
            u = CreateUnit(Players:get_bandits(), FourCC('n002'),x,y,facing)
            x,y = Utils:move_xy(GetUnitX(u),GetUnitY(u),150.0,Deg2Rad(facing-90.0))
        end
    end

    function fa:reinforcements()
        local x,y
        local facing = 270.0
        for i = 1,3 do 
            x,y = Utils:get_rect_random_xy(ForestAmbush.r_spawns[GetRandomInt(1, #ForestAmbush.r_spawns)])
            CreateUnit(Players:get_bandits(), FourCC('n002'),x,y,facing)
            x,y = Utils:get_rect_random_xy(ForestAmbush.r_spawns[GetRandomInt(1, #ForestAmbush.r_spawns)])
            CreateUnit(Players:get_bandits(), FourCC('n001'),x,y,facing)
        end
        for i = 1,4 do 
            x,y = Utils:get_rect_random_xy(ForestAmbush.r_spawns[GetRandomInt(1, #ForestAmbush.r_spawns)])
            CreateUnit(Players:get_bandits(), FourCC('n000'),x,y,facing)
        end
        for i = 1,2 do 
            x,y = Utils:get_rect_random_xy(ForestAmbush.r_spawns[GetRandomInt(1, #ForestAmbush.r_spawns)])
            CreateUnit(Players:get_bandits(), FourCC('n004'),x,y,facing)
            x,y = Utils:get_rect_random_xy(ForestAmbush.r_spawns[GetRandomInt(1, #ForestAmbush.r_spawns)])
            CreateUnit(Players:get_bandits(), FourCC('n003'),x,y,facing)
        end
        DBM:create({t=50.0,n='Reinforcements',t_bar=BarType:red(),f=ForestAmbush.reinforcements,t_icon='war3mapImported\\BTNUnitedAura.dds'})
    end

    function fa:start()
        Hero:move(GetRectCenterX(self.spawn),GetRectCenterY(self.spawn))
        SetUnitFacing(Hero:get(), 90.0)
        for _,v in ipairs(self.visions) do FogModifierStart(v) end

        self:initial_spawn()
        Warband:spawn(90.0)
        Units:pause_all()
        
        Units:register_on_death(Arena:get('boss'),'fa_boss_death',ForestAmbush.victory)

        DBM:create({t=5.0,n='Begin in',t_bar=BarType:darkgreen(),f=ForestAmbush.begin,t_icon='war3mapImported\\ArenaBegin.dds'})
    end

    function fa:victory()
        Units:pause_all()
        DBM:pause_all()
        DBM:create({t=10.0,n='Victory',t_bar=BarType:darkgreen(),f=function() Arena:stop(1) end,t_icon='war3mapImported\\ArenaBegin.dds'})
    end

    function fa:begin()
        Units:unpause_all()
        DBM:create({t=35.0,n='Reinforcements',t_bar=BarType:red(),f=ForestAmbush.reinforcements,t_icon='war3mapImported\\BTNUnitedAura.dds'})
    end

    function fa:stop()
        Units:remove_all()
        Units:unpause_all()
    end

    OnInit.main(function()
        Arena:register(ForestAmbush)
    end)
end