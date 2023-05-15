do
    TextTag = setmetatable({}, {})
    local tt = getmetatable(TextTag)
    tt.__index = tt

    function tt:defFontSize()
        return 0.024
    end

    function tt:create(params)
        local tag = CreateTextTag()
        --[[if Utils:type(params.s) == 'string' 
        and (Utils:type(params.u) == 'unit' or (Utils:type(params.x) == 'number' and Utils:type(params.y) == 'number')) 
        and (not(params.b) or Utils:type(params.b) == 'number')
        and (not(params.a) or Utils:type(params.a) == 'number')
        and (not(params.g) or Utils:type(params.g) == 'number')
        and (not(params.r) or Utils:type(params.r) == 'number')
        and (not(params.fa) or Utils:type(params.fa) == 'number')
        and (not(params.ls) or Utils:type(params.ls) == 'number') 
        then]]--
            local x,y = params.x,params.y
            if params.u then
                x,y = Utils:GetUnitXY(params.u)
            end
            SetTextTagText(tag, params.s,params.fs or self:defFontSize())
            SetTextTagColor(tag, params.r or 255.00, params.g or 76.00, params.b or 76.00, params.a or 0.00)
            SetTextTagPos(tag, x, y, 0)
            SetTextTagVelocity(tag, 0.0, 0.14)
            SetTextTagLifespanBJ(tag, params.ls or 1.00)
            SetTextTagFadepointBJ(tag, 0)
            SetTextTagPermanentBJ(tag, false) 
        --[[else
            print('ParamError: TextTag:create')
            print('@s (string) passed: ' .. Utils:type(params.s))
            print('@u (unit) passed: ' .. Utils:type(params.u))
            print('@x (number) passed: ' .. Utils:type(params.x))
            print('@y (number) passed: ' .. Utils:type(params.y))
            print('@r (number) passed: ' .. Utils:type(params.r))
            print('@g (number) passed: ' .. Utils:type(params.g))
            print('@b (number) passed: ' .. Utils:type(params.b))
            print('@a (number) passed: ' .. Utils:type(params.a))
            print('@fs (number) passed: ' .. Utils:type(params.fs))
            print('@ls (number) passed: ' .. Utils:type(params.ls))
        end]]--
    end
end