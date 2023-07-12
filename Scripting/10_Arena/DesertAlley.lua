do
    DesertAlley = setmetatable({}, {})
    local da = getmetatable(DesertAlley)
    da.__index = da

    local img = 'war3mapImported\\DesertAlley.dds'
    local name = 'Desert Alley'

    function da:get_name()
        return name 
    end

    function da:get_img()
        return img
    end

    function da:create()
        return self
    end

    function da:start()

    end

    function da:victory()

    end

    function da:begin()

    end

    function da:stop()

    end

    OnInit.main(function()
        Arena:register(DesertAlley)
    end)
end