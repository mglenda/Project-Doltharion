do
    ArenaTemplate1 = setmetatable({}, {})
    local a = getmetatable(ArenaTemplate1)
    a.__index = a

    local img = 'war3mapImported\\BeastmasterArena.dds'
    local name = 'Beastmaster'
    local order = 2

    function a:get_name()
        return name 
    end

    function a:get_img()
        return img
    end

    function a:create()
        self.r_arena = {
            Rect(-6400.0, 8960.0, -4480.0, 10240.0)
            ,Rect(-6272.0, 10208.0, -4608.0, 10752.0)
            ,Rect(-6272.0, 8448.0, -4608.0, 8992.0)
        }
        return self
    end

    function a:start()
        
    end

    function a:flee()

    end

    function a:victory()
    end

    function a:begin()

    end

    OnInit.main(function()
        Arena:register(ArenaTemplate1,order)
    end)
end