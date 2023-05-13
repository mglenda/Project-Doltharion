gg_trg_Test = nil
function InitGlobals()
end

do
    local funcs = {}
    
    function onInit(code)
        if type(code) == "function" then
            table.insert(funcs, code)
        end
    end
    
    local old = InitBlizzard
    function InitBlizzard()
        old()
        
        for i = 1, #funcs do
            funcs[i]()
        end
        
        funcs = nil
    end
end
do
    MAIN_UI = nil
    SCREEN_FRAME = nil
    ABILITY_BORDER_DEFAULT_WIDTH = 0.03
    TOC_FILE_PATH = "war3mapImported\\ui_main.toc"

    UI = setmetatable({}, {})
    local ui = getmetatable(UI)
    ui.__index = ui

    function ui:loadTocFile()
        if not(BlzLoadTOCFile(TOC_FILE_PATH)) then
            print(TOC_FILE_PATH .. " import failed")
        end
    end

    function ui:create()
        local this = {}
        setmetatable(this, ui)

        this:loadTocFile()
        this.h_panel = UnitPanel:create(0)
        this.t_panel = UnitPanel:create(1)
        this.t_panel:hide()
        return this
    end

    onInit(function()
        --Hide Original UI
        BlzHideOriginFrames(true)
        BlzFrameSetVisible(BlzGetFrameByName("ConsoleUIBackdrop",0), false)
        BlzFrameSetScale(BlzGetFrameByName("ConsoleUI", 0), 0.001)
        BlzEnableUIAutoPosition(false)
        SCREEN_FRAME = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)

        MAIN_UI = UI:create()
        print(MAIN_UI.h_panel.main)
        print(MAIN_UI.t_panel.main)
        Cheat('iseedeadpeople')
        --
    end)
end

do
    UnitPanel = setmetatable({}, {})
    local up = getmetatable(UnitPanel)
    up.__index = up

    function up:hide()
        if BlzFrameIsVisible(self.main) then
            BlzFrameSetVisible(self.main, false)
        end
    end

    function up:show()
        if not(BlzFrameIsVisible(self.main)) then
            BlzFrameSetVisible(self.main, true)
        end
    end

    -- unit panel constructor
    -- @param f_id parameter 0 for player 1 for target
    function up:create(f_id)
        local this = {}
        setmetatable(this, up)

        local x,y = f_id == 0 and 0.4 - (2 * ABILITY_BORDER_DEFAULT_WIDTH) or 0.4 + (2 * ABILITY_BORDER_DEFAULT_WIDTH),0.0
        local mainFrame = BlzCreateSimpleFrame('Details_Frame', SCREEN_FRAME, f_id)
        local barFrame = BlzCreateSimpleFrame('Details_BarFrame', mainFrame, f_id)
        local bar = BlzCreateSimpleFrame('Details_Bar', barFrame, f_id)
        local barName = BlzCreateSimpleFrame('Details_Bar_Name', bar, f_id)
        local barHP = BlzCreateSimpleFrame('Details_Bar_HP', bar, f_id)
        local barReg = BlzCreateSimpleFrame('Details_Bar_HPReg', bar, f_id)
        local unitIcon = BlzCreateSimpleFrame('Details_UnitIcon', barFrame, f_id)

        this.main = mainFrame
        
        local tbl = {
            mainFrame = mainFrame
            ,barFrame = barFrame
            ,bar = bar
            ,unitName = barName
            ,unitHP = barHP
            ,unitReg = barReg
            ,mainTexture = BlzGetFrameByName('Details_Texture', f_id)
            ,barFrameTexture = BlzGetFrameByName('Details_BarTexture', f_id)
            ,unitNameText = BlzGetFrameByName('Details_Bar_Name_Text', f_id)
            ,unitHPText = BlzGetFrameByName('Details_Bar_HP_Text', f_id)
            ,unitRegText = BlzGetFrameByName('Details_Bar_HPReg_Text', f_id)
            ,unitIcon = unitIcon
            ,unitIconTexture = BlzGetFrameByName('Details_UnitIconTexture', f_id)
        }
    
        BlzFrameSetPoint(barFrame, FRAMEPOINT_BOTTOM, mainFrame, FRAMEPOINT_TOP, 0, 0)
        BlzFrameSetPoint(unitIcon, FRAMEPOINT_LEFT, barFrame, FRAMEPOINT_LEFT, 0, 0)
        BlzFrameSetPoint(bar, FRAMEPOINT_LEFT, unitIcon, FRAMEPOINT_RIGHT, 0, 0)
        BlzFrameSetPoint(barName, FRAMEPOINT_LEFT, bar, FRAMEPOINT_LEFT, 0, 0)
        BlzFrameSetPoint(barHP, FRAMEPOINT_BOTTOMRIGHT, bar, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
        BlzFrameSetPoint(barReg, FRAMEPOINT_TOPRIGHT, bar, FRAMEPOINT_TOPRIGHT, 0, 0)
    
        BlzFrameSetAbsPoint(mainFrame, FRAMEPOINT_BOTTOMRIGHT, x, y)
    
        return this
    end
end
function CreateUnitsForPlayer0()
local p = Player(0)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("hfoo"), -1208.6, -10730.0, 351.397, FourCC("hfoo"))
end

function CreatePlayerBuildings()
end

function CreatePlayerUnits()
CreateUnitsForPlayer0()
end

function CreateAllUnits()
CreatePlayerBuildings()
CreatePlayerUnits()
end

function Trig_Test_Actions()
    DisplayTextToForce(GetPlayersAll(), BlzGetUnitStringField(GetTriggerUnit(), ConvertUnitStringField('uico')))
end

function InitTrig_Test()
gg_trg_Test = CreateTrigger()
TriggerAddAction(gg_trg_Test, Trig_Test_Actions)
end

function InitCustomTriggers()
InitTrig_Test()
end

function InitCustomPlayerSlots()
SetPlayerStartLocation(Player(0), 0)
ForcePlayerStartLocation(Player(0), 0)
SetPlayerColor(Player(0), ConvertPlayerColor(0))
SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
SetPlayerRaceSelectable(Player(0), true)
SetPlayerController(Player(0), MAP_CONTROL_COMPUTER)
SetPlayerStartLocation(Player(1), 1)
ForcePlayerStartLocation(Player(1), 1)
SetPlayerColor(Player(1), ConvertPlayerColor(1))
SetPlayerRacePreference(Player(1), RACE_PREF_ORC)
SetPlayerRaceSelectable(Player(1), true)
SetPlayerController(Player(1), MAP_CONTROL_USER)
end

function InitCustomTeams()
SetPlayerTeam(Player(0), 0)
SetPlayerState(Player(0), PLAYER_STATE_ALLIED_VICTORY, 1)
SetPlayerTeam(Player(1), 1)
SetPlayerState(Player(1), PLAYER_STATE_ALLIED_VICTORY, 1)
end

function main()
SetCameraBounds(-7424.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -11776.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 7424.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 11264.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -7424.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 11264.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 7424.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -11776.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
NewSoundEnvironment("Default")
SetAmbientDaySound("LordaeronSummerDay")
SetAmbientNightSound("LordaeronSummerNight")
SetMapMusic("Music", true, 0)
CreateAllUnits()
InitBlizzard()
InitGlobals()
InitCustomTriggers()
end

function config()
SetMapName("TRIGSTR_001")
SetMapDescription("TRIGSTR_003")
SetPlayers(2)
SetTeams(2)
SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
DefineStartLocation(0, -1024.0, -11136.0)
DefineStartLocation(1, -832.0, -10944.0)
InitCustomPlayerSlots()
InitCustomTeams()
end

