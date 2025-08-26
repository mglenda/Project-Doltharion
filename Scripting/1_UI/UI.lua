do
    local TOC_FILE_PATH = "war3mapImported\\ui_main.toc"

    UI = setmetatable({}, {})
    local ui = getmetatable(UI)
    ui.__index = ui

    local scale = 1.0

    function ui:getConst(def)
        if def == 'ab_border_def_width' then
            return 0.03 * scale
        elseif def == 'ab_sprite_def_scale' then
            return 0.45 * scale
        elseif def == 'screen_frame' then
            return BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        elseif def == 'scale' then 
            return scale 
        elseif def == 'max_x' then
            return 0.93
        elseif def == 'max_y' then
            return 0.6
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
        BuffPanel:create()
        UI.h_panel = UnitPanel:create(0)
        UI.t_panel = UnitPanel:create(1)
        UI.a_panel = AbilitiesPanel:create()
        UI.t_panel:hide()
        UI.h_panel:hide()
        UI.a_panel:hide()
        CastingBar:create()

        --Not Really Used
        WarbandJournal:create()
        WarbandJournal:hide()
        WarbandList:create()
        WarbandList:hide()
        MainMenu:create()
        MainMenu:hide()
        ------------------

        ArenaJournal:create()
        ArenaJournal:hide()
        DamageMeterPanel:create()
    end

    function ui:get_h_panel()
        return UI.h_panel:get()
    end

    function ui:hide_idle_panels()
        ArenaJournal:hide_book_button()
    end

    function ui:show_idle_panels()
        ArenaJournal:show_book_button()
    end

    function ui:rescale(s)
        scale = scale * s
        UI.a_panel:rescale()
        UI.t_panel:rescale(s)
        UI.h_panel:rescale(s)
        CastingBar:rescale(s)
        WarbandJournal:rescale(s)
        WarbandList:rescale(s)
        MainMenu:rescale(s)
        ArenaJournal:rescale(s)
        DamageMeterPanel:rescale(s)
        BuffPanel:rescale(s)
    end

    OnInit(function()
        --Hide Original UI
        BlzHideOriginFrames(true)
        BlzFrameSetVisible(BlzGetFrameByName("ConsoleUIBackdrop",0), false)
        BlzFrameSetScale(BlzGetFrameByName("ConsoleUI", 0), 0.001)
        BlzEnableUIAutoPosition(false)

        UI:create()
        UI:rescale(1.1)
        --Controller:registerKeyboardEvent(OSKEY_W,WarbandJournal.show,'wl_show',Clique:alt())
        --
    end)
end