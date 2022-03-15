local max_length_group = '1:00:00+'
local max_difficulty_group = '40+'
local max_bpm_group = '400+'

local song_lengths = {}
for i=0,90-1,30 do
	song_lengths[#song_lengths+1] = i
end
for i=90,5*60-10,5 do
	song_lengths[#song_lengths+1] = i
end
for i=5*60,10*60-60,30 do
	song_lengths[#song_lengths+1] = i
end
for i=10*60,30*60-60,60*5 do
	song_lengths[#song_lengths+1] = i
end
for i=30*60,60*60-10*60,10*60 do
	song_lengths[#song_lengths+1] = i
end
song_lengths[#song_lengths+1] = 60*60


local function GetMaxIndexBelowOrEqual(values, exact_value)
	local min_index = 1
	local max_index = #values

	while min_index < max_index do
		local mid_index = math.floor((min_index + max_index+1)/2)
		local song_length = values[mid_index]
		if song_length <= exact_value then
			min_index = mid_index
		else
			max_index = mid_index-1
		end
	end

	return min_index
end

local GetSongLengthGroup = function(song)
	local steps_type = GAMESTATE:GetCurrentStyle():GetStepsType()
	local exact_length = song:GetTotalSeconds(steps_type)
	if exact_length == nil then
		return '???'
	end
	
	local index = GetMaxIndexBelowOrEqual(song_lengths, exact_length)

	if index == #song_lengths then
		return max_length_group
	else
		return SecondsToMMSS(song_lengths[index])
			.. ' - '
			.. SecondsToMMSS(song_lengths[index+1] - 1)
	end
end

local song_bpms = {}
for i=0,400,10 do
	song_bpms[#song_bpms+1] = i
end

local function GetSongBpmGroup(course)
	local exact_bpm = 0
	for trail in ivalues(course:GetAllTrails()) do
		local mpn = GAMESTATE:GetMasterPlayerNumber()
		local bpms = GetDisplayBPMs(mpn, trail)
		if bpms ~= nil then
			exact_bpm = math.round(bpms[2])
		else
			exact_bpm = 0
			-- SM('uh oh ' .. course:GetDisplayFullTitle())
		end
		break
	end
	local index = GetMaxIndexBelowOrEqual(song_bpms, exact_bpm)

	if index == #song_bpms then
		return max_bpm_group
	else
		return song_bpms[index] .. ' - ' .. (song_bpms[index+1] - 1)
	end
end

-- You know that spot under the rug where you sweep away all the dirty
-- details and then hope no one finds them?  This file is that spot.
-- The idea is basically to just throw setup-related stuff
-- in here that we don't want cluttering up default.lua
---------------------------------------------------------------------------
-- because no one wants "Invalid PlayMode 7"
GAMESTATE:SetCurrentPlayMode(1)
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

local GetPlayableTrails = function(course)
	if not (course and course.GetAllTrails) then return nil end

	local trails = {}
	for _,trail in ipairs(course:GetAllTrails()) do
		local playable = true
		for _,entry in ipairs(trail:GetTrailEntries()) do
			if not SongUtil.IsStepsTypePlayable(entry:GetSong(), entry:GetSteps():GetStepsType()) then
				playable = false
				break
			end
		end
		if playable then table.insert(trails, trail) end
	end

	return trails
end

local function GetCourseGroups(course)
	local group = course:GetGroupName()
	if group ~= nil and group ~= "" then
		return group
	else
		return "Ungrouped Courses"
	end
end

local function LetterToGroup(letter)
	if 'A' <= letter and letter <= 'Z' then
		return letter
	elseif '0' <= letter and letter <= '9' then
		return '#'
	else
		return 'Other'
	end
end

local function GetSongFirstLetter(song)
	local letter = song:GetDisplayFullTitle():sub(1,1):upper()
	return LetterToGroup(letter)
end

function GetStepsDifficultyGroup(trail)
	local meter = trail:GetMeter()
	if meter >= 40 then return max_difficulty_group end
	return meter
end

local GroupSongsBy = function(func)
	grouped_songs = {}

	for song in ivalues(SONGMAN:GetAllCourses(PREFSMAN:GetPreference("AutogenGroupCourses"))) do
		local song_group = func(song)

		if grouped_songs[song_group] == nil then
			grouped_songs[song_group] = {song}
		else
			local songs = grouped_songs[song_group]
			songs[#songs+1] = song
		end
	end

	return grouped_songs
end


local function GetHighestDifficulty(group, song)
	local difficulty = 0
	for steps in ivalues(song:GetStepsByStepsType(GAMESTATE:GetCurrentStyle():GetStepsType())) do
		difficulty = math.max(difficulty, steps:GetMeter())
	end
	return difficulty
end

local function GetStepCount(group, song)
	local count = 0
	local mpn = GAMESTATE:GetMasterPlayerNumber()

	for steps in ivalues(song:GetStepsByStepsType(GAMESTATE:GetCurrentStyle():GetStepsType())) do
		local steps_count = steps:GetRadarValues(mpn):GetValue('RadarCategory_TapsAndHolds')
		if GetMainCourseSortPreference() ~= 6 or GetStepsDifficultyGroup(steps) == group then
			return steps_count
		end
		count = math.max(count, steps_count)
	end
	
	return count
end

local subsort_funcs = {
	function(g, s) return s:GetGroupName() end,
	function(g, s) return s:GetDisplayFullTitle():lower() end,
	function(g, s) return s:MusicLengthSeconds() end,
	function(g, s) return s:GetDisplayBpms()[2] end,
	GetStepCount,
	GetHighestDifficulty,
}
---------------------------------------------------------------------------
-- provided a group title as a string, prune out songs that don't have valid steps
-- returns an indexed table of song objects
pruned_songs_by_group = {}
local UpdatePrunedSongs = function()
	pruned_songs_by_group = {}

	--[[
	"GROUP",
	"TITLE",
	"LENGTH",
	"BPM",
	"DIFFICULTY",
	]]--

	local sort_pref = GetMainCourseSortPreference()
	local songs_by_group
	if sort_pref == 1 then
		songs_by_group = GroupSongsBy(GetCourseGroups)
	elseif sort_pref == 2 then
		songs_by_group = GroupSongsBy(GetSongFirstLetter)
	elseif sort_pref == 3 then
		songs_by_group = GroupSongsBy(GetSongLengthGroup)
	elseif sort_pref == 4 then
		songs_by_group = GroupSongsBy(GetSongBpmGroup)
	elseif sort_pref == 5 then
		songs_by_group = {}
		for song in ivalues(SONGMAN:GetAllCourses(PREFSMAN:GetPreference("AutogenGroupCourses"))) do
			local meters_set = {}
			for trail in ivalues(GetPlayableTrails(song)) do
				local meter = GetStepsDifficultyGroup(trail)
				meters_set[meter] = true
			end
			for meter, _ in pairs(meters_set) do
				if songs_by_group[meter] == nil then
					songs_by_group[meter] = {song}
				else
					local songs = songs_by_group[meter]
					songs[#songs+1] = song
				end
			end
		end
	end

	for group, group_songs in pairs(songs_by_group) do
		local songs = {}
		
		-- prune out songs that don't have valid steps or fit the filters
		for i,song in ipairs(group_songs) do
			-- this should be guaranteed by this point, but better safe than segfault
			
			-- Don't even bother if a course has 0 songs or no songs of .
			if #GetPlayableTrails(song) > 0 then
				local passesFilters = true
				
				--- Filter for Length
				if GetLowerLengthFilter() ~= 0 then
					local steps_type = GAMESTATE:GetCurrentStyle():GetStepsType()
					local CourseLength = song:GetTotalSeconds(steps_type)
					
					if CourseLength == nil then
						passesFilters = false
					elseif GetLowerLengthFilter() > CourseLength then
						passesFilters = false
					end
				end

				if GetUpperLengthFilter() ~= 0 then
					local steps_type = GAMESTATE:GetCurrentStyle():GetStepsType()
					local CourseLength = song:GetTotalSeconds(steps_type)
					
					if CourseLength == nil then
						passesFilters = false
					elseif GetUpperLengthFilter() < CourseLength then
						passesFilters = false
					end
				end
				
				--- Filter for BPM
				if GetLowerBPMFilter() ~= 49 then
					local CourseBPM = 0
					for trail in ivalues(song:GetAllTrails()) do
						local mpn = GAMESTATE:GetMasterPlayerNumber()
						local cur_trail = GAMESTATE:GetCurrentTrail(mpn)
						GAMESTATE:SetCurrentTrail(mpn, trail)
						CourseBPM = math.round(GetDisplayBPMs(mpn, trail)[2])
						GAMESTATE:SetCurrentTrail(mpn, cur_trail)
						break
					end
					
					if CourseBPM < GetLowerBPMFilter() then
						passesFilters = false
					end
				end
				if GetUpperBPMFilter() ~= 49 then
					local CourseBPM = 0
					for trail in ivalues(song:GetAllTrails()) do
						local mpn = GAMESTATE:GetMasterPlayerNumber()
						local cur_trail = GAMESTATE:GetCurrentTrail(mpn)
						GAMESTATE:SetCurrentTrail(mpn, trail)
						CourseBPM = math.round(GetDisplayBPMs(mpn, trail)[2])
						GAMESTATE:SetCurrentTrail(mpn, cur_trail)
						break
					end
					
					if CourseBPM > GetUpperBPMFilter() then
						passesFilters = false
					end
				end
				
				---- Filter for Difficulty
				if GetLowerDifficultyFilter() ~= 0 or GetUpperDifficultyFilter() ~= 0 then
					local hasPassingDifficulty = false
					for trail in ivalues(GetPlayableTrails(song)) do
						local passesLower = GetLowerDifficultyFilter() == 0 or trail:GetMeter() >= GetLowerDifficultyFilter()
						local passesUpper = GetUpperDifficultyFilter() == 0 or trail:GetMeter() <= GetUpperDifficultyFilter()
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
		end
		
		--[[
		"GROUP",
		"TITLE",
		"LENGTH",
		"BPM",
		"# OF STEPS",
		"DIFFICULTY",
		]]--

		local sort_func = subsort_funcs[GetSubSortPreference()]

		table.sort(songs, function(a, b)
			return sort_func(group, a) < sort_func(group, b)
		end)

		pruned_songs_by_group[group] = songs
	end
end

local PruneSongsFromGroup = function(group)
	local songs = pruned_songs_by_group[group]
	if songs == nil then songs = {} end

	-- Copy songs so that the calling function can mutate the returned table.
	local songs_copy = {}
	for song in ivalues(songs) do
		songs_copy[#songs_copy+1] = song
	end
	songs = songs_copy
	
	local current_song = GAMESTATE:GetCurrentCourse()
	-- we need to retain the index of the current song so we can set the SongWheel to start on it
	local index = 1
	for i, song in ipairs(songs) do
		if current_song == song then
			index = i
			break
		end
	end

	return songs, index
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------

local function GetGroupsBy(func)
	local groups_set = {}
	for song in ivalues(SONGMAN:GetAllCourses(PREFSMAN:GetPreference("AutogenGroupCourses"))) do
		local group = func(song)
		groups_set[group] = true
	end
	local groups = {}
	for group, _ in pairs(groups_set) do
		groups[#groups+1] = group
	end
	return groups
end

local function SortByLetter(a, b)
	if a == 'Other' then return false end
	if b == 'Other' then return true end
	if a == '#' then return false end
	if b == '#' then return true end
	return a:lower() < b:lower()
end

local GetGroups = function()
	
	local sort_pref = GetMainCourseSortPreference()
	if sort_pref == 1 then
		local groups = GetGroupsBy(GetCourseGroups)
		table.sort(groups, SortByLetter)
		return groups
	elseif sort_pref == 2 then
		local groups = GetGroupsBy(GetSongFirstLetter)
		table.sort(groups, SortByLetter)
		return groups
	elseif sort_pref == 3 then
		local groups = GetGroupsBy(GetSongLengthGroup)
		table.sort(groups, function(a,b)
			if a == max_length_group then return false end
			if b == max_length_group then return true end
			return a < b
		end)
		return groups
	elseif sort_pref == 4 then
		local groups = GetGroupsBy(GetSongBpmGroup)
		table.sort(groups, function(a,b)
			local a_bpm = tonumber(a:match('^[0-9]*'))
			local b_bpm = tonumber(b:match('^[0-9]*'))
			return a_bpm < b_bpm
		end)
		return groups
	elseif sort_pref == 5 then
		local groups_set = {}
		for song in ivalues(SONGMAN:GetAllCourses(PREFSMAN:GetPreference("AutogenGroupCourses"))) do
			for steps in ivalues(GetPlayableTrails(song)) do
				groups_set[GetStepsDifficultyGroup(steps)] = true
			end
		end
		local groups = {}
		for group, _ in pairs(groups_set) do
			groups[#groups+1] = group
		end
		table.sort(groups, function(a,b)
			if a == max_difficulty_group then return false end
			if b == max_difficulty_group then return true end
			return a < b
		end)
		return groups
	else
		return {}
	end
end


---------------------------------------------------------------------------

-- First looks to the last "seen" song for the default song and if it doesn't exist it will look at DDStats
-- since the DD GameMode can't rely on the engine to properly save LastPlayedSong. If neither exist then it defaults 
-- to the 1st song in the 1st folder.

local GetDefaultSong = function(groups)
	local songs = {}
	local playerNum
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		playerNum = PLAYER_1
	else
		playerNum = PLAYER_2
	end

	local lastCourse = DDStats.GetStat(playerNum, 'LastCourse')
	
	if LastSeenCourse ~= nil then
		for group in ivalues(groups) do
			for song in ivalues(PruneSongsFromGroup(group)) do
				if song:GetCourseDir() == LastSeenCourse then
					return song
				end
			end
		end
	elseif lastCourse ~= nil then
		for group in ivalues(groups) do
			for song in ivalues(PruneSongsFromGroup(group)) do
				if song:GetCourseDir() == lastCourse then
					return song
				end
			end
		end
	end
	
	return PruneSongsFromGroup( groups[1] )[1]
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- prune out groups that have no valid steps
-- passed an indexed table of strings representing potential group names
-- returns an indexed table of group names as strings



local PruneGroups = function(_groups)
	local groups = {}

	for group in ivalues( _groups ) do
		local group_has_been_added = false
		local songs = PruneSongsFromGroup(group)
		for song in ivalues(songs) do
			groups[#groups+1] = group
			group_has_been_added = true
			if group_has_been_added then break end
		end
	end
	return groups
end

--------------------------------------------------------------------------
local GetGroupInfo = function(groups)
	local info = {}
	for group in ivalues(groups) do
		local songs = PruneSongsFromGroup(group)
		local charts = {}, {}, {}

		info[group] = {}
		info[group].num_songs = #songs
		info[group].charts = ""

		for song in ivalues(songs) do

			for i,difficulty in ipairs(Difficulty) do
				-- don't care about edits
				if i>5 then break end
				if charts[difficulty] == nil then charts[difficulty] = 0 end

			end
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


local current_song
local group_index

local groups = GetGroups()
UpdatePrunedSongs()
-- prune the list of potential groups down to valid groups
groups = PruneGroups(groups)

-- there will be a current_song if we're on stage 2 or later
current_song = GetDefaultSong(groups)
GAMESTATE:SetCurrentCourse(current_song)

-- Find the group of the current song.
local found_group = false
if NameOfGroup ~= nil then
	for song in ivalues(PruneSongsFromGroup(NameOfGroup)) do
		if song == current_song then
			found_group = true
		end
	end
end
if not found_group then
	for group in ivalues(groups) do
		for song in ivalues(PruneSongsFromGroup(group)) do
			if song == current_song then
				NameOfGroup = group
				found_group = true
				break
			end
			if found_group then break end
		end
	end
end

-- Update group if we're sorted by difficulty.
if GetMainCourseSortPreference() == 6 then
	local steps = GAMESTATE:GetCurrentSteps(GAMESTATE:GetMasterPlayerNumber())
	if steps ~= nil then
		NameOfGroup = GetStepsDifficultyGroup(steps)
	end
end

-- If there are STILL no valid groups or songs, we aren't going to find any.
-- return nil, which default.lua will interpret to mean the
-- player needs to be informed that this machine has no suitable content...  D:
if #groups == 0 then
	return nil
end

group_index = FindInTable(NameOfGroup, groups) or 1

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