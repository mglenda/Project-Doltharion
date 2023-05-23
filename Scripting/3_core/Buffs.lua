do
    Buffs = setmetatable({}, {})
    local b = getmetatable(Buffs)
    b.__index = b

    local buffs = {}

    function b:apply(c,t,n,data)
        local this = {}
        setmetatable(this, b)

        if Utils:type(buffs[t]) ~= 'table' then buffs[t] = {} end

        table.insert(buffs[t],this)
        print(#buffs[t])
    end
end