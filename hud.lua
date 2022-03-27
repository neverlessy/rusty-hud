---@diagnostic disable: undefined-global, lowercase-global, redundant-parameter

-- Подключение библиотек
local m = require 'mimgui'
local e = require 'samp.events'
local enc = require 'encoding'
local mem = require 'memory'
local fa = require 'fAwesome5'


script_name('Unknowns Hud')
script_authors('Moon Glance', 'neverlessy')
script_version('1.0.0')
script_version_number(2200)
script_description('All rights reserved. © Moon Glance 2022')

--  Объявление переменных для удобства кода согласно moongl.ru/coderules
local new, v2, v4, cupoX, cupoY, chatMessage, flags = m.new, m.ImVec2, m.ImVec4, m.SetCursorPosX, m.SetCursorPosY, sampAddChatMessage, m.WindowFlags

-- Объявление других переменных
enc.default = 'CP1251'
local u8 = enc.UTF8
local tag = '{8bdee4}[UHUD]{b7b7b7} '
local uhud, settingsMenu = new.bool(), new.bool()
local settingsKillListBool, settingsListColoredNick, settingsWeaponSlots = new.bool(true), new.bool(), new.bool(true)
local sliderSlotsCount = new.int(4)
local userScreenX, userScreenY = getScreenResolution()
local killlist, weapons, weaponSlots = {}, {}, {0, 6, 0, 35}
local menuType = {true, false, false, false}
local killlistAlign = {true, false, false}

function main()
    while not isSampAvailable() do wait(0) end
    sampAddChatMessage(tag..'Скрипт активирован', -1)
    settingsMenu[0] = not settingsMenu[0]
    while true do wait(0)
        if settingsKillListBool[0] then
            uhud[0] = true
        else
            uhud[0] = false
        end
    end
end

function e.onPlayerDeathNotification(killerId, killedId, reason)
    if select(1, sampGetCharHandleBySampPlayerId(killerId)) or killerId == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) or killedId == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
        colorKiller, colorDead = sampGetPlayerColor(killerId), sampGetPlayerColor(killedId)
        if #killlist == 5 then
            for i = 1, 4 do
                killlist[i] = killlist[i + 1]
            end
            table.remove(killlist, 5)
            table.insert(killlist, {sampGetPlayerNickname(killerId), sampGetPlayerNickname(killedId), reason, colorKiller, colorDead})
        else
            table.insert(killlist, {sampGetPlayerNickname(killerId), sampGetPlayerNickname(killedId), reason, colorKiller, colorDead})
        end
    end
    if settingsKillListBool[0] then
        return false
    end
end

local settingsMenuFrame = m.OnFrame(
    function() return settingsMenu[0] end,
    function(player)
        m.PushStyleColor(m.Col.WindowBg, v4(0.07, 0.07, 0.07, 1.00))
        m.SetNextWindowPos(v2(400, 550), m.Cond.FirstUseEver, v2(0.5, 0.5))
        m.SetNextWindowSize(v2(750, 400), m.Cond.FirstUseEver)
        m.Begin("settings Window", settingsMenu, flags.NoResize + flags.NoCollapse + flags.NoScrollbar + flags.NoTitleBar)
            m.BeginChild('#MenuBar', v2(200, 390), false)
                if m.ButtonActivated(menuType[1], u8"О скрипте", v2(200, 50), cupoX(0)) then
                    switchMenu(1)
                end
                if m.ButtonActivated(menuType[2], u8"Интерфейс игрока", v2(200, 50), cupoX(0)) then
                    switchMenu(2)
                end
                if m.Button(u8"Закрыть", v2(200, 50), cupoX(0), cupoY(340)) then
                    settingsMenu[0] = false
                end
            m.EndChild() m.SameLine()
            m.BeginChild('#Content', v2(535, 390), false)
                if menuType[2] then
                    m.Checkbox(u8" Включение килллиста", settingsKillListBool)
                    if settingsKillListBool[0] then
                        m.Text(u8"Выравнивание", cupoX(25))
                        if m.ButtonActivated(killlistAlign[1], u8"Слева", v2(150,30), cupoX(25)) then
                            switchKlistAlign(1)
                        end m.SameLine()
                        if m.ButtonActivated(killlistAlign[2], u8"По центру", v2(150,30)) then
                            switchKlistAlign(2)
                        end m.SameLine() 
                        if m.ButtonActivated(killlistAlign[3], u8"Справа", v2(150,30)) then
                            switchKlistAlign(3)
                        end
                        m.Checkbox(u8" Цветные ники", settingsListColoredNick, cupoX(25))
                    end
                    m.Checkbox(u8" Слоты оружия", settingsWeaponSlots)
                    if settingsWeaponSlots[0] then
                        m.SliderInt(u8"Количество слотов", sliderSlotsCount, 1, 4, cupoX(25))
                        for i = 1, sliderSlotsCount[0] do
                            local name
                            if weaponSlots[i] == 0 then
                                name = u8'Пустой слот'
                            else
                                name = getWeaponNameById(weaponSlots[i])
                            end
                            if i == 1 then
                                if m.Button(u8""..name, v2(112,30), cupoX(25)) then
                                    m.OpenPopup("selectSlot"..i)
                                end m.SameLine()
                            elseif i == 2 then
                                if m.Button(u8""..name, v2(112,30)) then
                                    m.OpenPopup("selectSlot"..i)
                                end m.SameLine()
                            elseif i == 3 then
                                if m.Button(u8""..name, v2(112,30)) then
                                    m.OpenPopup("selectSlot"..i)
                                end m.SameLine()
                            elseif i == 4 then
                                if m.Button(u8""..name, v2(112,30)) then
                                    m.OpenPopup("selectSlot"..i)
                                end
                            end
                        end
                        for i = 1, sliderSlotsCount[0] do
                            if m.BeginPopup("selectSlot"..i) then
                                    m.BeginChild('#Popip'..i, v2(200, 300), false, flags.NoScrollbar)
                                        for v = 1, 46 do
                                            if v ~= 19 and v ~= 20 and v ~= 21 then
                                                if m.Button(""..getWeaponNameById(v)..' ('..v..')', v2(200,30)) then
                                                    m.CloseCurrentPopup()
                                                end
                                            end
                                        end
                                    m.EndChild()
                                m.EndPopup()
                            end
                        end
                    end
                end
            m.EndChild()
        m.End()
        m.GetIO().MouseDrawCursor = 1
        m.PopStyleColor(1)
        end
    )
    

local hudFrame = m.OnFrame(
    function() return uhud[0] end,
    function(player)
        m.PushStyleColor(m.Col.WindowBg, v4(0.07, 0.07, 0.07, 0.50))
        m.PushStyleColor(m.Col.Border, v4(0.25, 0.25, 0.26, 1.00))
        m.SetNextWindowPos(v2(1400, 300), m.Cond.FirstUseEver)
        m.SetNextWindowSize(v2(350, 250), m.Cond.Always)
            m.Begin("uhud", uhud, flags.NoResize + flags.NoCollapse + flags.NoScrollbar + flags.NoTitleBar + flags.NoBackground + flags.NoMouseInputs + flags.NoMove)
                m.BeginChild('a', v2(340, 240), false)
                    for i = 1, #killlist do
                        if killlist[i] ~= nil then
                            m.PushStyleVarFloat(m.StyleVar.FrameRounding, 0)
                            if killlist[i][1] ~= sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
                                m.PushStyleColor(m.Col.Border, v4(0.25, 0.25, 0.26, 1.00))
                            elseif killlist[i][1] == sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
                                m.PushStyleColor(m.Col.Border, v4(0.01, 0.41, 0.11, 1.00))
                            end
                            if killlist[i][2] == sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
                                m.PushStyleColor(m.Col.Border, v4(0.41, 0.01, 0.11, 1.00))
                            end
                                m.PushStyleColor(m.Col.ChildBg, v4(0.01, 0.01, 0.01, 0.80))
                                    m.ChildAutoSize(" "..killlist[i][1]..'  '..killlist[i][2]..'  ')
                                        m.PushFont(font[18])
                                            m.CenterTextAndImage("   "..killlist[i][1], weapons[tonumber(killlist[i][3])], killlist[i][2].."   ")
                                        m.PopFont()
                                    m.EndChild()
                                m.PopStyleColor(2)
                            m.PopStyleVar(1)
                        end
                    end
                m.EndChild()
            m.End()
        m.PopStyleColor(2)
        --m.GetIO().MouseDrawCursor = 1
        player.HideCursor = true
    end
)

function getWeaponNameById(model)
    local names = {
      [0] = 'Ничего',
      [1] = 'Кастет',
      [2] = 'Клюшка для гольфа',
      [3] = 'Полицейская дубинка',
      [4] = 'Нож',
      [5] = 'Бейсбольная бита',
      [6] = 'Лопата',
      [7] = 'Кий',
      [8] = 'Катана',
      [9] = 'Бензопила',
      [10] = 'Двухсторонний дилдо',
      [11] = 'Дилдо',
      [12] = 'Вибратор',
      [13] = 'Серебряный вибратор',
      [14] = 'Букет цветов',
      [15] = 'Трость',
      [16] = 'Граната',
      [17] = 'Слезоточивый газ',
      [18] = 'Коктейль Молотова',
      [22] = 'Пистолет 9мм',
      [23] = 'Пистолет с глушителем',
      [24] = 'Пустынный орел',
      [25] = 'Обычный дробовик',
      [26] = 'Обрез',
      [27] = 'Скорострельный дробовик',
      [28] = 'Узи',
      [29] = 'MP5',
      [30] = 'Автомат Калашникова',
      [31] = 'Винтовка M4',
      [32] = 'Tec-9',
      [33] = 'Охотничье ружье',
      [34] = 'Снайперская винтовка',
      [35] = 'РПГ',
      [36] = 'Самонаводящиеся ракеты HS',
      [37] = 'Огнемет',
      [38] = 'Миниган',
      [39] = 'Сумка с тротилом',
      [40] = 'Детонатор к сумке',
      [41] = 'Баллончик с краской',
      [42] = 'Огнетушитель',
      [43] = 'Фотоаппарат',
      [44] = 'Прибор ночного видения',
      [45] = 'Тепловизор',
      [46] = 'Парашют'
    }
    return u8(names[model])
end

function switchMenu(newMenu)
    for i = 1, 2 do
        if i ~= newMenu then
            menuType[i] = false
        end
    end
    menuType[newMenu] = true
end

function switchKlistAlign(newAlign)
    for i = 1, 4 do
        if i ~= newAlign then
            killlistAlign[i] = false
        end
    end
    killlistAlign[newAlign] = true
end

function m.ButtonActivated(activated, ...)
    if activated then
        m.PushStyleColor(m.Col.Button, m.GetStyle().Colors[m.Col.ButtonHovered])
        m.PushStyleColor(m.Col.ButtonHovered, m.GetStyle().Colors[m.Col.ButtonHovered])
        m.PushStyleColor(m.Col.ButtonActive, m.GetStyle().Colors[m.Col.ButtonHovered])

            m.Button(...)

        m.PopStyleColor()
        m.PopStyleColor()
        m.PopStyleColor()

    else
        return m.Button(...)
    end
end

function m.ChildAutoSize(label, ...)
    local calc = m.CalcTextSize(label)
    local width = m.GetWindowWidth()
    if killlistAlign[1] then
        m.SetCursorPosX( width - width)
    elseif killlistAlign[2] then
        m.SetCursorPosX( width / 2 - calc.x / 2 )
    elseif killlistAlign[3] then
        m.SetCursorPosX( width - (calc.x + 15) - 20 )
    end
    m.BeginChild(label, v2(calc.x + 25, 40), true)
end

function m.CenterText(text)
    local width = m.GetWindowWidth()
    local calc = m.CalcTextSize(text)
    m.SetCursorPosX( width / 2 - calc.x / 2 )
    m.Text(text)
end

function m.CenterTextAndImage(textLeft, image, textRight)
    local width = m.GetWindowWidth()
    m.SetCursorPosX( width - width)
    m.Text(textLeft, m.SetCursorPosY( 12 )) m.SameLine()
    m.Image(image, v2(20, 20), m.SetCursorPosY( 10 )) m.SameLine()
    m.Text(textRight, m.SetCursorPosY( 12 ))
end

m.OnInitialize(function()
    m.DarkTheme()
        for i = 0, 46 do
            weapons[i] = m.CreateTextureFromFile(getWorkingDirectory().."/resource/UHUD/weapons/"..i..".png")
        end
        local config = m.ImFontConfig()
        config.MergeMode = true
        local glyph_ranges_icon = m.GetIO().Fonts:GetGlyphRangesCyrillic()
        local iconRanges = m.new.ImWchar[3](fa.min_range, fa.max_range, 0)
        m.GetIO().Fonts:AddFontFromFileTTF('trebucbd.ttf', 14.0, nil, glyph_ranges_icon)
        local glyph_ranges = m.GetIO().Fonts:GetGlyphRangesCyrillic()
        icon = m.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/resource/UHUD/fonts/Fa6Pro-solid-900.otf', 16.0, config, iconRanges)
        font = {
            [18] = m.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/resource/UHUD/fonts/FSM.otf', 14.0, nil, glyph_ranges),
            [22] = m.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/resource/UHUD/fonts/HUDHINT.ttf', 22.0, nil, glyph_ranges),
        }
    m.GetIO().IniFilename = nil
end)

-- Dark Theme для скрипта. Автор: chapo (https://www.blast.hk/members/112329/)
function m.DarkTheme()
    m.SwitchContext()
    --==[ STYLE ]==--
    m.GetStyle().WindowPadding = m.ImVec2(5, 5)
    m.GetStyle().FramePadding = m.ImVec2(3, 3)
    m.GetStyle().ItemSpacing = m.ImVec2(5, 5)
    m.GetStyle().ItemInnerSpacing = m.ImVec2(2, 2)
    m.GetStyle().TouchExtraPadding = m.ImVec2(0, 0)
    m.GetStyle().IndentSpacing = 0
    m.GetStyle().ScrollbarSize = 10
    m.GetStyle().GrabMinSize = 10
    m.GetStyle().ColumnsMinSpacing = 25

    --==[ BORDER ]==--
    m.GetStyle().WindowBorderSize = 2
    m.GetStyle().ChildBorderSize = 2
    m.GetStyle().PopupBorderSize = 1
    m.GetStyle().FrameBorderSize = 0
    m.GetStyle().TabBorderSize = 1

    --==[ ROUNDING ]==--
    m.GetStyle().WindowRounding = 5
    m.GetStyle().ChildRounding = 5
    m.GetStyle().FrameRounding = 5
    m.GetStyle().PopupRounding = 5
    m.GetStyle().ScrollbarRounding = 5
    m.GetStyle().GrabRounding = 5
    m.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    m.GetStyle().WindowTitleAlign = m.ImVec2(0.5, 0.5)
    m.GetStyle().ButtonTextAlign = m.ImVec2(0.5, 0.5)
    m.GetStyle().SelectableTextAlign = m.ImVec2(0.5, 0.5)
    
    --==[ COLORS ]==--
    m.GetStyle().Colors[m.Col.Text]                   = m.ImVec4(1.00, 1.00, 1.00, 1.00)
    m.GetStyle().Colors[m.Col.TextDisabled]           = m.ImVec4(0.50, 0.50, 0.50, 1.00)
    m.GetStyle().Colors[m.Col.WindowBg]               = m.ImVec4(0.07, 0.07, 0.07, 1.00)
    m.GetStyle().Colors[m.Col.ChildBg]                = m.ImVec4(0.07, 0.07, 0.07, 0.00)
    m.GetStyle().Colors[m.Col.PopupBg]                = m.ImVec4(0.07, 0.07, 0.07, 1.00)
    m.GetStyle().Colors[m.Col.Border]                 = m.ImVec4(0.25, 0.25, 0.26, 1.00)
    m.GetStyle().Colors[m.Col.BorderShadow]           = m.ImVec4(0.00, 0.00, 0.00, 0.00)
    m.GetStyle().Colors[m.Col.FrameBg]                = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.FrameBgHovered]         = m.ImVec4(0.25, 0.25, 0.26, 1.00)
    m.GetStyle().Colors[m.Col.FrameBgActive]          = m.ImVec4(0.25, 0.25, 0.26, 1.00)
    m.GetStyle().Colors[m.Col.TitleBg]                = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.TitleBgActive]          = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.TitleBgCollapsed]       = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.MenuBarBg]              = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.ScrollbarBg]            = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.ScrollbarGrab]          = m.ImVec4(0.00, 0.00, 0.00, 1.00)
    m.GetStyle().Colors[m.Col.ScrollbarGrabHovered]   = m.ImVec4(0.41, 0.41, 0.41, 1.00)
    m.GetStyle().Colors[m.Col.ScrollbarGrabActive]    = m.ImVec4(0.51, 0.51, 0.51, 1.00)
    m.GetStyle().Colors[m.Col.CheckMark]              = m.ImVec4(1.00, 1.00, 1.00, 1.00)
    m.GetStyle().Colors[m.Col.SliderGrab]             = m.ImVec4(0.21, 0.20, 0.20, 1.00)
    m.GetStyle().Colors[m.Col.SliderGrabActive]       = m.ImVec4(0.21, 0.20, 0.20, 1.00)
    m.GetStyle().Colors[m.Col.Button]                 = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.ButtonHovered]          = m.ImVec4(0.21, 0.23, 0.20, 1.00)
    m.GetStyle().Colors[m.Col.ButtonActive]           = m.ImVec4(0.41, 0.41, 0.41, 1.00)
    m.GetStyle().Colors[m.Col.Header]                 = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.HeaderHovered]          = m.ImVec4(0.20, 0.20, 0.20, 1.00)
    m.GetStyle().Colors[m.Col.HeaderActive]           = m.ImVec4(0.47, 0.47, 0.47, 1.00)
    m.GetStyle().Colors[m.Col.Separator]              = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.SeparatorHovered]       = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.SeparatorActive]        = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.ResizeGrip]             = m.ImVec4(1.00, 1.00, 1.00, 0.25)
    m.GetStyle().Colors[m.Col.ResizeGripHovered]      = m.ImVec4(1.00, 1.00, 1.00, 0.67)
    m.GetStyle().Colors[m.Col.ResizeGripActive]       = m.ImVec4(1.00, 1.00, 1.00, 0.95)
    m.GetStyle().Colors[m.Col.Tab]                    = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.TabHovered]             = m.ImVec4(0.28, 0.28, 0.28, 1.00)
    m.GetStyle().Colors[m.Col.TabActive]              = m.ImVec4(0.30, 0.30, 0.30, 1.00)
    m.GetStyle().Colors[m.Col.TabUnfocused]           = m.ImVec4(0.07, 0.10, 0.15, 0.97)
    m.GetStyle().Colors[m.Col.TabUnfocusedActive]     = m.ImVec4(0.14, 0.26, 0.42, 1.00)
    m.GetStyle().Colors[m.Col.PlotLines]              = m.ImVec4(0.61, 0.61, 0.61, 1.00)
    m.GetStyle().Colors[m.Col.PlotLinesHovered]       = m.ImVec4(1.00, 0.43, 0.35, 1.00)
    m.GetStyle().Colors[m.Col.PlotHistogram]          = m.ImVec4(0.90, 0.70, 0.00, 1.00)
    m.GetStyle().Colors[m.Col.PlotHistogramHovered]   = m.ImVec4(1.00, 0.60, 0.00, 1.00)
    m.GetStyle().Colors[m.Col.TextSelectedBg]         = m.ImVec4(1.00, 0.00, 0.00, 0.35)
    m.GetStyle().Colors[m.Col.DragDropTarget]         = m.ImVec4(1.00, 1.00, 0.00, 0.90)
    m.GetStyle().Colors[m.Col.NavHighlight]           = m.ImVec4(0.26, 0.59, 0.98, 1.00)
    m.GetStyle().Colors[m.Col.NavWindowingHighlight]  = m.ImVec4(1.00, 1.00, 1.00, 0.70)
    m.GetStyle().Colors[m.Col.NavWindowingDimBg]      = m.ImVec4(0.80, 0.80, 0.80, 0.20)
    m.GetStyle().Colors[m.Col.ModalWindowDimBg]       = m.ImVec4(0.00, 0.00, 0.00, 1.00)
end