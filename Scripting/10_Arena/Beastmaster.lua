do
    Beastmaster = setmetatable({}, {})
    local a = getmetatable(Beastmaster)
    a.__index = a

    local img = 'war3mapImported\\BeastmasterArena.dds'
    local name = 'Beastmaster'
    local order = 1

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
        self.r_spawn = Rect(-5504.0, 8896.0, -5376.0, 9056.0)
        self.b_data = {
            {id = FourCC('N006'),spawn = Rect(-5504.0, 10080.0, -5376.0, 10240.0)}
        }

        return self
    end

    function a:start()
        print('start')
    end

    function a:flee()
        print('flee')
    end

    function a:victory()
        print('victory')
    end

    function a:begin()
        print('begin')
    end

    OnInit.main(function()
        Arena:register(Beastmaster,order)
    end)
end