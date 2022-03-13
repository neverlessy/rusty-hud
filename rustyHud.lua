---@diagnostic disable: lowercase-global, undefined-global
local events = require 'samp.events'
local imgui = require 'mimgui'
local vkeys = require 'vkeys'
local wm = require 'windows.message'
local fa = require 'fAwesome5'

local new = imgui.new
local hudWindow = new.bool()
local sizeX, sizeY = getScreenResolution()
local satiety = 0
local satietyCheck = false

imgui.OnInitialize(function()
    styleInit()
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    local glyph_ranges_icon = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local iconRanges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromFileTTF('trebucbd.ttf', 14.0, nil, glyph_ranges_icon)
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    icon = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/resource/MiPhone/fonts/Fa6Pro-solid-900.otf', 16.0, config, iconRanges)
    imgui.GetIO().IniFilename = nil
end)

function main()
    while not isSampAvailable() do wait(0) end
    hudWindow[0] = true
    displayHud(false)
    while true do
        sampGetPlayerSatiety()
        wait(60000)
    end
end

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
                    imgui.BeginChild('#BarHealthBar', imgui.ImVec2((hp * 2) - ((hp - 100) * 2), 20), imgui.SetCursorPosX(25), imgui.SetCursorPosY(3), false)
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
        return false
    end
end

function sampGetPlayerSatiety()
    sampSendChat('/satiety')
    satietyCheck = true
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