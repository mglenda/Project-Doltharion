do
    Beastmaster = setmetatable({}, {})
    local a = getmetatable(Beastmaster)
    a.__index = a

    local img = 'war3mapImported\\BeastmasterArena.dds'
    local name = 'Beastmaster'

    function a:get_name()
        return name 
    end

    function a:get_img()
        return img
    end

    function a:create()
        return self
    end

    function a:start()

    end

    function a:victory()

    end

    function a:begin()

    end

    function a:stop()

    end

    OnInit.main(function()
        Arena:register(Beastmaster)
    end)
end