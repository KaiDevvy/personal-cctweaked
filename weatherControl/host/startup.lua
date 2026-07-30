local NAME = "Fox's Signs"

local urls = {
    basalt = "https://raw.githubusercontent.com/Pyroxenium/Basalt2/refs/heads/main/release/",
    kaifox = "https://raw.githubusercontent.com/KaiDevvy/personal-cctweaked/refs/heads/main/weatherControl/host/"
}

local files = {
    {url = urls["basalt"], file = "basalt-full.lua", rename = "basalt.lua"},
    {url = urls["kaifox"], file = "startup.lua" },
}

local w,h = term.getSize()
local totalDownloaded = 0

local function progressBar(amount)
    local PADDING = 5
    local width = w - PADDING * 2
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.blue)
    term.setCursorPos(PADDING,11)
    for i = PADDING, width+PADDING do
        if (i/width < amount) then
            write("#")
        else
            write(" ")
        end
    end
end

local function updateText(text)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.setCursorPos(1,9)
    term.clearLine()
    term.setCursorPos(math.floor(w/2 - string.len(text) / 2 + 0.5), 9);
    write(text);
end

local function download(url, dest, attempt)
    local rawData = http.get(url)
    local fileName = url:match("[^/]*$")
    updateText("Downloading " .. fileName)

    if not rawData then
        if attempt == 3 then error("Failed to download " .. url .. " after 3 attempts.") end
        updateText("failed to download " .. url .. ". Trying again (attempt " .. attempt .. "/3)")
        return download(url, attempt+1)
    end

    local destination = dest
    if destination == nil or destination == "" then
        destination = fileName
    end
    if string.sub(destination,-1) == "/" then
        destination = destination .. fileName
    end
    updateText(destination)

    local data = rawData.readAll()

    local file = fs.open(destination, "w+")
    file.write(data)
    file.close()
end

local function downloadAll(downloads, total)
    local nextFile = table.remove(downloads, 1)
    if nextFile then
        sleep(0.1)
        parallel.waitForAll(function() downloadAll(downloads, total) end, function()
            local destination = ""
            if nextFile.dest ~= nil then
                destination = destination .. nextFile.dest
            end
            if nextFile.rename ~= nil then
                destination = destination .. nextFile.rename
            end
            download(nextFile.url .. nextFile.file, destination, 1)
            totalDownloaded = totalDownloaded + 1
            progressBar(totalDownloaded / total)
        end)
    end
end

local function install()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.blue)
    term.clear()

    term.setCursorPos(math.floor(w/2 - #NAME/2 + 0.5), 2)
    write(NAME)

    updateText("Installing Dependencies..")
    progressBar(0)

    downloadAll(files, #files)

    progressBar(100)
    updateText("Complete! Starting now..")
    sleep(1)

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    term.clear()
    term.setCursorPos(1,1)
    os.reboot()
end

install()