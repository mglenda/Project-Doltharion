do
    Data = setmetatable({}, {})
    local d = getmetatable(Data)
    d.__index = d

    --reserved u,s,bn,dur,per
    --is_d = true :: if it is negative debuff, not set or false if it is buff positive buff
    --d = duration :: number bigger than 0 to set buff duration, not set = infinite duration
    --prio = priority :: define what is priority of the buff by which it will be sorted for various actions, lower number = higher priority
    --e = effects_data :: table of effects which should be applied, each effect should have its own table containing m = model string path, a = attachment point, s = scale (optional)
    --es = effects_stack :: true each stack of buff applies effects, not set / false = effects will be applied only once per buff type, no matter how much stacks buff has
    --p = period :: defines period duration
    --h = hidden :: true buff won't be displayed on unit panel, not set / false it will be displayed on unit panel
    --func_p = period func :: function which happens on period end
    --func_q = quit func :: function which if returns true buff will expire
    --func_e = end func :: function which will always execute when buff expires
    --func_d = dispell func :: function which will execute if buff was dispelled
    local buffs = {
        ['blasted'] = {
            e = {
                {m = 'Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl',a = 'chest'}
                ,{m = 'Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl',a = 'right hand'}
                ,{m = 'Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl',a = 'left hand',s = 1.5}
            }
            ,d = 10
            ,p = 1
        }
    }

    function d:get_buff(b)
        return buffs[b]
    end
end