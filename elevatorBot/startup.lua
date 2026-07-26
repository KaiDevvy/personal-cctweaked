
local music = require("music")

local displayText = {
    "Fox Elevator Bot(tm)",
    "",
    "",
    "",
    "Running!",
    "",
    "Make sure to load some coal into",
    "the slots on the right!"
}

local function drawHorizontalCenter(text, y)
    local w,h = term.getSize()
    term.setCursorPos(math.floor((w - #text)/2)+1, y)
    term.write(text)
end

term.clear()
local w,h = term.getSize()
for i = 1, #displayText do
    local line = displayText[i]
    drawHorizontalCenter(line, (math.floor(h/2)-4)+i)
end

parallel.waitForAny(
    function()
        while true do
            -- REFUEL
            if turtle.getFuelLevel() < 20000 then
                turtle.refuel()
            end
            drawHorizontalCenter("(" .. tostring(turtle.getFuelLevel()) .. "/20000)", h-1)
            
            -- WAIT FOR ELEVATOR NODE TO UNPOWER
            if not redstone.getInput("right") then

                music.play()

                -- MOVE UNTIL BLOCKED
                if turtle.detectDown() then
                    while turtle.up() do
                    end
                else
                    while turtle.down() do
                    end
                end

                music.stop()
            else
                os.pullEvent("redstone")
            end
        end
    end,
    music.loop
)
