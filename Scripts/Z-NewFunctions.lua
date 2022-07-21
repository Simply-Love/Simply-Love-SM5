-- This file will maybe be used for new functions created by Zarzob/Zankoku's fork of Simply Love

-- Returns an array of files named <number>.<extension> in <directory>
-- Created to play random audio files for song pass/fail/pb/wr
findFiles=function(dir,extension)
    local iterate = true
    local i = 1
    local files = {}
    while iterate do
        local file = dir .. i .. "." .. extension
        if FILEMAN:DoesFileExist(file) then 
            table.insert(files,file)
        else
            iterate = false
        end
        i = i + 1
    end
    return files
end