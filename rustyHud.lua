---@diagnostic disable: lowercase-global, undefined-global
local events = require 'samp.events'
local imgui = require 'mimgui'
local vkeys = require 'vkeys'
local wm = require 'windows.message'
local fa = require 'fAwesome5'
local memory = require 'memory'
local enc = require 'encoding'

script_name('Rusty Hud')
script_author("neverlessy")
script_version("0.0.5")
script_version_number(2205)

local new = imgui.new
local win = new.bool(false)
local hudWindow, weaponWindow, settingsWindow = new.bool(), new.bool(), new.bool()
local sizeX, sizeY = getScreenResolution()
local weapons, slots = {}, {24, 31, 0, 0, 0, 0}
local satiety, num = 0, '0'
local satietyCheck = false
enc.default = 'CP1251'
local u8 = enc.UTF8

imgui.OnInitialize(function()
    styleInit()
    for i = 0, 46 do
        weapons[i] = imgui.CreateTextureFromFile(getWorkingDirectory().."/resource/RustyHUD/weapons/"..i..".png")
    end
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    local glyph_ranges_icon = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local iconRanges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromFileTTF('trebucbd.ttf', 14.0, nil, glyph_ranges_icon)
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    icon = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/resource/RustyHUD/font/Fa6Pro-solid-900.otf', 16.0, config, iconRanges)
    font = {
        [15] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/resource/RustyHUD/font/FSM.otf', 18.0, nil, glyph_ranges),
        [22] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/resource/RustyHUD/font/HUDHINT.ttf', 22.0, nil, glyph_ranges),
    }
    imgui.GetIO().IniFilename = nil
end)

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(0) end
    hudWindow[0], weaponWindow[0] = true, true
    displayHud(false)
    sampGetPlayerSatiety()
    sampRegisterChatCommand('rusty', function()
        sampToggleCursor(true)
        showCursor(true, true)
        settingsWindow[0] = not settingsWindow[0]
    end)
    while true do wait(0)
    end
end

local settingsFrame = imgui.OnFrame(
    function() return settingsWindow[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
        imgui.SetNextWindowSize(imgui.ImVec2(700, 450), imgui.Cond.FirstUseEver)
        imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 8)
        imgui.PushStyleVarFloat(imgui.StyleVar.WindowRounding, 8)
            imgui.Begin("Settings Window", weaponWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
                   imgui.PushFont(font[15])
                    for i = 1, 6 do
                        if imgui.ImageButton(weapons[slots[i]], imgui.ImVec2(60, 60)) then
                            imgui.OpenPopup(u8'Слот '..i)
                            sampAddChatMessage('Нажата кнопка '..i, -1)
                        end imgui.SameLine()
                        if imgui.BeginPopupModal(u8'Слот '..i, win[0], true, imgui.WindowFlags.NoResize) then
                            imgui.SetWindowSizeVec2(imgui.ImVec2(400, 600), imgui.Cond.FirstUseEver)
                            for v = 0, 46 do
                                if v ~= 19 and v ~= 20 and v ~= 21 then
                                    if imgui.Button(''..getWeaponNameById(v), imgui.ImVec2(200, 80)) then
                                        sampAddChatMessage('Для слота '..i..' установлено оружие '..v, -1)
                                        slots[i] = v
                                        imgui.CloseCurrentPopup()
                                    end imgui.SameLine()
                                    imgui.Image(weapons[v], imgui.ImVec2(80, 80))
                                end
                            end
                            imgui.EndPopup()
                        end
                    end
                    imgui.PopFont()
            imgui.End()
        imgui.PopStyleVar(2)
        imgui.ShowCursor = true
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

local weaponFrame = imgui.OnFrame(
    function() return weaponWindow[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - 15), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
        imgui.SetNextWindowSize(imgui.ImVec2(535, 95), imgui.Cond.FirstUseEver)
        imgui.Begin("Weapon Window", weaponWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoBackground + imgui.WindowFlags.NoMove)
            imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.36, 0.36, 0.36, 0.60))
                for i = 1, 6 do
                        imgui.BeginChild('#slot-'..i, imgui.ImVec2(80, 80), false)
                            if hasCharGotWeapon(PLAYER_PED, slots[i]) and slots[i] ~= 0 then
                                imgui.Image(weapons[slots[i]], imgui.ImVec2(60, 60), imgui.SetCursorPosX(10), imgui.SetCursorPosY(7))
                                weapon, ammo, Model = getCharWeaponInSlot(PLAYER_PED, i)
                                if getCurrentCharWeapon(PLAYER_PED) == slots[i] then
                                    if getAmmoInClip() < 10 then
                                        imgui.Text("    "..getAmmoInClip(), imgui.SetCursorPosY(63), imgui.SetCursorPosX(56))
                                    elseif getAmmoInClip() >= 10 or getAmmoInClip() < 100 then
                                        imgui.Text("  "..getAmmoInClip(), imgui.SetCursorPosY(63), imgui.SetCursorPosX(56))
                                    elseif getAmmoInClip() >= 100 then
                                        imgui.Text(""..getAmmoInClip(), imgui.SetCursorPosY(63), imgui.SetCursorPosX(56))
                                    end
                                    imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.34, 0.76, 0.61, 0.50))
                                        imgui.BeginChild('#ammoInClipBar'..i, imgui.ImVec2(4, 80), imgui.SetCursorPosY(0), imgui.SetCursorPosX(0))
                                        imgui.EndChild()
                                    imgui.PopStyleColor(1)
                                else
                                    if getAmmoInCharWeapon(PLAYER_PED, slots[i]) < 10 then
                                        imgui.Text("    "..getAmmoInCharWeapon(PLAYER_PED, slots[i]), imgui.SetCursorPosY(63), imgui.SetCursorPosX(56))
                                    elseif getAmmoInCharWeapon(PLAYER_PED, slots[i]) >= 10 or getAmmoInCharWeapon(PLAYER_PED, slots[i]) < 100 then
                                        imgui.Text("  "..getAmmoInCharWeapon(PLAYER_PED, slots[i]), imgui.SetCursorPosY(63), imgui.SetCursorPosX(56))
                                    elseif getAmmoInCharWeapon(PLAYER_PED, slots[i]) >= 100 then
                                        imgui.Text(""..getAmmoInCharWeapon(PLAYER_PED, slots[i]), imgui.SetCursorPosY(63), imgui.SetCursorPosX(56))
                                    end
                                end
                            end
                        imgui.EndChild() imgui.SameLine()
                end
                if isKeyJustPressed(48) then
                    setCurrentCharWeapon(PLAYER_PED, 0)
                end
                if isKeyJustPressed(49) then
                    setCurrentCharWeapon(PLAYER_PED, slots[1])
                end
                if isKeyJustPressed(50) then
                    setCurrentCharWeapon(PLAYER_PED, slots[2])
                end
                if isKeyJustPressed(51) then 
                    setCurrentCharWeapon(PLAYER_PED, slots[3])
                end
                if isKeyJustPressed(52) then
                    setCurrentCharWeapon(PLAYER_PED, slots[4])
                end
                if isKeyJustPressed(53) then 
                    setCurrentCharWeapon(PLAYER_PED, slots[5])
                end
                if isKeyJustPressed(54) then 
                    setCurrentCharWeapon(PLAYER_PED, slots[6])
                end
            imgui.PopStyleColor(1)
        imgui.End()
        player.HideCursor = true
    end
)

function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function separator(text)
	    for S in string.gmatch(text, "%d+") do
	    	local replace = comma_value(S)
	    	text = string.gsub(text, S, replace)
	    end
	    for S in string.gmatch(text, "%d+") do
	    	S = string.sub(S, 0, #S-1)
	    	local replace = comma_value(S)
	    	text = string.gsub(text, S, replace)
	    end
	return text
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

local hudFrame = imgui.OnFrame(
    function() return hudWindow[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX - 15, sizeY - 15), imgui.Cond.FirstUseEver, imgui.ImVec2(1, 1))
        imgui.SetNextWindowSize(imgui.ImVec2(250, 140), imgui.Cond.FirstUseEver)
        imgui.Begin("Main Window", hudWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoBackground + imgui.WindowFlags.NoMove)
        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.36, 0.36, 0.36, 0.60))
            imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.34, 0.76, 0.61, 0.60))
                imgui.BeginChild('#BarBalance', imgui.ImVec2(230, 26), false)
                    imgui.PushFont(font[22])
                    imgui.Text("  $") imgui.SameLine()
                    if getPlayerMoney(player) > 0 then
                        imgui.CenterText(u8""..separator(tostring(""..getPlayerMoney(player))))
                    else
                        imgui.CenterText(u8"0") 
                    end
                    imgui.PopFont()
                imgui.EndChild()
            imgui.PopStyleColor()
            imgui.BeginChild('#BarHealth', imgui.ImVec2(230, 26), false)
                    imgui.Text(""..fa.ICON_FA_PLUS, imgui.SetCursorPosY(7), imgui.SetCursorPosX(5))
                    local hp = sampGetPlayerHealth(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                    local armour = sampGetPlayerArmor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                    if hp == 0 then
                        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.34, 0.76, 0.61, 0.00))
                    else
                        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.34, 0.76, 0.61, 0.50))
                    end
                    imgui.PushFont(font[15])
                        imgui.Text(""..hp - 1, imgui.SetCursorPosY(4), imgui.SetCursorPosX(33))
                    imgui.PopFont()
                    if hp <= 100 then
                        imgui.BeginChild('#BarHealthBar', imgui.ImVec2(hp * 2), imgui.SetCursorPosX(25), imgui.SetCursorPosY(3), false)
                    elseif hp > 100 then
                        imgui.BeginChild('#BarHealthBar', imgui.ImVec2((hp * 2) - ((hp - 100) * 2), 20), imgui.SetCursorPosX(25), imgui.SetCursorPosY(3), false)
                    end
                    imgui.EndChild()
                imgui.PopStyleColor(1)
            imgui.EndChild()
            imgui.BeginChild('#BarArmour', imgui.ImVec2(230, 26), false)
                    imgui.Text(""..fa.ICON_FA_ARMOUR, imgui.SetCursorPosY(8), imgui.SetCursorPosX(4))
                    if armour == 0 then
                        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.34, 0.67, 0.75, 0.00))
                    else
                        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.34, 0.67, 0.75, 0.50))
                    end
                    imgui.PushFont(font[15])
                        imgui.Text(""..armour, imgui.SetCursorPosY(4), imgui.SetCursorPosX(33))
                    imgui.PopFont()
                    imgui.BeginChild('#BarHealthBar', imgui.ImVec2(armour * 2, 20), imgui.SetCursorPosX(25), imgui.SetCursorPosY(3), false)
                    imgui.EndChild()
                imgui.PopStyleColor(1)
            imgui.EndChild()
            imgui.BeginChild('#BarSatiety', imgui.ImVec2(230, 26), false)
                imgui.Text(""..fa.ICON_FA_UTENSILS, imgui.SetCursorPosY(8), imgui.SetCursorPosX(4))
                if satiety == 0 then
                    imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.85, 0.58, 0.01, 0.00))
                else
                    imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.85, 0.58, 0.01, 0.50))
                end
                imgui.PushFont(font[15])
                    imgui.Text(""..satiety, imgui.SetCursorPosY(4), imgui.SetCursorPosX(33))
                imgui.PopFont()
                imgui.BeginChild('#BarSatietyBars', imgui.ImVec2(satiety * 2, 20), imgui.SetCursorPosX(25), imgui.SetCursorPosY(3), false)
                imgui.EndChild()
            imgui.EndChild()
        imgui.PopStyleColor(1)
        imgui.End()
        player.HideCursor = true
    end
)

function events.onShowDialog(id, style, title, button1, button2, text)
    if text:find("Ваша сытость%: {......}%d+/%d+") and satietyCheck then
        satiety = text:match("Ваша сытость%: {......}(%d+)/%d+")
        satietyCheck = false
        sampSendDialogResponse(id, 0 , -1, -1)
        return false
    end
end

function sampGetPlayerSatiety()
    lua_thread.create(function()
        while true do 
            sampSendChat('/satiety')
            satietyCheck = true
            wait(60000)
        end
    end)
end

function getAmmoInClip()
	local pointer = getCharPointer(PLAYER_PED)
	local weapon = getCurrentCharWeapon(PLAYER_PED)
	local slot = getWeapontypeSlot(weapon)
	local offset = pointer + 0x5A0
	local address = offset + slot * 0x1C
	return memory.getuint32(address + 0x8)
end

function styleInit()
    local style = imgui.GetStyle()
      local colors = style.Colors
      local clr = imgui.Col
      local ImVec4 = imgui.ImVec4
      local ImVec2 = imgui.ImVec2
  
      style.Alpha = 1.0
      style.ChildRounding = 0.0
      style.WindowRounding = 0.0
      style.GrabRounding = 40.0
      style.GrabMinSize = 20.0
      style.WindowBorderSize = 0.0
      style.FrameRounding = 0.0
      style.ButtonTextAlign = imgui.ImVec2(0.03, 0.5)
      style.PopupRounding = 10.0
  
      colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00);
      colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00);
      colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00);
      colors[clr.ChildBg] = ImVec4(1.00, 1.00, 1.00, 0.05);
      colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00);
      colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 1.00);
      colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00);
      colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00);
      colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00);
      colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00);
      colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00);
      colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75);
      colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00);
      colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00);
      colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00);
      colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31);
      colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00);
      colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00);
      --colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00);
      colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31);
      colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31);
      colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00);
      colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00);
      colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00);
      colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00);
      colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00);
      colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00);
      colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00);
      --colors[clr.Column] = ImVec4(0.56, 0.56, 0.58, 1.00);
      --colors[clr.ColumnHovered] = ImVec4(0.24, 0.23, 0.29, 1.00);
      --colors[clr.ColumnActive] = ImVec4(0.56, 0.56, 0.58, 1.00);
      colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00);
      colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00);
      colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00);
      --colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16);
      --colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39);
      --colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00);
      colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63);
      colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00);
      colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63);
      colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00);
      colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43);
      --colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73);
  end