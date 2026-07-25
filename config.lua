

local config = {}

local properties = {}
local currentFile = nil

local function parseLine(line)
    local key, value = line:match("^([^=]+)=(.*)$")
    if key then
        return key, value
    end
    return nil
end

function config.load(filename)
    currentFile = filename
    properties = {}

    if not fs.exists(filename) then
        return true
    end

    local file = fs.open(filename, "r")
    if not file then
        return false
    end

    local line = file.readLine()
    while line do
        local k,v = parseLine(line)
        if k then
            properties[k] = v
        end
        line = file.readLine()
    end

    file.close()
    return true
end

function config.save(filename)
    filename = filename or currentFile
    if not filename then
        error("config.save: no filename given or loaded")
    end

    local file = fs.open(filename, "w+")
    if not file then
        return false
    end

    for k,v in pairs(properties) do
        if v ~= nil then
            file.writeLine(k .. "=" .. v)
        end
    end

    file.close()
    return true
end

function config.get(key)
    return properties[key]
end

function config.set(key, value)
    properties[key] = value
end

return config