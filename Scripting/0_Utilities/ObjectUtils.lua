do
    ObjectUtils = setmetatable({}, {})
    local mt = getmetatable(ObjectUtils)
    mt.__index = mt

    local ab_codes = {}

    function mt:getUnitAbilities(u,noAatk)
        local list = {}
        for _,ab_code in ipairs(ab_codes) do
            if GetUnitAbilityLevel(u, FourCC(ab_code)) > 0 and (not(noAatk) or ab_code ~= 'Aatk') then
                table.insert(list,{ac = ab_code,p = BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, FourCC(ab_code)), ABILITY_ILF_MANA_COST, 0)})
            end
        end
        table.sort(list, function (k1, k2) return k1.p < k2.p end)
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