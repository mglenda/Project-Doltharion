do
    MouseCoords = setmetatable({}, {})
    local mc = getmetatable(MouseCoords)
    mc.__index = mc

    local trg = CreateTrigger()
    local x,y,e

    function mc:store()
        x,y = BlzGetTriggerPlayerMouseX(),BlzGetTriggerPlayerMouseY()
        if e then 
            BlzSetSpecialEffectX(e, x)
            BlzSetSpecialEffectY(e, y)
            BlzSetSpecialEffectZ(e, Utils:get_point_z(x,y))
        end
    end

    function mc:get_x()
        return x
    end

    function mc:get_y()
        return y
    end

    function mc:set_effect(em,s)
        e = AddSpecialEffect(em, x, y)
        BlzSetSpecialEffectScale(e, s)
    end

    function mc:clear_effect()
        if Utils:type(e) == 'effect' then
            DestroyEffect(e)
            e = nil
        end
    end

    function mc:get_xy()
        return self:get_x(),self:get_y()
    end

    OnInit.map(function()
        TriggerRegisterPlayerMouseEventBJ(trg, Players:get_player(), bj_MOUSEEVENTTYPE_MOVE)
        TriggerAddAction(trg, MouseCoords.store)
    end)
end