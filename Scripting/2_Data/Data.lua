do
    Data = setmetatable({}, {})
    local d = getmetatable(Data)
    d.__index = d

    local stats = {}

    OnInit.map(function()
        stats['resist'] = Resistance
    end)

    function d:get_stat_class(sn)
        return stats[sn]
    end
    --reserved u,s,bn,dur,per
    --is_d = isdebuff :: true if it is negative debuff, not set or false if it is positive buff
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
    --st = stats :: table containing all stats modified by buff, id of element should be name of stat to be modified, value of 
                  --element should be table containing: 
                  --value at 1st position 
                  --true/false at 2nd position to define wether effect stacks or no where true means it does stack and false/nil/undefined means it does not
                  --Example: st = {['resist'] = {10,true}} = means this buff incrase resistance of unit by 10 per stack
                  --Example: st = {['resist'] = {5}}  = means this buff incrase resistance of unit by 5, does not stack
                  --Example: st = {['resist'] = {8,false}}  = means this buff incrase resistance of unit by 8, does not stack
        -- Stat_List ::
            -- 'resist' = Resistance

    local buffs = {
        ['blasted'] = {
            e = {
                {m = 'Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl',a = 'chest'}
            }
            ,d = 5
            ,p = 0.5
            ,func_p = function(bt) 
                bt.st['resist'][1] = bt.st['resist'][1] + 5               
                Resistance:recalculate(bt.u)
            end
            ,st = {
                ['resist'] = {5,true}
            }
        }
    }

    function d:get_buff(b)
        return buffs[b]
    end
end