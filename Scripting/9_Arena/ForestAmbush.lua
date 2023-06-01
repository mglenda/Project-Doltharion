do
    ForestAmbush = setmetatable({}, {})
    local fa = getmetatable(ForestAmbush)
    fa.__index = fa

    function fa:create()
        self.arena = Rect(-7456.0, -11808.0, -5504.0, -9184.0)
        self.spawn = Rect(-6528.0, -11456.0, -6432.0, -11360.0)
        self.vision = CreateFogModifierRectBJ(false, Players:get_player(), FOG_OF_WAR_VISIBLE, self.arena)
        self.boss_spawn = Rect(-6048.0, -9760.0, -5952.0, -9664.0)
        self.boss_id = 'n005'
        return self
    end

    function fa:start()
        Utils:set_unit_xy(Hero:get(),GetRectCenterX(self.spawn),GetRectCenterY(self.spawn))
        PanCameraToTimedForPlayer(Players:get_player(), GetUnitX(Hero:get()), GetUnitY(Hero:get()), 0.0)
        FogModifierStart(self.vision)
        self.boss = CreateUnit(Players:get_empire(), FourCC(self.boss_id), GetRectCenterX(self.boss_spawn),GetRectCenterY(self.boss_spawn), 230.0)
        SetUnitColor(self.boss, PLAYER_COLOR_SNOW)
        PauseUnit(Hero:get(), true)
    end

    function fa:stop()
        AllUnits:remove()
    end
end