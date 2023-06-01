do
    Hero = setmetatable({}, {})
    local hero = getmetatable(Hero)
    hero.__index = hero

    function hero:create(u_id)
        local spawn_r = Rect(-6528.0, -11456.0, -6432.0, -11360.0)
        self.unit = CreateUnit(self:getPlayer(), FourCC(u_id), GetRectCenterX(spawn_r), GetRectCenterY(spawn_r), 90.0)
        UI.a_panel:loadUnit(self.unit)
        UI.h_panel:loadUnit(self.unit)
        AbilityController:load()
        CastingController:load()
        SelectUnitForPlayerSingle(self.unit, self:getPlayer())
        PanCameraToTimedForPlayer(self:getPlayer(), GetUnitX(self.unit), GetUnitY(self.unit), 0.0)
    end

    function hero:get()
        return self.unit
    end

    function hero:setCasting(order)
        self.casting = order
    end

    function hero:clearCasting()
        self.casting = nil
    end

    function hero:isCasting()
        return self.casting
    end

    function hero:getPlayer()
        return Player(0)
    end

    OnInit.final(function()
        local arena = Rect(-7456.0, -11808.0, -5504.0, -9184.0)
        CreateFogModifierRectBJ(true, Hero:getPlayer(), FOG_OF_WAR_VISIBLE, arena)
        Hero:create('H000')
    end)
end