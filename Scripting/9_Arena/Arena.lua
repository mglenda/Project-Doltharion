do
    Arena = setmetatable({}, {})
    local a = getmetatable(Arena)
    a.__index = a

    function a:register(arena)
        if Utils:type(self.arenas) ~= 'table' then self.arenas = {} end
        table.insert(self.arenas,arena:create())
    end

    function a:start(i)
        self.arenas[i]:start()
    end

    function a:stop(i)
        self.arenas[i].stop()
    end

    OnInit.final(function()
        Arena:register(ForestAmbush)
    end)
end