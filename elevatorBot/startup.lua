
local music = require("music")

parallel.waitForAny(
    function()
        while true do
            -- REFUEL
            if turtle.getFuelLevel() < 80000 then
                turtle.refuel()
            end
            
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
            end
        end
    end,
    music.loop
)