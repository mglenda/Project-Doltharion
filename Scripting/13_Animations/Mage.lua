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
            self.data['spell']
        }
    end

    function as:big_spellcast()
        return {
            self.data['spell cast']
            ,self.data['spell throw']
        }
    end

    function as:spell_combo_x_hits(hit_count)
        local animations = {
            self.data['attack 1']
            ,self.data['attack 2']
            ,self.data['attack 3']
            ,self.data['attack 4']
            ,self.data['attack 5']
            ,self.data['attack 6']
        }
        local tbl = {}
        for i=1,hit_count,1 do
            if i <= #animations then
                table.insert(tbl,animations[i])
            else
                table.insert(tbl,animations[GetRandomInt(1,#animations)])
            end
        end
        return tbl
    end

    function as:seq_spellchannel()
        return {
            self.data['spell']
            ,self.data['spell channel']
        }
    end

    function as:load()
        self.data = {
            ['stand'] = {0,6.667,true}
            ,['sprint'] = {1,0.625,true}
            ,['death'] = {2,1.959,false}
            ,['stand 2'] = {3,3.292,true}
            ,['spell'] = {6,0.959,false}
            ,['walk'] = {9,0.625,true}
            ,['attack 1'] = {12,0.625,false}
            ,['attack 2'] = {13,0.625,false}
            ,['attack 3'] = {14,0.625,false}
            ,['attack 4'] = {15,0.625,false}
            ,['attack 5'] = {16,0.625,false}
            ,['attack 6'] = {17,0.625,false}
            ,['spell channel'] = {18,0.959,true}
            ,['spell throw'] = {19,0.625,false}
            ,['spell cast'] = {20,1.792,false}
        }
    end

    OnInit.map(function()
        AnimMage:load()
    end)
end