do
    Controller = setmetatable({}, {})
    local c = getmetatable(Controller)
    c.__index = c

    local events = {}
    local m_keys = {0,1,2,3,4,5,6,7}

    function c:registerKeyboardEvent(keys,func,key,metaKeys)
        key = key or 'def'
        metaKeys = metaKeys or 0

        if Utils:type(func) ~= 'function' then
            print('Controller:registerKeyboardEvent @func required: function, passed:' .. Utils:type(func))
            return
        else
            local tbl = {
                trigger = CreateTrigger()
                ,key = key
            }
            if Utils:type(keys) == 'oskeytype' then
                if Utils:type(metaKeys) == 'table' then
                    for _,mk in ipairs(metaKeys) do
                        if Utils:table_contains(m_keys, mk) then
                            BlzTriggerRegisterPlayerKeyEvent(tbl.trigger, Players:get_player(), keys, mk, true)
                        else
                            print('Controller:registerKeyboardEvent @metaKeys required: values(0-7), passed:' .. Utils:type(mk))
                        end
                    end
                else
                    BlzTriggerRegisterPlayerKeyEvent(tbl.trigger, Players:get_player(), keys, metaKeys, true)
                end
            elseif Utils:type(keys) == 'table' then
                if Utils:type(metaKeys) == 'table' then
                    for _,k in ipairs(keys) do
                        if Utils:type(k) == 'oskeytype' then
                            for _,mk in ipairs(metaKeys) do
                                if Utils:table_contains(m_keys, mk) then
                                    BlzTriggerRegisterPlayerKeyEvent(tbl.trigger, Players:get_player(), k, mk, true)
                                else
                                    print('Controller:registerKeyboardEvent @metaKeys required: values(0-7), passed:' .. Utils:type(mk))
                                end
                            end
                        else
                            print('Controller:registerKeyboardEvent @keys required: oskeytype/table, passed:' .. Utils:type(k))
                        end
                    end
                else
                    for _,k in ipairs(keys) do
                        if Utils:type(k) == 'oskeytype' then
                            BlzTriggerRegisterPlayerKeyEvent(tbl.trigger, Players:get_player(), k, metaKeys, true)
                        else
                            print('Controller:registerKeyboardEvent @keys required: oskeytype/table, passed:' .. Utils:type(k))
                        end
                    end
                end
            else
                print('Controller:registerKeyboardEvent @keys required: oskeytype/table, passed:' .. Utils:type(keys))
                return
            end
            TriggerAddAction(tbl.trigger, func)
            table.insert(events,tbl)
        end
    end

    function c:registerFrameMouseEvent(frames,events,func,key)
        print(Utils:type(frames))
        print(Utils:type(events))
    end

    function c:registerMouseEvent(events,func,key)

    end

    function c:destroy(key)
        if key then
            for i=#events,1,-1 do
                if events[i].key == key then
                    if events[i].trigger then DestroyTrigger(events[i].trigger) end
                    table.remove(events,i)
                end
            end
        end
    end
end