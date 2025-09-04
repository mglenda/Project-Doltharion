do
    Hero = setmetatable({}, {})
    local hero = getmetatable(Hero)
    hero.__index = hero

    function hero:create(hero_class)
        self.hero = hero_class:create()
        UI.a_panel:loadUnit(self:get())
        UI.h_panel:loadUnit(self:get())
        self.safe_zone = Rect(5792.0, -11776.0, 7424.0, -10336.0)
        CreateFogModifierRectBJ(true, Players:get_player(), FOG_OF_WAR_VISIBLE, self.safe_zone)
        AbilityController:load()
        SelectUnitForPlayerSingle(self:get(), Players:get_player())
        PanCameraToTimedForPlayer(Players:get_player(), GetUnitX(self:get()), GetUnitY(self:get()), 0.0)
    end

    function hero:move(x,y)
        x,y = x or GetPlayerStartLocationX(Players:get_player()),y or GetPlayerStartLocationY(Players:get_player())
        if IsUnitAliveBJ(self:get()) then
            Utils:set_unit_xy(self:get(),x,y)
        else
            ReviveHero(self:get(), x, y, false)
            SelectUnitForPlayerSingle(self:get(), Players:get_player())
        end
        SetUnitLifePercentBJ(self:get(), 100)
        PanCameraToTimedForPlayer(Players:get_player(), GetUnitX(Hero:get()), GetUnitY(Hero:get()), 0.0)
    end

    function hero:get()
        return self.hero:get_unit()
    end

    function hero:get_energy()
        if Utils:type(self.hero.get_energy) == 'function' then
            return self.hero:get_energy()
        end
        return nil
    end

    function hero:set_energy(amount)
        if Utils:type(self.hero.set_energy) == 'function' then
            self.hero:set_energy(amount)
        end
    end

    function hero:add_energy(amount)
        if Utils:type(self.hero.add_energy) == 'function' then
            self.hero:add_energy(amount)
        end
    end

    function hero:get_energy_ui()
        if Utils:type(self.hero.get_energy_ui) == 'function' then
            return self.hero:get_energy_ui()
        end
        return nil
    end

    function hero:has_energy()
        return self.hero.energy
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
        Hero:create(HeroMage)
    end)
end