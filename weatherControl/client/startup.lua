
local basalt = require("basalt")

local PROTOCOL = "FOXNET"
local msgClear = "CLEAR"
local msgDay = "DAY"
local msgStat = "STATUS"
local msgPing = "PING"

local statusDisplay = nil
local computer = nil

local function statusMessage(message)
    if statusDisplay ~= nil then
        statusDisplay.setText(message)
    end
end

local function discover_server()
    while true do
        while true do
            if not rednet.isOpen("back") then
                rednet.open("back")
            end
            
            statusMessage("Looking up host..")
            computer = rednet.lookUp(PROTOCOL)
            statusMessage("Host not found. Trying again..")
            sleep(1)
        end

    end
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

    local id, response, payload = rednet.receive(PROTOCOL, 5)

    if id == server_id and response then
        return true, response
    else
        return false, nil
    end
end

local function buildUI()
    local main = basalt.getMainFrame()

    statusDisplay = main:addLabel()
        :setPosition(5,5)
end

local function init()
    buildUI()
    local computerID = nil

    while true do
        if not ensure_modem() or not computerID then
            computerID = discover_server()
            if not computerID then
                statusMessage("No host found. Retrying in 5 seconds")
                sleep(5)
                basalt.stop()
                local _ = init()
                return;
            end
        end

        local success, reply = send_request(computerID, msgStat)
        if success then
            statusMessage(reply)
        end
    end
end

init()