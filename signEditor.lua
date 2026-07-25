
local basalt = require("basalt")
local config = require("config")
local signRender = require("signRender")

local signEditor = {}

local main = basalt.getMainFrame()

local arrows = fs.list("symbols/arrows/")
local icons = fs.list("symbols/icons/")

local arrow_idx = 1
local icon_idx = 1



local COLORS = {
    "black", "white", "red", "blue", "cyan", "green", "orange", "brown", "magenta", "lightGray", "gray"
}

config.load("/data/sign.cfg")

local function getContrastingTextColor(color)
    local r,g,b = term.getPaletteColor(color)
    local luminance = (0.299 * r + 0.587 * g + 0.114 * b)

    if luminance > 0.5 then
        return colors.black
    else
        return colors.white
    end
end

local function loadColors(color_dropdown)
    for i = 1, #COLORS do
        local color = COLORS[i]
        local textColor = getContrastingTextColor(colors[color])
        color_dropdown:addItem({
            text = color,
            bg = colors[color],
            fg = textColor,
            selectedBg = colors[color],
            selectedFg = textColor
        })
    end
end

local function drawGraphic(path, target)
    local backDir = term.redirect(target)
    term.setBackgroundColor(colors.black)
    term.clear()
    local graphic = paintutils.loadImage("/symbols/" .. path)
    paintutils.drawImage(graphic,2,2)
    term.redirect(backDir)
end

function signEditor.open()
    -- SETTING DEFAULTS
    if config.get("signContent") == nil then
        config.set("signContent", "Sample Text")
    end
    if config.get("borderColor") == nil then
        config.set("borderColor", "blue")
    end
    if config.get("arrow") == nil then
        config.set("arrow", "arrow_up.img")
    end
    if config.get("icon") == nil then
        config.set("icon", "gate.img")
    end

    -- Refresh monitors in case of reboot
    signRender.display()

    local w,h = term.getSize()

    main.background = colors.lightGray

    local innerFrame = main:addFrame()
        :setPosition(2,2)
        :setSize(w-2,h-2)

    innerFrame.background = colors.gray

    -- TITLE
    innerFrame:addLabel()
        :setPosition(3,2)
        :setText("Sign Editor")

    -- BORDER COLOR
    local color_dropdown = innerFrame:addDropDown()
        :setPosition(5,5)
    
    color_dropdown.scrollBarColor = colors.lightGray

    loadColors(color_dropdown)

    -- load config value
    color_dropdown:selectNext()
    for i = 1, #COLORS do
        if color_dropdown:getSelectedItem().text == config.get("borderColor") then
            color_dropdown.background = color_dropdown:getSelectedItem().bg
            color_dropdown.foreground = color_dropdown:getSelectedItem().fg
            break
        end
        color_dropdown:selectNext()
    end

    color_dropdown:onSelect(function(self, index, item)
        self.background = item.bg
        self.foreground = item.fg
        config.set("borderColor", item.text)
    end)

    -- SIGN CONTENT
    innerFrame:addInput()
        :setSize(15,1)
        :setPosition(30,5)
        :setText(config.get("signContent"))
        :onSubmit(function(self)
            config.set("signContent", self.text)
        end)

    -- ARROW
    local arrow_display = innerFrame:addDisplay()
        :setSize(8,8)
        :setPosition(9, 7)
        :onClick(function(self, button)
            if button == 1 then
                arrow_idx = (arrow_idx % #arrows) + 1
            elseif button == 2 then
                arrow_idx = ((arrow_idx-2) % #arrows) + 1
            end
            drawGraphic("arrows/" .. arrows[arrow_idx], self:getWindow())
            config.set("arrow", arrows[arrow_idx])
        end)

    local config_arrow = config.get("arrow")
    if config_arrow ~= nil then
        for i, name in ipairs(arrows) do
            if name == config_arrow then
                arrow_idx = i
                break
            end
        end
    end

    drawGraphic("arrows/" .. arrows[arrow_idx], arrow_display:getWindow())

    -- ICON
    local icon_display = innerFrame:addDisplay()
        :setSize(9,8)
        :setPosition(34, 7)
        :onClick(function(self, button)
            if button == 1 then
                icon_idx = (icon_idx % #icons) + 1
            elseif button == 2 then
                icon_idx = ((icon_idx-2) % #icons) + 1
            end
            drawGraphic("icons/" .. icons[icon_idx], self:getWindow())
            config.set("icon", icons[icon_idx])
        end)

    -- load config
    local config_icon = config.get("icon")
    if config_icon ~= nil then
        for i, name in ipairs(icons) do
            if name == config_icon then
                icon_idx = i
                break
            end
        end
    end

    drawGraphic("icons/" .. icons[icon_idx], icon_display:getWindow())


    -- Apply/Save
    innerFrame:addButton()
        :setText("Save & Apply")
        :setBackground(colors.green)
        :setSize(30, 1)
        :setPosition(10, 16)
        :onClick(function(self)
            config.save()
            signRender.display()
        end)

    basalt.run()
end

return signEditor