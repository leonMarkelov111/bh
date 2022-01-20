local imgui = require 'imgui'
require('encoding').default = 'CP1251'
local u8 = require('encoding').UTF8
local q = require 'lib.samp.events'
local fa = require 'fAwesome5'

local window = imgui.ImBool(false)
local waiting = imgui.ImInt(2500)
local state = false
local id, nick, house, ms, biz, captcha = nil, nil, nil, nil, nil, nil

local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 15.0, font_config, fa_glyph_ranges)
    end
end

function imgui.OnDrawFrame()
    if window.v then
        local ex, ey = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(ex / 2 - 200, ey / 2 - 77.5), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(400, 155), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Promo', window, 1 + 2 + 32 + 128)
        local size = imgui.GetWindowSize()
        imgui.SetCursorPos(imgui.ImVec2(size.x / 2 - imgui.CalcTextSize(u8'Статус: '..(state and u8'Включён' or u8'Выключен')).x / 2, 12.5)) 
        imgui.Text(u8'Статус:') imgui.SameLine()
        if state then
            imgui.TextColored(imgui.ImVec4(0, 1, 0, 1), u8'Включён')
        else
            imgui.TextColored(imgui.ImVec4(1, 0, 0, 1), u8'Выключен')
        end
        imgui.SameLine()
        imgui.SetCursorPos(imgui.ImVec2(size.x - 20 - 10, 10))
        imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 10)
        if imgui.Button(fa.ICON_FA_TIMES, imgui.ImVec2(20, 20)) then window.v = false end
        imgui.PopStyleVar(1)
        imgui.Separator()
        imgui.SetCursorPosX(size.x / 2 -  imgui.CalcTextSize(state and u8'Выключить' or u8'Включить').x / 2)
        if imgui.Button(state and u8'Выключить' or u8'Включить') then state = not state end
        imgui.SetCursorPosX(size.x / 2 - (imgui.CalcTextSize(u8'Задержка').x + 210) / 2) imgui.Text(u8'Задержка:') imgui.SameLine() imgui.PushItemWidth(150) imgui.SliderInt('##waiting', waiting, 0, 5000, waiting.v ~= 0 and "%.0f ms" or u8"Без задержки") imgui.SameLine() if imgui.Button(fa.ICON_FA_MINUS, imgui.ImVec2(25, 20)) then if waiting.v - 100 > 0 then waiting.v = waiting.v - 100 else waiting.v = 0 end end imgui.SameLine() if imgui.Button(fa.ICON_FA_PLUS, imgui.ImVec2(25, 20)) then if waiting.v + 100 < 5000 then waiting.v = waiting.v + 100 else waiting.v = 5000 end end
        imgui.SetCursorPosY(size.y - 25) imgui.Separator()
        imgui.SetCursorPosX(size.x / 2 - imgui.CalcTextSize(u8'Автор: Katsu <3').x / 2) imgui.Text(u8'Автор:') imgui.SameLine() imgui.TextColored(imgui.ImVec4(1, 0, 77 / 255, 1), '#Yankee')
        imgui.End()
    end
end

function main()
    repeat wait(0) until isSampAvailable()
    while true do wait(0) imgui.Process = window.v end
end

function q.onSendCommand(text)
    if text == '/aopra' then window.v = not window.v return false end
end

function q.onServerMessage(color, text)
    if text:find('{BE2D2D} (.*) (.*) купил дом ID:(.*) по гос. цене за (.*) ms! Капча: ((.*) | (.*))') then
        local nick text:match('{BE2D2D} (.*) .* купил дом ID:.* по гос. цене за .* ms! Капча: (.* | .*)')
        local id text:match('{BE2D2D} .* (.*) купил дом ID:.* по гос. цене за .* ms! Капча: (.* | .*)')
        local idhouse text:match('{BE2D2D} .* .* купил дом ID:(.*) по гос. цене за .* ms! Капча: (.* | .*)')
        local ms text:match('{BE2D2D} .* .* купил дом ID:.* по гос. цене за (.*) ms! Капча: (.* | .*)')
        local cap1 text:match('{BE2D2D} .* .* купил дом ID:.* по гос. цене за .* ms! Капча: ((.*) | .*)')
        local cap2 text:match('{BE2D2D} .* .* купил дом ID:.* по гос. цене за .* ms! Капча: (.* | (.*))')
        sampSendChat('/jail ' ..id.. ' 3000 Опру дом: ' ..idhouse..' Капча: ' ..ms)
        sampAddChatMessage('+one', -1)
    end
end

function q.onServerMessage(color, text)
    if text:find('ВНИМАНИЕ:{BE2D2D} Промокод на (.+) %[level/id: (.+) %| количество: (.+)%], промокод %-> (.+) %(Вводить /promo%).') and state then
        id, nick, house, ms, biz, captcha = text:match('ВНИМАНИЕ:{BE2D2D} Промокод на (.+) %[level/id: (.+) %| количество: (.+)%], промокод %-> (.+) %(Вводить /promo%).')
        sampSendChat('/jail [id] 3000 Опру биз [biz]')
        sampAddChatMessage('+one', -1)
    end
end

function applyTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
  
  
    style.WindowPadding = ImVec2(6, 4)
    style.WindowRounding = 5.0
    style.FramePadding = ImVec2(5, 2)
    style.FrameRounding = 3.0
    style.ItemSpacing = ImVec2(7, 5)
    style.ItemInnerSpacing = ImVec2(1, 1)
    style.TouchExtraPadding = ImVec2(0, 0)
    style.IndentSpacing = 6.0
    style.ScrollbarSize = 12.0
    style.ScrollbarRounding = 16.0
    style.GrabMinSize = 20.0
    style.GrabRounding = 2.0
  
    style.WindowTitleAlign = ImVec2(0.5, 0.5)

    
    colors[clr.Border] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.WindowBg] = ImVec4(0.13, 0.14, 0.17, 1.00)
    colors[clr.FrameBg] = ImVec4(0.200, 0.220, 0.270, 0.85)
    colors[clr.TitleBg] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.TitleBgActive] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.Button] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.ButtonHovered] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.Separator] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.Header] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.HeaderHovered] = ImVec4(0.68, 0, 0.2, 0.86)
    colors[clr.HeaderActive] = ImVec4(1, 0.24, 0.47, 1.00)
    colors[clr.CheckMark] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.ModalWindowDarkening] = ImVec4(0.200, 0.220, 0.270, 0.73)

    colors[clr.ScrollbarBg] = ImVec4(0.200, 0.220, 0.270, 0.85)
    colors[clr.ScrollbarGrab] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(1, 0, 0.3, 1.00)

    colors[clr.ButtonActive] = ImVec4(1, 0, 0.3, 1.00)
    
end
applyTheme()