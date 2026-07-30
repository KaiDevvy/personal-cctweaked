
local basalt = require("basalt")

local PROTOCOL = "FOXNET"
local HOSTNAME = "MANIPULATOR"
local msgClear = "CLEAR"
local msgDay = "DAY"
local msgStat = "STATUS"

local main = nil
local statusDisplay = nil
local computerID = nil

local pendingAction = nil

local function formatTime12h(hours)

    local hour24 = math.floor(hours)
    local minute = math.floor((hours - hour24) * 60)

    local period = hour24 < 12 and "AM" or "PM"
    local hour12 = hour24 % 12
    if hour12 == 0 then hour12 = 12 end

    return string.format("%d:%02d %s", hour12, minute, period)
end

local function statusMessage(message)
    if statusDisplay ~= nil then
        statusDisplay:setText(message)
        statusDisplay:setPosition(0,4)
        statusDisplay:centerHorizontal(main)
    else
        print("No status")
    end
end

local function discover_server()
    local ids = { rednet.lookup(PROTOCOL, HOSTNAME) }

    if #ids > 0 then
        return ids[1]
    end
    return nil
end

local function ensure_modem()
    if rednet.isOpen() then return true end

    for _, side in ipairs(rs.getSides()) do
        if peripheral.getType(side) == "modem" then
            rednet.open(side)
            return true
        end
    end
    return false
end

local function send_request(server_id, message)
    if not ensure_modem() then
        return false, nil
    end

    local payload = {
        message = message,
        timestamp = os.epoch("utc")
    }

    rednet.send(server_id, payload, PROTOCOL)

    local id, response, protocol = rednet.receive(PROTOCOL, 5)

    if id == server_id and response and protocol == PROTOCOL then
        return true, response
    else
        return false, nil
    end
end

local function buildUI()
    local w,h = term.getSize()

    main = basalt.getMainFrame()

    statusDisplay = main:addLabel()
        :setText("")

    main:addButton()
        :setText("Clear")
        :setSize(10, 10)
        :setPosition(2, 10)
        :onClick(function()
            pendingAction = msgClear
        end)

    main:addButton()
        :setText("Day")
        :setSize(10, 10)
        :setPosition(20-4, 10)
        :onClick(function()
            pendingAction = msgDay
        end)
end

local function logic_loop()
    statusMessage("Connecting..")
    while true do
        if not ensure_modem() or not computerID then
            computerID = discover_server()
            if not computerID then
                statusMessage("Retrying..")
                sleep(5)
                goto continue
                return;
            end
        end

        statusMessage(formatTime12h(os.time()))
        
        if pendingAction then
            local action = pendingAction
            pendingAction = nil;
            statusMessage("Request Sent!")
            local success, reply = send_request(computerID, action)
        end

        sleep(0.1)

        ::continue::
    end
end

local function init()
    buildUI()
    parallel.waitForAny(
        function() basalt.run() end,
        logic_loop
    )
end

init()