
local mf = require("morefonts")
local config = require ("config")

local monitors = { peripheral.find("monitor") }

config.load("/data/sign.cfg")

local signRender = {}

function signRender.display()
    for _,monitor in ipairs(monitors) do
        monitor.setTextScale(0.5)
        local originalTerm = term.redirect(monitor)
        term.setBackgroundColor(colors.black)
        term.clear()

        local w,h = term.getSize()

        -- BORDER
        paintutils.drawBox(1,1,w,h,colors[config.get("borderColor")])
        
        -- ARROW
        if config.get("arrow") ~= nil then
            local arrow_img = paintutils.loadImage("symbols/arrows/" .. config.get("arrow"))
            if arrow_img ~= nil then
                paintutils.drawImage(arrow_img, 3,3)
            end
        end

        -- ICON
        if config.get("icon") ~= nil then
            local icon_img = paintutils.loadImage("symbols/icons/" .. config.get("icon"))
            if icon_img ~= nil then
                paintutils.drawImage(icon_img, 11, 3)
            end
        end

        -- TEXT
        local text = config.get("signContent")
        if text == nil then
            text = "..."
        end
        term.setBackgroundColor(colors.black)
        mf.writeOn(monitor, text, nil, nil, {
            font = "./fonts/science",
            condense = true,
            dx = 10
        })
        term.redirect(originalTerm)
    end
end

return signRender