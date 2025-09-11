do
    Druid = setmetatable({}, {})
    local a = getmetatable(Druid)
    a.__index = a

    local img = 'war3mapImported\\DruidArena.dds'
    local name = 'Druid'
    local order = 2

    local boss_type_id = FourCC('N006')

    function a:get_name()
        return name 
    end

    function a:get_img()
        return img
    end

    function a:create()
        --Mandatory
        self.r_arena = {
            Rect(-6432.0, 8928.0, -6240.0, 10272.0)
            ,Rect(-4640.0, 8928.0, -4448.0, 10272.0)
            ,Rect(-6304.0, 8416.0, -4576.0, 10784.0)
        }
        self.r_spawn = Rect(-5504.0, 8896.0, -5376.0, 9056.0)
        self.b_data = {
            {id = boss_type_id,spawn = Rect(-5504.0, 10080.0, -5376.0, 10240.0)}
        }
        self.sounds = {
            start = {
                sound = gg_snd_BM_Init
                ,text = "That does it, i will hunt you down !"
            }
            ,flee = {
                sound = gg_snd_BM_Defeat
                ,text = "Phr, hardly a challenge it would seem."
            }
            ,defeat = {
                sound = gg_snd_BM_Flee
                ,text = "It is the law of the wild, the strong take from the weak."
            }
            ,victory = {
                sound = gg_snd_BM_Victory
                ,text = "At last, the hunt ... is oveeerghh ..."
            }
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

    OnInit.global(function()
        Arena:register(Druid,order)
    end)
end