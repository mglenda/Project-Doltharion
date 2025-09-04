do
    ObjectUtils = setmetatable({}, {})
    local mt = getmetatable(ObjectUtils)
    mt.__index = mt

    local ab_codes = {}

    --[[
        ObjectUtils:get_unit_abilities_with_priority(u)
    ]]--
    function mt:get_unit_abilities_with_priority(u)
        local list = {}
        if u then
            for _,a_code in ipairs(ab_codes) do
                if GetUnitAbilityLevel(u, FourCC(a_code)) > 0 and a_code ~= 'Aatk' then
                    table.insert(list,{a_code = a_code,p = BlzGetAbilityIntegerField(BlzGetUnitAbility(u, FourCC(a_code)), ABILITY_IF_TARGET_ATTACHMENTS)})
                end
            end
            
            table.sort(list, function (k1, k2) return k1.p < k2.p end)
            for i,_ in ipairs(list) do
                list[i] = list[i].a_code
            end
        end
        return list
    end

    --[[
        ObjectUtils:get_unit_ability_codes{
            unit = my_unit
            ,no_attack = true/false
        }
    ]]--
    function mt:get_unit_ability_codes(args)
        local list = {}
        local u = args.unit
        if u then 
            for _,a_code in ipairs(ab_codes) do
                if GetUnitAbilityLevel(u, FourCC(a_code)) > 0 and (not(args.no_attack) or a_code ~= 'Aatk') then
                    table.insert(list,a_code)
                end
            end
        end
        return list
    end

    function mt:loadAbilities()
        local chars_first,chars_rest = {'A'},{}

        for i=48,57 do
            table.insert(chars_rest,string.char(i))
        end
        for _,c1 in ipairs(chars_first) do
            for _,c2 in ipairs(chars_rest) do
                for _,c3 in ipairs(chars_rest) do
                    for _,c4 in ipairs(chars_rest) do
                        table.insert(ab_codes,c1 .. c2 .. c3 .. c4)
                    end
                end
            end
        end
        table.insert(ab_codes,'Aatk')
    end
    
    OnInit.map(function()
        ObjectUtils:loadAbilities()
    end)
end