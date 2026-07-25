local NAME = "FoxSigns"

local files = {
    {url = "https://raw.githubusercontent.com/Pyroxenium/Basalt2/refs/heads/main/release/basalt-full.lua", dest = "basalt.lua"},
    {url = "https://raw.githubusercontent.com/MichielP1807/more-fonts/main/morefonts.lua", dest = "morefonts.lua"},
    {url = "https://raw.githubusercontent.com/michielp1807/more-fonts/refs/heads/main/fonts/Scientifica-Bold", dest = "fonts/science"}
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
    updateText("Downloading " .. url:match("[^/]*$"))

    if not rawData then
        if attempt == 3 then error("Failed to download " .. url .. " after 3 attempts.") end
        updateText("failed to download " .. url .. ". Trying again (attempt " .. attempt .. "/3)")
        return download(url, attempt+1)
    end

    local data = rawData.readAll()

    local file = fs.open(dest, "w+")
    file.write(data)
    file.close()
end

local function downloadAll(downloads, total)
    local nextFile = table.remove(downloads, 1)
    if nextFile then
        sleep(0.1)
        parallel.waitForAll(function() downloadAll(downloads, total) end, function()
            download(nextFile.url, nextFile.dest, 1)
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
    updateText("Complete!")
    sleep(1)

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    term.clear()
    term.setCursorPos(1,1)
end

install()