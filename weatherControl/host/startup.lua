


local PROTOCOL = "FOXNET"
local HOST_NAME = "MANIPULATOR"

local function formatTime12h(ticks)
    local hoursDecimal = (ticks / 1000 + 6) % 24

    local hour24 = math.floor(hoursDecimal)
    local minute = math.floor((hoursDecimal - hour24) * 60)

    local period = hour24 < 12 and "AM" or "PM"
    local hour12 = hour24 % 12
    if hour12 == 0 then hour12 = 12 end

    return string.format("%d:%02d %s", hour12, minute, period)
end

local function init_rednet()
    for _, side in  ipairs(rs.getSides()) do
        if peripheral.getType(side) == "modem" then
            if not rednet.isOpen(side) then
                rednet.open(side)
                print("Rednet Launched")
            end

            rednet.host(PROTOCOL, HOST_NAME)
            print("Hosting " .. HOST_NAME .. " under protocol " .. PROTOCOL)
            return true
        end
    end
    print("Error: No modem detected!")
    return false
end

local function start_server()
    print("Server ready! Listening for requests..")
    while true do
        if not rednet.isOpen() then
            print("Connection lost! Attempting to reconnect..")
            while not init_rednet() do
                print("Failed, retrying in 5 seconds..")
                sleep(5)
            end
        end


        local sender_id, payload, protocol = rednet.receive(PROTOCOL)

        if protocol == PROTOCOL then
            if type(payload) == "table" then
                if payload.message == "STATUS" then
                    rednet.send(sender_id, formatTime12h(os.time()), PROTOCOL)
                elseif payload.message == "CLEAR" then
                    print(sender_id .. ": Set weather to clear")
                    print(PROTOCOL)
                    rednet.send(sender_id, "Setting to clear", PROTOCOL)
                    redstone.setOutput("right", true)
                    sleep(0.5)
                    redstone.setOutput("right", false)
                elseif payload.message == "DAY" then
                    print(sender_id .. ": Set time to day")
                    rednet.send(sender_id, "Setting to day", PROTOCOL)
                    redstone.setOutput("left", true)
                    sleep(0.5)
                    redstone.setOutput("left", false)
                end
            end
        end
    end
end

if init_rednet() then
    start_server()
end