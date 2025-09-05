do
    Camera = setmetatable({}, {})
    local cam = getmetatable(Camera)
    cam.__index = cam

    cam.num_plus = ConvertOsKeyType(107)
    cam.k_plus = ConvertOsKeyType(187)
    cam.num_minus = ConvertOsKeyType(109)
    cam.k_minus = ConvertOsKeyType(189)
    cam.zoom_trigger = CreateTrigger()
    cam.refresh_trigger = CreateTrigger()
    cam.max_distance = 6000.0
    cam.distance = 0.0
    cam.max_vanilla_distance = 2951.0

    function cam:zoom_in()
        Camera:add_distance(-100)
    end

    function cam:zoom_out()
        Camera:add_distance(100)
    end

    function cam:add_distance(x)
        self.distance = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)
        self.distance = (self.distance + x >= 0 and self.distance + x <= self.max_distance) and self.distance + x or self.distance
    end

    function cam:refresh()
        if self.distance > self.max_vanilla_distance and self.distance ~= GetCameraField(CAMERA_FIELD_TARGET_DISTANCE) then
            local far_z = self.distance + 4000.0
            SetCameraField(CAMERA_FIELD_TARGET_DISTANCE,self.distance, 0)
            SetCameraField(CAMERA_FIELD_FARZ, far_z, 0)
            SetTerrainFogEx(0, far_z, far_z, 0, 1.00, 1.00, 1.00)
        end
        -- print('zoffset: ' .. GetCameraField(CAMERA_FIELD_ZOFFSET))
        -- print('rotation: ' .. GetCameraField(CAMERA_FIELD_ROTATION))
        -- print('angle_of_attack: ' .. GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK))
        -- print('target_distance: ' .. GetCameraField(CAMERA_FIELD_TARGET_DISTANCE))
        -- print('roll: ' .. GetCameraField(CAMERA_FIELD_ROLL))
        -- print('field_of_view: ' .. GetCameraField(CAMERA_FIELD_FIELD_OF_VIEW))
        -- print('farz: ' .. GetCameraField(CAMERA_FIELD_FARZ))
        -- print('nearz: ' .. GetCameraField(CAMERA_FIELD_NEARZ))
        -- print('local_pitch: ' .. GetCameraField(CAMERA_FIELD_LOCAL_PITCH))
        -- print('local_yaw: ' .. GetCameraField(CAMERA_FIELD_LOCAL_YAW))
        -- print('local_roll: ' .. GetCameraField(CAMERA_FIELD_LOCAL_ROLL))
    end
    
    OnInit.final(function()
        Camera.distance = 4000
        Controller:registerKeyboardEvent(Camera.num_plus,Camera.zoom_in,'core_camera_zoom',Clique:ctrl())
        Controller:registerKeyboardEvent(Camera.k_plus,Camera.zoom_in,'core_camera_zoom',Clique:ctrl())
        Controller:registerKeyboardEvent(Camera.num_minus,Camera.zoom_out,'core_camera_zoom',Clique:ctrl())
        Controller:registerKeyboardEvent(Camera.k_minus,Camera.zoom_out,'core_camera_zoom',Clique:ctrl())
        TriggerRegisterTimerEventPeriodic(Camera.refresh_trigger,0.01)
        TriggerAddAction(Camera.refresh_trigger, function() Camera:refresh() end)
    end)
end