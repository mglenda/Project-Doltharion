do
    Hero = setmetatable({}, {})
    local hero = getmetatable(Hero)
    hero.__index = hero

    function hero:create(u_id)
        self.unit = CreateUnit(Players:get_player(), FourCC(u_id), GetPlayerStartLocationX(Players:get_player()),GetPlayerStartLocationY(Players:get_player()), 90.0)
        UI.a_panel:loadUnit(self.unit)
        UI.h_panel:loadUnit(self.unit)
        AbilityController:load()
        CastingController:load()
        SelectUnitForPlayerSingle(self.unit, Players:get_player())
        PanCameraToTimedForPlayer(Players:get_player(), GetUnitX(self.unit), GetUnitY(self.unit), 0.0)
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

    OnInit.final(function()
        Hero:create('H000')
    end)
end