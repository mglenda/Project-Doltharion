do
    local TOC_FILE_PATH = "war3mapImported\\ui_main.toc"

    UI = setmetatable({}, {})
    local ui = getmetatable(UI)
    ui.__index = ui

    local scale = 1.0

    function ui:getConst(def)
        if def == 'ab_border_def_width' then
            return 0.03 * scale
        elseif def == 'screen_frame' then
            return BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        elseif def == 'scale' then 
            return scale 
        end
        return nil
    end

    function ui:loadTocFile()
        if not(BlzLoadTOCFile(TOC_FILE_PATH)) then
            print(TOC_FILE_PATH .. " import failed")
        end
    end

    function ui:create()
        UI:loadTocFile()
        UI.h_panel = UnitPanel:create(0)
        UI.t_panel = UnitPanel:create(1)
        UI.a_panel = AbilitiesPanel:create()
        UI.t_panel:hide()
        UI.h_panel:hide()
        UI.a_panel:hide()
        CastingBar:create()
        WarbandJournal:create()
        WarbandJournal:hide()
        WarbandList:create()
        WarbandList:hide()
    end

    function ui:rescale(s)
        scale = scale * s
        UI.a_panel:rescale()
        UI.t_panel:rescale(s)
        UI.h_panel:rescale(s)
        CastingBar:rescale(s)
        WarbandJournal:rescale(s)
        WarbandList:rescale(s)
    end

    OnInit(function()
        --Hide Original UI
        BlzHideOriginFrames(true)
        BlzFrameSetVisible(BlzGetFrameByName("ConsoleUIBackdrop",0), false)
        BlzFrameSetScale(BlzGetFrameByName("ConsoleUI", 0), 0.001)
        BlzEnableUIAutoPosition(false)

        UI:create()
        UI:rescale(1.1)
        Controller:registerKeyboardEvent(OSKEY_W,WarbandJournal.show,'wl_show',Clique:alt())
        --
    end)
end