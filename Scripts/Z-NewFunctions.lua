-- This file will maybe be used for new functions created for Zarzob/Zankoku's fork of Simply Love

-- Returns an array of files in <directory> of <extension> (defaulting to ogg)
-- Created to play random audio files for song pass/fail/pb/wr
findFiles=function(dir,ext)
	local rawFiles = FILEMAN:GetDirListing(dir,false,true)
	local files = {}
    local ext = ext or "ogg"
	for file in ivalues(rawFiles) do
		local filetype = file:match("[^.]+$"):lower()
		if filetype == ext then table.insert(files,file) end
	end
    return files
end

cleanGSub=function(str, what, with)
	what = what:gsub("[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
	with = with:gsub("[%%]", "%%%%") -- escape replacement
	return str:gsub(what, with)
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

-- Return an array of cumulative_seconds for each song in a course, which used by Step Statistics Time.lua
courseLengthBySong=function(player)
    local cumulative_seconds = {}
    if GAMESTATE:IsCourseMode() then
        local rate = SL.Global.ActiveModifiers.MusicRate
        local seconds = 0
        local trail = GAMESTATE:GetCurrentTrail(player)
    
        if trail then
            local entries = trail:GetTrailEntries()
            for i, entry in ipairs(entries) do
                seconds = seconds + (entry:GetSong():MusicLengthSeconds() / rate)
                table.insert(cumulative_seconds, seconds)
            end
        end
        return cumulative_seconds
    end
end

-- Return the total length of the current song or course, in seconds
totalLengthSongOrCourse=function(player)
    local totalseconds = 0
    if GAMESTATE:IsCourseMode() then
        local trail = GAMESTATE:GetCurrentTrail(player)
        if trail then
            totalseconds = trail:GetLengthSeconds()
        end
    else
        local song = GAMESTATE:GetCurrentSong()
        if song then
            totalseconds = song:GetLastSecond()
        end
    end

    -- totalseconds is initilialzed in the engine as -1
    -- https://github.com/stepmania/stepmania/blob/6a645b4710/src/Song.cpp#L80
    -- and might not have ever been set to anything meaningful in edge cases
    -- e.g. ogg file is 5 seconds, ssc file has 1 tapnote occuring at beat 0
    if totalseconds < 0 then totalseconds = 0 end

    local rate = SL.Global.ActiveModifiers.MusicRate
    totalseconds = totalseconds / rate

    return totalseconds
end

-- Return the current time of the course or song, in seconds
currentTimeSongOrCourse=function(player)
    local playerState = GAMESTATE:GetPlayerState(player)	
    local seconds = 0
    local rate = SL.Global.ActiveModifiers.MusicRate

    -- This doesn't work for course mode yet, it isn't called
    if GAMESTATE:IsCourseMode() then
        -- Find out what song in the course
        local course_index = GAMESTATE:GetCourseSongIndex()

        -- cumulative song length array
        local cumulative_seconds = courseLengthBySong(player)

        -- Add up all the previous songs
        for i=1,course_index do
            seconds = seconds + cumulative_seconds[course_index]
        end

        -- Now add on the current song's timer
        local currentSongTimer = playerState:GetSongPosition():GetMusicSecondsVisible()
        currentSongTimer = currentSongTimer / rate
        seconds = seconds + currentSongTimer
    else
        seconds = playerState:GetSongPosition():GetMusicSecondsVisible()  / rate
    end

    return seconds
end

-- Formatting time from seconds
-- Function not currently provided by ITGmania
SecondsToHMMSS = function(s)
    local hours, mins, secs
    local hmmss = "%d:%02d:%02d"
	-- native floor division sounds nice but isn't available in Lua 5.1
	hours = math.floor(s/3600)
	mins  = math.floor((s % 3600) / 60)
	secs  = s - (hours * 3600) - (mins * 60)
	return hmmss:format(hours, mins, secs)
end