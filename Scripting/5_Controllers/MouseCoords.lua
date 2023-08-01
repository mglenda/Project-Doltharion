do
    MouseCoords = setmetatable({}, {})
    local mc = getmetatable(MouseCoords)
    mc.__index = mc

    local trg = CreateTrigger()
    local x,y

    function mc:store()
        x,y = BlzGetTriggerPlayerMouseX(),BlzGetTriggerPlayerMouseY()
    end

    function mc:get_x()
        return x
    end

    function mc:get_y()
        return y
    end

    function mc:get_xy()
        return self:get_x(),self:get_y()
    end

    OnInit.map(function()
        TriggerRegisterPlayerMouseEventBJ(trg, Players:get_player(), bj_MOUSEEVENTTYPE_MOVE)
        TriggerAddAction(trg, MouseCoords.store)
    end)
end