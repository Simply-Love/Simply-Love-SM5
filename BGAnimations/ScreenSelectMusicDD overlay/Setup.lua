local DDStats = LoadActor('./DDStats.lua')

-- You know that spot under the rug where you sweep away all the dirty
-- details and then hope no one finds them?  This file is that spot.
-- The idea is basically to just throw setup-related stuff
-- in here that we don't want cluttering up default.lua
---------------------------------------------------------------------------
-- because no one wants "Invalid PlayMode 7"
GAMESTATE:SetCurrentPlayMode(0)
local SongsInSet = SL.Global.Stages.PlayedThisGame

---------------------------------------------------------------------------
-- local junk
local margin = {
	w = WideScale(54,72),
	h = 30
}

-- FIXME: making numCols and numRows configurable variables made sense when the song select
--  was more grid-like, but groups are now a single row, and songs just go up and down.
local numCols = 3
local numRows = 5

---------------------------------------------------------------------------
-- variables that are to be passed between files

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

local steps_type = GAMESTATE:GetCurrentStyle():GetStepsType()

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

----- Lower Difficulty Filter profile settings ----- 
function GetLowerDifficultyFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'LowerDifficultyFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'LowerDifficultyFilter')
	end

	if value == nil then
		value = 0
	end

	return tonumber(value)
end

----- Upper Difficulty Filter profile settings ----- 
function GetUpperDifficultyFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'UpperDifficultyFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'UpperDifficultyFilter')
	end

	if value == nil then
		value = 0
	end

	return tonumber(value)
end

----- Lower BPM Filter profile settings ----- 
function GetLowerBPMFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'LowerBPMFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'LowerBPMFilter')
	end

	if value == nil then
		value = 49
	end

	return tonumber(value)
end


----- Upper BPM Filter profile settings ----- 
function GetUpperBPMFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'UpperBPMFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'UpperBPMFilter')
	end

	if value == nil then
		value = 49
	end

	return tonumber(value)
end


----- Lower Length Filter profile settings ----- 
function GetLowerLengthFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'LowerLengthFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'LowerLengthFilter')
	end

	if value == nil then
		value = 0
	end

	return tonumber(value)
end

----- Upper Length Filter profile settings ----- 
function GetUpperLengthFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'UpperLengthFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'UpperLengthFilter')
	end
	
	return tonumber(value)
end

local PruneSongsFromGroup = function(group)
	local songs = {}
	local current_song = GAMESTATE:GetCurrentSong()
	local index = 1

	-- prune out songs that don't have valid steps or fit the filters
	for i,song in ipairs(SONGMAN:GetSongsInGroup(group)) do
		-- this should be guaranteed by this point, but better safe than segfault
		
		if song:HasStepsType(steps_type) then
			local passesFilters = true
			--- Filter for Length
			if GetLowerLengthFilter() ~= 0 then
				if GetLowerLengthFilter() > song:MusicLengthSeconds() then
					passesFilters = false
				end
			end

			if GetUpperLengthFilter() ~= 0 then
				if GetUpperLengthFilter() < song:MusicLengthSeconds() then
					passesFilters = false
				end
			end
			
			--- Filter for BPM (NPS)
			--[[if GetLowerBPMFilter() ~= 49 or GetUpperBPMFilter() ~= 49 then
				for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
					local GetStepsNPS = GetNPSperMeasure(GAMESTATE:GetCurrentSong(),GAMESTATE:GetCurrentSteps())
					local TrueChartBPM = ((GetStepsNPS / 16) * 240)
					if GetLowerBPMFilter() ~= 49 then
						if TrueChartBPM < GetLowerBPMFilter() then
							passesFilters = false
						end
					end
					if GetUpperBPMFilter() ~= 49 then
						if TrueChartBPM > GetUpperBPMFilter() then
							passesFilters = false
						end
					end
				end
			end--]]
			
			---- Filter for Difficulty
			if GetLowerDifficultyFilter() ~= 0 or GetUpperDifficultyFilter() ~= 0 then
				local hasPassingDifficulty = false
				for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
					local passesLower = GetLowerDifficultyFilter() == 0 or steps:GetMeter() >= GetLowerDifficultyFilter()
					local passesUpper = GetUpperDifficultyFilter() == 0 or steps:GetMeter() <= GetUpperDifficultyFilter()
					if passesLower and passesUpper then
						hasPassingDifficulty = true
					end
				end
				if not hasPassingDifficulty then
					passesFilters = false
				end
			end
			
			if passesFilters then
				songs[#songs+1] = song
			end
			
		end
		-- we need to retain the index of the current song so we can set the SongWheel to start on it
		if current_song == song then 
			index = #songs
		else end
	end

	return songs, index
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------

function GetGroovestatsFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'GroovestatsFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'GroovestatsFilter')
	end

	if value == nil then
		value = 'No'
	end

	return value
end

local GetGroups = function()
	if GetGroovestatsFilter() == 'Yes' then
		local path = THEME:GetCurrentThemeDirectory() .. "Other/Groovestats-Groups.txt"
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
		end
	elseif GetGroovestatsFilter() == 'No' then
		return SONGMAN:GetSongGroupNames()
	end
end

---------------------------------------------------------------------------

-- First looks to DDStats for the default song and if it doesn't exist it will look at the stats.xml
-- since the DD GameMode can't rely on SM to save LastPlayedSong. If neither exist then it defaults 
-- to the 1st song in the 1st folder.

local GetDefaultSong = function(groups)
	local songs = {}
	local playerNum
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		playerNum = PLAYER_1
	else
		playerNum = PLAYER_2
	end
	
	local lastSong = DDStats.GetStat(playerNum, 'LastSong')
	if lastSong ~= nil then
		for i, song in ipairs(SONGMAN:GetAllSongs(songs)) do
			if song:GetSongDir() == lastSong then
				return song
			end
		end
	end
	
	local Profile = PROFILEMAN:GetProfile(playerNum)
	local LastSong = Profile:GetLastPlayedSong()

	if Profile and LastSong then
		return LastSong
	else
		return PruneSongsFromGroup( groups[1] )[1]
	end

end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- prune out groups that have no valid steps
-- passed an indexed table of strings representing potential group names
-- returns an indexed table of group names as strings



local PruneGroups = function(_groups)
	local groups = {}
	local info = {}
	
	for group in ivalues( _groups ) do
		local group_has_been_added = false
		local songs = PruneSongsFromGroup(group)
		info[group] = {}
		info[group].num_songs = #songs
		
		for song in ivalues(SONGMAN:GetSongsInGroup(group)) do
			--- If a pack has no songs in it after filtering don't show it, otherwise carry on.
			if #songs ~= 0 then
				if song:HasStepsType(steps_type) then

					for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
							groups[#groups+1] = group
							group_has_been_added = true
							break
					end
				end
				if group_has_been_added then break end
			else end
		end
	end
	return groups
end

---------------------------------------------------------------------------



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
			if charts[difficulty] == nil then charts[difficulty] = 0 end
			info[group].charts = info[group].charts .. charts[difficulty] .. " " .. THEME:GetString( "CustomDifficulty", ToEnumShortString(difficulty) ) .. "\n"
		end

	end
	return info
end

---------------------------------------------------------------------------


local current_song = GAMESTATE:GetCurrentSong()
local group_index = 1

IsCurrentSongValid = function(groups)
	if GetDefaultSong(groups) ~= current_song or GetDefaultSong(groups) == nil then
		current_song = PruneSongsFromGroup( groups[1] )[1]
		GAMESTATE:SetCurrentSong(current_song)
	else
		current_song = GetDefaultSong(groups)
		GAMESTATE:SetCurrentSong(current_song)	
	end
end

local groups = GetGroups()
-- prune the list of potential groups down to valid groups

if GetGroovestatsFilter() == 'No' then
	groups = PruneGroups(SONGMAN:GetSongGroupNames())
elseif GetGroovestatsFilter() == 'Yes' then
	groups = PruneGroups(groups)
end

-- If there are STILL no valid groups, we aren't going to find any.
-- return nil, which default.lua will interpret to mean the
-- player needs to be informed that this machine has no suitable content...  D:
if #groups == 0 then
	return nil
end

-- there will be a current_song if we're on stage 2 or later
if current_song == nil then
	current_song = GetDefaultSong(groups)
	GAMESTATE:SetCurrentSong(current_song)
end

SCREENMAN:SystemMessage(tostring(GAMESTATE:GetCurrentSong()))

group_index = FindInTable(current_song:GetGroupName(), groups) or 1

return {
	steps_type=steps_type,
	Groups=groups,
	group_index=group_index,
	row=row,
	col=col,
	InitOptionRowsForSingleSong=InitOptionRowsForSingleSong,
	group_info=GetGroupInfo(groups),
	PruneSongsFromGroup=PruneSongsFromGroup
}