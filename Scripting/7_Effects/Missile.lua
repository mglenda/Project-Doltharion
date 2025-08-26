do
    Missile = setmetatable({}, {})
    local m = getmetatable(Missile)
    m.__index = m

    function m:create(args)
        local this = {}
        setmetatable(this, m)

        --Mandatory Params
        this.e_model = args.e_model
        this.spawn_x = args.spawn_x
        this.spawn_y = args.spawn_y
        this.spawn_z = args.spawn_z
        --Either Target Unit
        this.target = args.target
        --Or Target X,Y,Z Coords
        this.t_is_unit = Utils:type(this.target) == 'unit'
        if this.t_is_unit then
            this.target_x = GetUnitX(this.target)
            this.target_y = GetUnitY(this.target)
            this.target_z = Utils:get_unit_impact_z(this.target)
        else
            this.target_x = args.target_x
            this.target_y = args.target_y
            this.target_z = args.target_z
        end
        
        --Optional
        this.a_phase = args.a_phase or math.random() * 10 * math.pi
        this.w_speed = args.w_speed or 0.08 + math.random() * 0.08
        this.w_radius = args.w_radius or 20 + math.random() * 10
        this.e_scale = args.e_scale or 1.0
        this.speed = args.speed or 10.0

        this.dist_traveled = 0
        this.x = this.spawn_x
        this.y = this.spawn_y
        this.z = this.spawn_z

        this.missile = AddSpecialEffect(this.e_model, this.x, this.y)
        BlzSetSpecialEffectScale(this.missile, this.e_scale)
        BlzSetSpecialEffectZ(this.missile, this.spawn_z)
        BlzSetSpecialEffectYaw(this.missile, Utils:get_rad_between_points(this.x,this.y,this.target_x,this.target_y))

        return this
    end

    function m:get_distance_from_traget()
        return Utils:get_distance(self.x,self.y,self.target_x,self.target_y)
    end

    function m:destroy()
        DestroyEffect(self.missile)
    end

    function m:move()
        if self.t_is_unit then
            self.target_x = GetUnitX(self.target)
            self.target_y = GetUnitY(self.target)
            self.target_z = Utils:get_unit_impact_z(self.target)
        end

        --X,Y movement
        local r = Utils:get_rad_between_points(self.x,self.y,self.target_x,self.target_y)
        self.x = Utils:move_x(self.x, self.speed, r)
        self.y = Utils:move_y(self.y, self.speed, r)
        self.dist_traveled = self.dist_traveled + self.speed
        local dist_total = self:get_distance_from_traget() + self.dist_traveled

        -- rotation swirl
        self.a_phase = self.a_phase + self.w_speed
        local x = self.x + Cos(self.a_phase) * self.w_radius
        local y = self.y + Sin(self.a_phase) * self.w_radius

        -- Z interpolation
        local progress = math.min(self.dist_traveled / dist_total, 1.0)
        self.z = self.spawn_z + (self.target_z - self.spawn_z) * progress
        
        -- set effect coords
        BlzSetSpecialEffectX(self.missile, x)
        BlzSetSpecialEffectY(self.missile, y)
        BlzSetSpecialEffectZ(self.missile, self.z)
        BlzSetSpecialEffectYaw(self.missile, r)
    end
end