do
    Hero = setmetatable({}, {})
    local hero = getmetatable(Hero)
    hero.__index = hero

    function hero:create(u_id)
        self.unit = CreateUnit(self:getPlayer(), FourCC(u_id), -1525.2, -10740.1, 270.0)
        UI.a_panel:loadUnit(self.unit)
        UI.h_panel:loadUnit(self.unit)
        AbilityController:load()
        CastingController:load()
        SelectUnitForPlayerSingle(self.unit, self:getPlayer())
        SetHeroLevel(self.unit, 30,false)
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
        Hero:create('H000')
    end)
end