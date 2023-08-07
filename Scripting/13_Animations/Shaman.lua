do
    AnimShaman = setmetatable({}, {})
    local as = getmetatable(AnimShaman)
    as.__index = as

    local ut = FourCC('H001')

    function as:get_ut()
        return ut
    end

    function as:seq_attackslam()
        return {self.data['attack slam']}
    end

    function as:seq_attack()
        return {
            self.data['attack 1']
            ,self.data['attack 2']
            ,self.data['attack slam']
        }
    end

    function as:seq_spellchannel()
        return {
            self.data['spell']
            ,self.data['spell channel']
        }
    end

    function as:load()
        self.data = {
            ['walk alt'] = {0,1.334,true}
            ,['walk'] = {1,0.6,true}
            ,['stand'] = {2,3.0,true}
            ,['death'] = {3,1.666,false}
            ,['stand ready'] = {4,1.333,true}
            ,['stand victory'] = {5,2.0,true}
            ,['attack 1'] = {6,0.966,false}
            ,['attack 2'] = {8,0.766,false}
            ,['attack slam'] = {7,1.0,false}
            ,['spell'] = {9,0.76,false}
            ,['spell throw'] = {11,1.0,false}
            ,['spell slam'] = {12,1.0,false}
            ,['stand channel'] = {13,1.0,true}
            ,['spell channel'] = {14,1.0,true}
            ,['sprint'] = {15,0.533,true}
            ,['stand 2'] = {16,4.0,true}
            ,['dissipate'] = {18,2.0,false}
        }
    end

    OnInit.map(function()
        AnimShaman:load()
    end)
end