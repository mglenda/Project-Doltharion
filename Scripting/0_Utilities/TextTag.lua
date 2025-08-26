do
    TextTag = setmetatable({}, {})
    local tt = getmetatable(TextTag)
    tt.__index = tt

    function tt:defFontSize()
        return 0.02
    end

    function tt:create(params)
        local tag = CreateTextTag()
        local x,y = params.x,params.y
        if params.u then
            x,y = Utils:GetUnitXY(params.u)
            if params.os then x,y = Utils:move_xy(x,y,params.os,90.0*bj_DEGTORAD) end
        end
        SetTextTagText(tag, params.s,params.fs or self:defFontSize())
        SetTextTagColor(tag, params.r or 255.00, params.g or 76.00, params.b or 76.00, params.a or 0.00)
        SetTextTagPos(tag, x, y, 0)
        SetTextTagVelocity(tag, 0.0, 0.14)
        SetTextTagLifespanBJ(tag, params.ls or 1.00)
        SetTextTagFadepointBJ(tag, 0)
        SetTextTagPermanentBJ(tag, false) 
    end
end