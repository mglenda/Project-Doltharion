do
    HeroMage = setmetatable({}, {})
    local h = getmetatable(HeroMage)
    h.__index = h

    local u_id = FourCC('H000')

    function h:create()
        local this = {}
        setmetatable(this, h)

        this.unit = CreateUnit(Players:get_player(), u_id, GetPlayerStartLocationX(Players:get_player()),GetPlayerStartLocationY(Players:get_player()), 90.0)
        
        this.energy = 0
        this.max_energy = 100

        Abilities:add_silence{
            unit = this.unit
            ,s_key = 'overheat'
            ,a_code = CatalyticIncineration:get_a_code()
        }

        return this
    end

    function h:get_energy_ui()
        local energy_text = tostring(math.floor(self.energy)) .. '/' .. tostring(math.floor(self.max_energy))
        local energy_bar_path = 'war3mapImported\\DBM_BarFill_Pink.dds'
        local energy_name = 'Overheat'
        local energy_value = (self.energy / self.max_energy) * 100

        return {
            energy_name = energy_name
            ,energy_text = energy_text
            ,energy_bar_path = energy_bar_path
            ,energy_value = energy_value
        }
    end

    function h:get_energy()
        return self.energy
    end

    function h:set_energy(amount)
        if amount >= self.max_energy then
            Abilities:clear_silence{
                unit = self.unit
                ,s_key = 'overheat'
            }
            Abilities:enable_highlight(self.unit,CatalyticIncineration:get_a_code())
        elseif not(Abilities:silence_with_key_exists(self.unit,'overheat')) then
            Abilities:add_silence{
                unit = self.unit
                ,s_key = 'overheat'
                ,a_code = CatalyticIncineration:get_a_code()
            }
            Abilities:disable_highlight(self.unit,CatalyticIncineration:get_a_code())
        end
        self.energy = amount
    end

    function h:add_energy(amount)
        if self.energy + amount >= self.max_energy then
            self:set_energy(self.max_energy)
        elseif self.energy + amount <= 0 then
            self:set_energy(0)
        else
            self:set_energy(self.energy + amount)
        end
    end

    function h:get_unit()
        return self.unit
    end
end