-- You know that spot under the rug where you sweep away all the dirty
-- details and then hope no one finds them?  This file is that spot.
--
-- The idea is basically to just throw setup-related stuff
-- in here that we don't want cluttering up default.lua
---------------------------------------------------------------------------
-- because no one wants "Invalid PlayMode 7"
GAMESTATE:SetCurrentPlayMode(0)

---------------------------------------------------------------------------
-- local junk
local margin = {
	w = WideScale(54,72),
	h = 30
}

local numCols = 3
local numRows = 5

---------------------------------------------------------------------------
-- variables that are to be passed between files
local OptionsWheel = {}

-- simple option definitions
local OptionRows = LoadActor("./OptionRows.lua")

for player in ivalues( {PLAYER_1, PLAYER_2} ) do
	-- create the optionwheel for this player
	OptionsWheel[player] = setmetatable({disable_wrapping = true}, sick_wheel_mt)

	-- set up each optionrow for each optionwheel
	for i=1,#OptionRows do
		OptionsWheel[player][i] = setmetatable({}, sick_wheel_mt)
	end
end

local col = {
	how_many = numCols,
	w = (_screen.w/numCols) - margin.w,
}
local row = {
	how_many = numRows,
	h = ((_screen.h - (margin.h*(numRows-2))) / (numRows-2)),
}

---------------------------------------------------------------------------
-- a steps_type like "StepsType_Dance_Single" is needed so we can filter out steps that aren't suitable
-- (there has got to be a better way to do this...)
local game_name = GAMESTATE:GetCurrentGame():GetName()
local style

if GAMESTATE:GetCurrentStyle():GetName() == "double" then
	style = "Double"
else
	-- "single" and  "versus" both map to "Single" here
	style = "Single"
end

local steps_type = "StepsType_"..game_name:gsub("^%l", string.upper).."_"..style

-- techno is a special case with steps_type like "StepsType_Techno_Single8"
if game_name == "techno" then steps_type = steps_type.."8" end



---------------------------------------------------------------------------
-- initializes sick_wheel OptionRows for the CurrentSong with needed information
-- this function is called when choosing a song, either actively (pressing START)
-- or passively (MenuTimer running out)

local InitOptionRowsForSingleSong = function()
	local steps = {}
	-- prune out charts whose meter exceeds the specified max
	for chart in ivalues(SongUtil.GetPlayableSteps( GAMESTATE:GetCurrentSong() )) do
		if chart:GetMeter() <= ThemePrefs.Get("CasualMaxMeter") then
			steps[#steps+1] = chart
		end
	end

	OptionRows[1].choices = steps

	for pn in ivalues( {PLAYER_1, PLAYER_2} ) do
		OptionsWheel[pn]:set_info_set( OptionRows, 1)

		for i=1,#OptionRows do
			OptionsWheel[pn][i]:set_info_set( OptionRows[i].choices, 1)
		end
	end
end


---------------------------------------------------------------------------
-- helper function used by GetGroups() and GetDefaultSong()
-- returns the contents of a txt file as an indexed table, split on newline

local GetFileContents = function(path)
	local contents = ""

	if FILEMAN:DoesFileExist(path) then
		-- create a generic RageFile that we'll use to read the contents
		local file = RageFileUtil.CreateRageFile()
		-- the second argument here (the 1) signifies
		-- that we are opening the file in read-only mode
		if file:Open(path, 1) then
			contents = file:Read()
		end

		-- destroy the generic RageFile now that we have the contents
		file:destroy()
	end

	-- split the contents of the file on newline
	-- to create a table of lines as strings
	local lines = {}
	for line in contents:gmatch("[^\r\n]+") do
		lines[#lines+1] = line
	end

	return lines
end

---------------------------------------------------------------------------
-- provided a group title as a string, prune out songs that don't have valid steps
-- returns an indexed table of song objects

local PruneSongsFromGroup = function(group)
	local songs = {}

	-- prune out songs that don't have valid steps
	for i,song in ipairs(SONGMAN:GetSongsInGroup(group)) do
		-- this should be guaranteed by this point, but better safe than segfault
		if song:HasStepsType(steps_type)
		-- respect StepMania's cutoff for 1-round songs
		and song:MusicLengthSeconds() < PREFSMAN:GetPreference("LongVerSongSeconds") then
			-- ensure that at least one stepchart has a meter ≤ CasualMaxMeter (10, by default)
			for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
				if steps:GetMeter() <= ThemePrefs.Get("CasualMaxMeter") then
					songs[#songs+1] = song
					break
				end
			end
		end
	end

	return songs
end

---------------------------------------------------------------------------
-- parse ./Other/CasualMode-Groups.txt to find which groups will appear in SSMCasual
-- returns an indexed table of group names as strings

local GetGroups = function()
	local path = THEME:GetCurrentThemeDirectory() .. "Other/CasualMode-Groups.txt"
	local preliminary_groups = GetFileContents(path)

	-- if the file didn't exist or was empty or contained no valid groups,
	-- return the full list of groups available to SM
	if preliminary_groups == nil or #preliminary_groups == 0 then
		return SONGMAN:GetSongGroupNames()
	end

	local groups = {}
	-- some Groups found in the file may not actually exist due to human error, typos, etc.
	for prelim_group in ivalues(preliminary_groups) do
		-- if this group exists
		if SONGMAN:DoesSongGroupExist( prelim_group ) then
			-- add this preliminary group to the table of finalized groups
			groups[#groups+1] = prelim_group
		end
	end

	if #groups > 0 then
		return groups
	else
		return SONGMAN:GetSongGroupNames()
	end
end

---------------------------------------------------------------------------
-- parse ./Other/CasualMode-DefaultSong.txt to find one or more songs to
-- default to when SSNCasual first loads
-- returns a song object

local GetDefaultSong = function(groups)

	local path = THEME:GetCurrentThemeDirectory() .. "Other/CasualMode-DefaultSong.txt"
	local preliminary_songs = GetFileContents(path)

	-- the file was empty or doesn't exist, return the first song in the first group
	if preliminary_songs == nil or #preliminary_songs == 0 then
		return SONGMAN:GetSongsInGroup(groups[1])[1]
	end

	-- verify that the song(s) specified actually exist
	local songs = {}
	for prelim_song in ivalues(preliminary_songs) do
		-- parse the group out of the prelim_song string to verify this song
		-- exists within a permitted group
		local _group = prelim_song:gsub("/[%w%s]*", "")

		-- if this song exists and is part of a group returned by PruneGroups()
		if SONGMAN:FindSong( prelim_song ) and FindInTable(_group, groups) then
			-- add this prelim_song to the table of songs that do exist
			songs[#songs+1] = prelim_song
		end
	end


	-- if multiple valid songs were found, randomly select and return one
	if #songs >= 2 then
		local song = SONGMAN:FindSong( songs[math.random(1, #songs)] )
		if song then return song end

	-- if DefaultSong.txt only contained one song, return that
	elseif #songs == 1 then
		local song = SONGMAN:FindSong( songs[1] )
		if song then return song end
	end

	-- fall back on first valid song from first valid group if needed
	return PruneSongsFromGroup( groups[1] )[1]
end


---------------------------------------------------------------------------
-- prune out groups that have no valid steps
-- passed an indexed table of strings representing potential group names
-- returns an indexed table of group names as strings

local PruneGroups = function(_groups)
	local groups = {}

	for group in ivalues( _groups ) do
		local group_has_been_added = false

		for song in ivalues(SONGMAN:GetSongsInGroup(group)) do
			if song:HasStepsType(steps_type)
			and song:MusicLengthSeconds() < PREFSMAN:GetPreference("LongVerSongSeconds") then

				for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
					if steps:GetMeter() < ThemePrefs.Get("CasualMaxMeter") then
						groups[#groups+1] = group
						group_has_been_added = true
						break
					end
				end
			end
			if group_has_been_added then break end
		end
	end

	return groups
end

---------------------------------------------------------------------------
-- currently not used

local GetGroupInfo = function(groups)
	local info = {}
	for group in ivalues(groups) do
		local songs = PruneSongsFromGroup(group)
		local artists, genres, charts = {}, {}, {}

		info[group] = {}
		info[group].num_songs = #songs
		info[group].artists = ""
		info[group].genres = ""
		info[group].charts = ""

		for song in ivalues(songs) do
			if #artists < 5 then
				if song:GetDisplayArtist() ~= "" then
					artists[#artists+1] = song:GetDisplayArtist()
				end
			end

			if #genres < 5 then
				if song:GetGenre() ~= "" then
					genres[#genres+1] = song:GetGenre()
				end
			end

			for i,difficulty in ipairs(Difficulty) do
				-- don't care about edits
				if i>5 then break end
				if charts[difficulty] == nil then charts[difficulty] = 0 end

				if song:HasStepsTypeAndDifficulty(steps_type, difficulty) then
					charts[difficulty] = charts[difficulty] + 1
				end
			end
		end

		for i, a in ipairs(artists) do
			info[group].artists = info[group].artists .. "• " .. a .. (i ~= #artists and "\n" or "")
		end
		for i, g in ipairs(genres) do
			info[group].genres = info[group].genres .. "• " .. g .. (i ~= #genres and "\n" or "")
		end
		for i,difficulty in ipairs(Difficulty) do
			if i>5 then break end
			info[group].charts = info[group].charts .. charts[difficulty] .. " " .. THEME:GetString( "CustomDifficulty", ToEnumShortString(difficulty) ) .. "\n"
		end

	end
	return info
end

---------------------------------------------------------------------------


local current_song = GAMESTATE:GetCurrentSong()
local group_index = 1

-- GetGroups() will read from ./Other/CasualMode-Groups.txt
local groups = GetGroups()
-- prune the list of potential groups down to valid groups
groups = PruneGroups(groups)

-- it's possible the list that GetGroups() was too limited and we
-- just pruned the table to be completely empty
-- in that case, try again using ALL groups available to StepMania
if #groups == 0 then
	groups = PruneGroups(SONGMAN:GetSongGroupNames())
end

-- If there are STILL no valid groups, we aren't going to find any.
-- return nil, which default.lua will interpret to mean the
-- player needs to be informed that this machine has no suitable
-- casual content...  D:
if #groups == 0 then
	return nil
end

-- there will be a current_song if we're on stage 2 or later
-- if no current_song, check ./Other/CasualMode-DefaultSong.txt
if current_song == nil then
	current_song = GetDefaultSong(groups)
	GAMESTATE:SetCurrentSong(current_song)
end

group_index = FindInTable(current_song:GetGroupName(), groups) or 1

-- local group_info = GetGroupInfo(groups)

return {
	steps_type=steps_type,
	Groups=groups,
	group_index=group_index,
	group_info=group_info,
	OptionsWheel=OptionsWheel,
	OptionRows=OptionRows,
	row=row,
	col=col,
	InitOptionRowsForSingleSong=InitOptionRowsForSingleSong,
}