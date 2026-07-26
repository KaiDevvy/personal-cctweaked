
local speaker = peripheral.find("speaker")
local dfpwm = require("cc.audio.dfpwm")


local playing = false

local music = {}

local function audioLoop()
    while true do
        if playing then
            local decoder = dfpwm.make_decoder()

            for chunk in io.lines("data/songs/elevator.dfpwm", 16 * 1024) do
                if not playing then break end
                
                local buffer = decoder(chunk)

                while playing and not speaker.playAudio(buffer) do
                    os.pullEvent("speaker_audio_empty")
                end
            end

            playing = false
        else
            os.pullEvent("music_play")
        end
    end
end

function music.play()
    if not playing then
        playing = true
        os.queueEvent("music_play")
    end
end

function music.stop()
    playing = false
    speaker.stop()
    os.queueEvent("speaker_audio_empty")
end


music.loop = audioLoop

return music