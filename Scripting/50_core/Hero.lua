do
    Hero = setmetatable({}, {})
    local hero = getmetatable(Hero)
    hero.__index = hero

    function hero:create(u_id)
        self.unit = CreateUnit(Players:get_player(), FourCC(u_id), GetPlayerStartLocationX(Players:get_player()),GetPlayerStartLocationY(Players:get_player()), 90.0)
        UI.a_panel:loadUnit(self.unit)
        UI.h_panel:loadUnit(self.unit)
        self.safe_zone = Rect(5856.0, -11776.0, 7456.0, -10624.0)
        CreateFogModifierRectBJ(true, Players:get_player(), FOG_OF_WAR_VISIBLE, self.safe_zone)
        AbilityController:load()
        CastingController:load()
        SelectUnitForPlayerSingle(self.unit, Players:get_player())
        PanCameraToTimedForPlayer(Players:get_player(), GetUnitX(self.unit), GetUnitY(self.unit), 0.0)
    end

    function hero:move(x,y)
        x,y = x or GetPlayerStartLocationX(Players:get_player()),y or GetPlayerStartLocationY(Players:get_player())
        Utils:set_unit_xy(self:get(),x,y)
        PanCameraToTimedForPlayer(Players:get_player(), GetUnitX(Hero:get()), GetUnitY(Hero:get()), 0.0)
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
        Hero:create('H001')
    end)
end