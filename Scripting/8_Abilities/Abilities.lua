do
    Abilities = setmetatable({}, {})
    local a = getmetatable(Abilities)
    a.__index = a

end