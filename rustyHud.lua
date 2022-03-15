---@diagnostic disable: lowercase-global, undefined-global
local events = require 'samp.events'
local imgui = require 'mimgui'
local vkeys = require 'vkeys'
local wm = require 'windows.message'
local fa = require 'fAwesome5'
local memory = require 'memory'

local new = imgui.new
local hudWindow, weaponWindow = new.bool(), new.bool()
local sizeX, sizeY = getScreenResolution()
local weapons, slots = {}, {}
local satiety = 0
local satietyCheck = false

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
    imgui.GetIO().IniFilename = nil
end)

function main()
    while not isSampAvailable() do wait(0) end
    hudWindow[0], weaponWindow[0] = true, true
    displayHud(true)
    for i = 1, 13 do
        weapon, ammo, Model = getCharWeaponInSlot(PLAYER_PED, i)
        sampAddChatMessage(''..weapon..' | '..ammo, -1)
    end
    sampAddChatMessage('', -1)
    while true do
        sampGetPlayerSatiety()
        wait(60000)
    end
end

local weaponFrame  = imgui.OnFrame(
    function() return weaponWindow[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - 130), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
        imgui.SetNextWindowSize(imgui.ImVec2(535, 95), imgui.Cond.FirstUseEver)
        imgui.Begin("Weapon Window", weaponWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoBackground)
            imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.36, 0.32, 0.36, 0.50))
                for i = 1, 6 do
                    weapon, ammo, Model = getCharWeaponInSlot(PLAYER_PED, i)
                    if weapon ~= 0 then
                        slots[i] = weapon
                        imgui.BeginChild('#weapon-'..weapon..'ammo:'..i, imgui.ImVec2(80, 80), false)
                            imgui.Image(weapons[weapon], imgui.ImVec2(60, 60), imgui.SetCursorPosX(10), imgui.SetCursorPosY(7))
                            if weapon == getCurrentCharWeapon(PLAYER_PED) then
                                if getAmmoInClip() < 10 then
                                    imgui.Text("    "..getAmmoInClip(), imgui.SetCursorPosY(63), imgui.SetCursorPosX(56))
                                elseif getAmmoInClip() >= 10 or getAmmoInClip() < 100 then
                                    imgui.Text("  "..getAmmoInClip(), imgui.SetCursorPosY(63), imgui.SetCursorPosX(56))
                                elseif getAmmoInClip() >= 100 then
                                    imgui.Text(""..getAmmoInClip(), imgui.SetCursorPosY(63), imgui.SetCursorPosX(56))
                                end
                            end
                        imgui.EndChild() imgui.SameLine()
                    else
                        imgui.BeginChild('#spaceSlot-'..i, imgui.ImVec2(80, 80), false)
                           
                        imgui.EndChild() imgui.SameLine()
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
                end
            imgui.PopStyleColor(1)
        imgui.End()
        player.HideCursor = true
    end
)

local hudFrame = imgui.OnFrame(
    function() return hudWindow[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX - 15, sizeY - 15), imgui.Cond.FirstUseEver, imgui.ImVec2(1, 1))
        imgui.SetNextWindowSize(imgui.ImVec2(250, 110), imgui.Cond.FirstUseEver)
        imgui.Begin("Main Window", hudWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoBackground + imgui.WindowFlags.NoMove)
        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.36, 0.32, 0.36, 0.50))
            imgui.BeginChild('#BarHealth', imgui.ImVec2(230, 26), false)
                    imgui.Text(""..fa.ICON_FA_PLUS, imgui.SetCursorPosY(7), imgui.SetCursorPosX(5))
                    local hp = sampGetPlayerHealth(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                    local armour = sampGetPlayerArmor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                    if hp == 0 then
                        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.34, 0.76, 0.61, 0.00))
                    else
                        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.34, 0.76, 0.61, 0.50))
                    end
                    imgui.Text(""..hp - 1, imgui.SetCursorPosY(5), imgui.SetCursorPosX(33))
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
                    imgui.Text(""..armour, imgui.SetCursorPosY(5), imgui.SetCursorPosX(33))
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
                imgui.Text(""..satiety, imgui.SetCursorPosY(5), imgui.SetCursorPosX(33))
                imgui.BeginChild('#BarHealthBar', imgui.ImVec2(satiety * 2, 20), imgui.SetCursorPosX(25), imgui.SetCursorPosY(3), false)
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
    sampSendChat('/satiety')
    satietyCheck = true
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