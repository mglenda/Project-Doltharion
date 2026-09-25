do
    AnimMage = setmetatable({}, {})
    local as = getmetatable(AnimMage)
    as.__index = as

    local ut = FourCC('H000')

    function as:get_ut()
        return ut
    end

    function as:seq_spellcast()
        return {
            self.data['attack 1']
        }
    end

    function as:big_spellcast()
        return {
            self.data['spell channel']
        }
    end

    function as:seq_spellchannel()
        return {
            self.data['spell channel']
        }
    end

    function as:load()
        self.data = {
            ['stand'] = {0,5.033,true}
            ,['stand 3'] = {1,4.666,true}
            ,['walk'] = {2,0.933,true}
            ,['stand 2'] = {3,5.033,true}
            ,['attack 1'] = {4,1.5,false}
            ,['attack 2'] = {5,1.167,false}
            ,['spell cast'] = {6,1.5,false}
            ,['attack 3'] = {7,1.167,false}
            ,['spell channel'] = {8,1.633,true}
            ,['death'] = {9,3.0,false}
            ,['dissipate'] = {10,2.0,false}
            ,['spell throw'] = {11,1.634,false}
            ,['stand'] = {12,1.467,true}
        }
    end

    OnInit.map(function()
        AnimMage:load()
    end)
end