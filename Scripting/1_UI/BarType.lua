do
    BarType = setmetatable({}, {})
    local bt = getmetatable(BarType)
    bt.__index = bt

    function bt:blue()
        return {
            t = 'war3mapImported\\DBM_BarFill_Blue.dds'
            ,f = BlzConvertColor(255, 255, 255, 255)
        }
    end

    function bt:brown()
        return {
            t = 'war3mapImported\\DBM_BarFill_Brown.dds'
            ,f = BlzConvertColor(255, 255, 255, 255)
        }
    end

    function bt:gray()
        return {
            t = 'war3mapImported\\DBM_BarFill_Gray.dds'
            ,f = BlzConvertColor(255, 21, 32, 212)
        }
    end

    function bt:green()
        return {
            t = 'war3mapImported\\DBM_BarFill_Green.dds'
            ,f = BlzConvertColor(255, 255, 255, 255)
        }
    end

    function bt:pink()
        return {
            t = 'war3mapImported\\DBM_BarFill_Pink.dds'
            ,f = BlzConvertColor(255, 255, 255, 255)
        }
    end

    function bt:red()
        return {
            t = 'war3mapImported\\DBM_BarFill_Red.dds'
            ,f = BlzConvertColor(255, 255, 255, 255)
        }
    end

    function bt:yellow()
        return {
            t = 'war3mapImported\\DBM_BarFill_Yellow.dds'
            ,f = BlzConvertColor(255, 21, 162, 32)
        }
    end

    function bt:orange()
        return {
            t = 'war3mapImported\\DBM_BarFill_Orange.dds'
            ,f = BlzConvertColor(255, 255, 255, 255)
        }
    end

    function bt:darkgreen()
        return {
            t = 'war3mapImported\\DBM_BarFill_DarkGreen.dds'
            ,f = BlzConvertColor(255, 255, 255, 255)
        }
    end

    function bt:lightblue()
        return {
            t = 'war3mapImported\\DBM_BarFill_LightBlue.dds'
            ,f = BlzConvertColor(255, 110, 84, 4)
        }
    end

    function bt:gold()
        return {
            t = 'war3mapImported\\DBM_BarFill_Gold.dds'
            ,f = BlzConvertColor(255, 100, 100, 100)
        }
    end

    function bt:shadow()
        return {
            t = 'war3mapImported\\DBM_BarFill_Shadow.dds'
            ,f = BlzConvertColor(255, 255, 255, 255)
        }
    end
end