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

-- Returns current song and steps for player
-- Moving out of Step Statistics StepsInfo.lua
GetSongAndSteps = function(player) 
	-- Return song ID and step data ID
	local song
	local steps
	
	if GAMESTATE:IsCourseMode() then
		local songindex = GAMESTATE:GetCourseSongIndex()
		local trail = GAMESTATE:GetCurrentTrail(player):GetTrailEntries()[songindex+1]
		steps = trail:GetSteps()
		song = trail:GetSong()
	else
		song = GAMESTATE:GetCurrentSong()
		steps = GAMESTATE:GetCurrentSteps(player)			
	end
	
	return song, steps
end

-- Returns array of step artist info
-- Moving out of Step Statistics StepsInfo.lua
getAuthorTable = function(steps)
	-- Returns a table of max 3 rows of step data
	-- like step author, chart artist, tech notation, stream breakdown,  meme quotes
	local desc = steps:GetDescription()
	local author_table = {}
	
	if desc ~= "" then author_table[#author_table+1] = desc end

	local cred = steps:GetAuthorCredit()
	if cred ~= "" and (not FindInTable(cred, author_table)) then author_table[#author_table+1] = cred end

	local name = steps:GetChartName()
	if name ~= "" and (not FindInTable(name, author_table)) then author_table[#author_table+1] = name end

	return author_table
end
