do
    Druid = setmetatable({}, {})
    local a = getmetatable(Druid)
    a.__index = a

    local img = 'war3mapImported\\DruidArena.dds'
    local name = 'Druid'
    local order = 2

    local boss_type_id = FourCC('N007')

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
                sound = gg_snd_DU_Init
                ,text = "Nature seeks balance, in all things."
            }
            ,flee = {
                sound = gg_snd_DU_Flee
                ,text = "A single thought is worth many actions."
            }
            ,defeat = {
                sound = gg_snd_DU_Defeat
                ,text = "I release you from this fate. May you finally find your peace, in death."
            }
            ,victory = {
                sound = gg_snd_DU_Victory
                ,text = "We serve the land ... arghhhh ..."
            }
            ,enroot = {
                sound = gg_snd_DU_Enroot
                ,text = "Nature is resilient."
            }
            ,starfall = {
                sound = gg_snd_DU_Starfall
                ,text = "Stand strong ! Only a bit longer."
            }
            ,bearform = {
                sound = gg_snd_DU_Bearform
                ,text = "Raaaaaargh ... !!!"
            }
            ,spirits = {
                sound = gg_snd_DU_Spirits
                ,text = "Urgh, i am under assult, assist me !"
            }
        }

        return self
    end

    function a:start()
        self.boss = ArenaUtils:get_boss()
    end

    function a:begin()
        Units:freeze(self.boss)
    end

    OnInit.global(function()
        Arena:register(Druid,order)
    end)
end