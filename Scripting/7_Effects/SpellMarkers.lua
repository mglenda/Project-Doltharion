do
    SpellMarker = setmetatable({}, {})
    local sm = getmetatable(SpellMarker)
    sm.__index = sm

    local types = {
        chaos = 'war3mapImported\\Spell Marker Chaos.mdx'
        ,corruption = 'war3mapImported\\Spell Marker Corruption.mdx'
        ,crimson = 'war3mapImported\\Spell Marker Crimson.mdx'
        ,gold = 'war3mapImported\\Spell Marker Gold.mdx'
        ,green = 'war3mapImported\\Spell Marker Green.mdx'
        ,pink = 'war3mapImported\\Spell Marker Pink.mdx'
        ,red = 'war3mapImported\\Spell Marker Red.mdx'
        ,teal = 'war3mapImported\\Spell Marker Teal.mdx'
    }
    local scale_aoe_ratio = 120

    --[[
        SpellMarker:create{
            type = 'chaos'
            ,x = 
            ,y = 
            ,aoe = 

            ,time = 
        }
    ]]--
    function sm:create(args)
        if types[args.type] then
            local this = {}
            setmetatable(this, sm)
            
            this.x = args.x
            this.y = args.y
            this.aoe = args.aoe
            
            if args.time then 
                this:_calc_scale_z()
                this.e = EffectAnimation:create_xyz{
                    x = this.x
                    ,y = this.y
                    ,model = types[args.type]
                    ,scale = this.scale
                    ,time = args.time
                    ,is_marker = true
                }
            else
                this.e = AddSpecialEffect(types[args.type], args.x, args.y)
                this:_reset()
            end
            
            return this
        end
        return nil
    end

    function sm:move(range,rad)
        local x = Utils:move_x(self.x, range, rad)
        local y = Utils:move_y(self.y, range, rad)

        self:set_xy(x,y)
    end

    function sm:set_aoe(aoe)
        self.aoe = aoe
        self._reset()
    end

    function sm:destroy()
        DestroyEffect(self.e)
    end
    
    function sm:set_xy(x,y)
        self.x = x
        self.y = y
        BlzSetSpecialEffectX(self.e, x)
        BlzSetSpecialEffectY(self.e, y)
        self:_reset_z()
    end

    function sm:set_x(x)
        self.x = x
        BlzSetSpecialEffectX(self.e, x)
        self:_reset_z()
    end

    function sm:set_y(y)
        self.y = y
        BlzSetSpecialEffectY(self.e, y)
        self:_reset_z()
    end

    function sm:_calc_scale_z()
        self.scale = self:_get_scale()
        self.z = self:_get_z()
    end

    function sm:_reset_z()
        self.z = self:_get_z()
        BlzSetSpecialEffectZ(self.e, self.z)
    end

    function sm:_reset_scale()
        self.scale = self:_get_scale()
        BlzSetSpecialEffectScale(self.e, self.scale)
    end

    function sm:_reset()
        self:_reset_scale()
        self:_reset_z()
    end

    function sm:_get_z()
        return (-18.88 * self.scale + 8.88) + Utils:get_point_z(self.x,self.y)
    end

    function sm:get_z(e)
        local scale = BlzGetSpecialEffectScale(e)
        local x = BlzGetLocalSpecialEffectX(e)
        local y = BlzGetLocalSpecialEffectY(e)
        return (-18.88 * scale + 8.88) + Utils:get_point_z(x,y)
    end

    function sm:_get_scale()
        return self.aoe / scale_aoe_ratio
    end
end