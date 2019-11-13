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

-- TODO: figure out what's using these and what for
local numCols = 3
local numRows = 5

---------------------------------------------------------------------------
-- variables that are to be passed between files
local OptionsWheel = {}
local GroupWheel = setmetatable({}, sick_wheel_mt)
local SongWheel = setmetatable({}, sick_wheel_mt)

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

local steps_type = GetStepsType()


---------------------------------------------------------------------------
-- initializes sick_wheel OptionRows for the CurrentSong with needed information
-- this function is called when choosing a song, either actively (pressing START)
-- or passively (MenuTimer running out)

local InitOptionRowsForSingleSong = function()
	for pn in ivalues( {PLAYER_1, PLAYER_2} ) do
		OptionsWheel[pn]:set_info_set(OptionRows, 1)
		for i,row in ipairs(OptionRows) do
			if row.OnLoad then
				row.OnLoad(OptionsWheel[pn][i], pn, row:Choices(), row.Values())
			end
		end
	end
end

---------------------------------------------------------------------------
-- default song when ScreenSelectMusicExperiment first loads
-- returns a song object

local GetDefaultSong = function()
	--TODO this only works for player one. And if there are two songs with the same name in the same group it'll pick the first
	--Try to grab the last played song on the profile for player one
	local profile = PROFILEMAN:GetProfile('PlayerNumber_P1')
	--if they haven't used Experiment mode before than last song won't be set so default to the first song
	if profile and SL.Global.LastSongPlayedName then
		local t = SONGMAN:GetSongsInGroup(SL.Global.LastSongPlayedGroup)
		for song in ivalues(t) do
			if song:GetMainTitle() == SL.Global.LastSongPlayedName then
				return song
			end
		end
	end
	-- fall back on first valid song from first valid group if needed
	return SONGMAN:GetAllSongs()[1]
end

---------------------------------------------------------------------------
-- prune out groups that have no valid steps
-- passed an indexed table of strings representing potential group names
-- returns an indexed table of group names as strings

local PruneGroups = function(_groups)
	local groups = {}
	local songs
	for group in ivalues( _groups ) do
		songs = PruneSongList(GetSongList(group))
		if #songs > 0 then
			groups[#groups+1] = group
		end
	end
	return groups
end

---------------------------------------------------------------------------
-- initializes sick_wheel groups
-- this function is called as a result of GroupTypeChangedMessageCommand broadcast by SortMenu_InputHandler.lua and
-- heard by default.lua (for ScreenSelectMusicExperiment overlay)

local InitGroups = function()
	local groups = PruneGroups(GetGroups())
	if #groups == 0 then
		SM("WARNING: ALL SONGS WERE FILTERED. RESETTING FILTERS")
		ResetFilters()
		groups = GetGroups()
	end
	local group_index = GetGroupIndex(groups)
	GroupWheel:set_info_set(groups, group_index)
end

---------------------------------------------------------------------------

local GetGroupInfo = function()
	local groups = PruneGroups(GetGroups())
	local info = {}
	local songs
	for group in ivalues(groups) do
		songs = PruneSongList(GetSongList(group))
		info[group] = {}
		info[group].num_songs = #songs
		info[group]['UnsortedLevel'] = {}
		info[group]['UnsortedPassedLevel'] = {}
		info[group]['PassedLevel'] = {}
		info[group].filtered_charts = 0
		for song in ivalues(songs) do
			if song:HasStepsType(GetStepsType()) then
				for steps in ivalues(song:GetStepsByStepsType(GetStepsType())) do
					--if the chart passes filters, add to our list of charts
					if ValidateChart(song, steps) then 
						info[group]['UnsortedLevel'][tostring(steps:GetMeter())] = 1 + (tonumber(info[group]['UnsortedLevel'][tostring(steps:GetMeter())]) or 0)
						local highScore = PROFILEMAN:GetProfile(0):GetHighScoreList(song,steps):GetHighScores()[1]
							if highScore then
								if highScore:GetGrade() and Grade:Reverse()[highScore:GetGrade()] < 17 then --TODO this won't work for player 2!
									info[group]['UnsortedPassedLevel'][tostring(steps:GetMeter())] = 1 + (tonumber(info[group]['UnsortedPassedLevel'][tostring(steps:GetMeter())]) or 0)
								end
							end
					else info[group].filtered_charts = info[group].filtered_charts + 1 end
				end
			end
		end
		info[group]['Level'] = info[group]['UnsortedLevel']
		info[group]['PassedLevel'] = info[group]['UnsortedPassedLevel']

		local sortTable = { }
		for k, v in pairs(info[group]['Level']) do table.insert(sortTable, { difficulty = k, num_songs = v }) end
		table.sort(sortTable, function(k1,k2) return tonumber(k1.difficulty) < tonumber(k2.difficulty) end)
		info[group]['Level'] = sortTable
		sortTable = {}
		for k, v in pairs(info[group]['PassedLevel']) do table.insert(sortTable, { difficulty = k, num_songs = v }) end
		table.sort(sortTable, function(k1,k2) return tonumber(k1.difficulty) < tonumber(k2.difficulty) end)
		info[group]['PassedLevel'] = sortTable
		local max_num = 0
		info[group].charts = ""
		for item in ivalues(info[group]['Level']) do
			info[group].charts = info[group].charts .. " Level " .. item.difficulty .. ": " .. item.num_songs .. "\n"
			if item.num_songs > max_num then max_num = item.num_songs end
		end
		info[group].max_num = max_num
	end
	return info
end
---------------------------------------------------------------------------
-- If there's no song set that means we're entering the screen for the first time, grab the default song and set up the groups
if not GAMESTATE:GetCurrentSong() then
	local current_song = GetDefaultSong()
	GAMESTATE:SetCurrentSong(current_song)
	GAMESTATE:SetCurrentSteps(0,GAMESTATE:GetCurrentSong():GetAllSteps()[1])
	InitPreloadedGroups()
-- Otherwise if the player got a new high grade then we need to remake the relevant grade groups
-- TODO right now this doesn't check if they got a highscore, it just makes new groups.
else
	UpdateGradeGroups(GAMESTATE:GetCurrentSong())
end

return {
	steps_type=steps_type,
	group_info=GetGroupInfo(),
	OptionsWheel=OptionsWheel,
	GroupWheel=GroupWheel,
	SongWheel=SongWheel,
	OptionRows=OptionRows,
	row=row,
	col=col,
	InitOptionRowsForSingleSong=InitOptionRowsForSingleSong,
	InitGroups=InitGroups,
	GetGroupInfo=GetGroupInfo,
}