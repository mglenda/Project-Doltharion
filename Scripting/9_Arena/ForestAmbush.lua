do
    ForestAmbush = setmetatable({}, {})
    local fa = getmetatable(ForestAmbush)
    fa.__index = fa

    function fa:create()
        self.arena = Rect(-7456.0, -11808.0, -5504.0, -9184.0)
        self.spawn = Rect(-6528.0, -11456.0, -6432.0, -11360.0)
        self.vision = CreateFogModifierRectBJ(false, Players:get_player(), FOG_OF_WAR_VISIBLE, self.arena)
        self.boss_spawn = Rect(-6464.0, -9664.0, -6368.0, -9568.0)
        self.boss_id = 'n005'
        return self
    end

    function fa:initial_spawn()
        local facing = 270.0
        self.boss = CreateUnit(Players:get_empire(), FourCC(self.boss_id), GetRectCenterX(self.boss_spawn),GetRectCenterY(self.boss_spawn), facing)
        SetUnitColor(self.boss, PLAYER_COLOR_SNOW)

        local x,y = Utils:move_xy(GetUnitX(self.boss),GetUnitY(self.boss),150.0,Deg2Rad(facing-90.0))
        local u = CreateUnit(Players:get_empire(), FourCC('n004'),x,y,facing)
        SetUnitColor(u,PLAYER_COLOR_SNOW)

        x,y = Utils:move_xy(GetUnitX(self.boss),GetUnitY(self.boss),150.0,Deg2Rad(facing+90.0))
        u = CreateUnit(Players:get_empire(), FourCC('n004'),x,y,facing)
        SetUnitColor(u,PLAYER_COLOR_SNOW)

        x,y = Utils:move_xy(GetUnitX(u),GetUnitY(u),212.0,Deg2Rad(facing+45.0))
        for i=1,5 do
            u = CreateUnit(Players:get_empire(), FourCC(Utils:mod(i,2) == 0 and 'n003' or 'n001'),x,y,facing)
            SetUnitColor(u,PLAYER_COLOR_SNOW)
            x,y = Utils:move_xy(GetUnitX(u),GetUnitY(u),150.0,Deg2Rad(facing-90.0))
        end

        x,y = Utils:move_xy(GetUnitX(u),GetUnitY(u),150.0,Deg2Rad(facing))
        for i=1,5 do
            u = CreateUnit(Players:get_empire(), FourCC(Utils:mod(i,2) == 0 and 'n004' or 'n000'),x,y,facing)
            SetUnitColor(u,PLAYER_COLOR_SNOW)
            x,y = Utils:move_xy(GetUnitX(u),GetUnitY(u),150.0,Deg2Rad(facing+90.0))
        end

        x,y = Utils:move_xy(GetUnitX(u),GetUnitY(u),150.0,Deg2Rad(facing))
        for i=1,5 do
            u = CreateUnit(Players:get_empire(), FourCC('n002'),x,y,facing)
            SetUnitColor(u,PLAYER_COLOR_SNOW)
            x,y = Utils:move_xy(GetUnitX(u),GetUnitY(u),150.0,Deg2Rad(facing-90.0))
        end
    end

    function fa:start()
        PauseUnit(Hero:get(), true)
        Utils:set_unit_xy(Hero:get(),GetRectCenterX(self.spawn),GetRectCenterY(self.spawn))
        PanCameraToTimedForPlayer(Players:get_player(), GetUnitX(Hero:get()), GetUnitY(Hero:get()), 0.0)
        FogModifierStart(self.vision)
        Abilities:reset_all_cooldowns(Hero:get())

        self:initial_spawn()
    end

    function fa:stop()
        AllUnits:remove()
        PauseUnit(Hero:get(), false)
        Abilities:reset_all_cooldowns(Hero:get())
    end
end