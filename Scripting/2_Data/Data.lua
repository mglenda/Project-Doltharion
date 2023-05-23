do
    Data = setmetatable({}, {})
    local d = getmetatable(Data)
    d.__index = d

    local buffs = {
        ['blasted'] = {
            d = 5
            ,e_m = 'Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl'
            ,e_a = 'chest'
        }
    }

    function d:get_buff(b)
        return buffs[b]
    end
end