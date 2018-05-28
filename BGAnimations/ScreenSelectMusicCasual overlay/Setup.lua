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

for player in ivalues(GAMESTATE:GetHumanPlayers()) do
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
-- there has got to be a better way to do this...
local steps_type = "StepsType_"..GAMESTATE:GetCurrentGame():GetName():gsub("^%l", string.upper).."_"
if GAMESTATE:GetCurrentStyle():GetName() == "double" then
	steps_type = steps_type .. "Double"
else
	steps_type = steps_type .. "Single"
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

local GetDefaultSong = function(Groups)

	local path = THEME:GetCurrentThemeDirectory() .. "Other/CasualMode-DefaultSong.txt"
	local preliminary_songs = GetFileContents(path)

	-- the file was empty or doesn't exist, return the first song in the first group
	if preliminary_songs == nil or #preliminary_songs == 0 then
		return SONGMAN:GetSongsInGroup(Groups[1])[1]
	end

	-- verify that the song(s) specified actually exist
	local songs = {}
	for prelim_song in ivalues(preliminary_songs) do
		-- parse the group out of the prelim_song string to verify this song
		-- exists within a permitted group
		local _group = prelim_song:gsub("/[%w%s]*", "")

		-- if this song exists and is part of a group returned by PruneGroups()
		if SONGMAN:FindSong( prelim_song ) and FindInTable(_group, Groups) then
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

	-- fall back on first song from first group if needed
	return SONGMAN:GetSongsInGroup(Groups[1])[1]
end


---------------------------------------------------------------------------
-- prune out groups that have no valid steps
-- returns an indexed table of group names as strings

local PruneGroups = function()
	local groups = {}

	for group in ivalues( GetGroups() ) do
		local group_has_been_added = false

		for song in ivalues(SONGMAN:GetSongsInGroup(group)) do
			if song:HasStepsType(steps_type) then

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

local current_song = GAMESTATE:GetCurrentSong()
local group_index = 1
local Groups = PruneGroups()

-- there will be a current_song if this is stage 2 or later
if current_song then
	group_index = FindInTable(current_song:GetGroupName(), Groups) or 1

-- if no current_song, check ./Other/CasualMode-DefaultSong.txt
else
	current_song = GetDefaultSong(Groups)
	GAMESTATE:SetCurrentSong(current_song)
end

return {steps_type=steps_type, Groups=Groups, group_index=group_index, OptionsWheel=OptionsWheel, OptionRows=OptionRows, row=row, col=col}