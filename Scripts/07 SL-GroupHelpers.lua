--------------------------------------------------------------------------
-- A table of the possible sort groups and what the group names are
local SortGroups = {
	Title = {
		"A","B","C","D","E","F",
		"G","H","I","J","K","L",
		"M","N","O","P","Q","R",
		"S","T","U","V","W","X",
		"Y","Z","Num","Other"
	},
	BPM = {
		100,110,120,130,140,
		150,160,170,180,190,
		200,210,220,230,240,
		250,260,270,280,290,
		300,
	},
	Length = {
		1,2,3,4,5,
		6,7,8,9,10
	},
	Difficulty = {
		1,2,3,4,5,
		6,7,8,9,10,
		11,12,13,14,15,
		16,17,18,19,20,
		21,22,23,24,25,
	},
	Grade = {
		"Grade_Tier01","Grade_Tier02",
		"Grade_Tier03","Grade_Tier04",
		"Grade_Tier05","Grade_Tier06",
		"Grade_Tier07","Grade_Tier08",
		"Grade_Tier09","Grade_Tier10",
		"Grade_Tier11","Grade_Tier12",
		"Grade_Tier13","Grade_Tier14",
		"Grade_Tier15","Grade_Tier16",
		"Grade_Tier17","Grade_Tier18",
		"Grade_Tier19","Grade_Tier20",
		"Grade_Failed","No_Grade",
	},
	Group = {},
	Tag = {"No Tags Set"}
}

-- To keep load times down we only want to create groups once. The structure is PreloadedGroups[SortType][GroupName] -> {table of songs}
-- For example: PreloadedGroups["Title"]["A"] contains an indexed table of all songs starting with A
local PreloadedGroups = {}

-- When songs should be ordered by difficulty and then BPM keep track of them in this table since we need to split
-- songs depending on the number of charts
 DifficultyBPM = {}

-- A table of tagged songs loaded from Other/TaggedSongs.txt
-- Each item in the table is a table with the following items: customGroup, title, actualGroup
-- TODO change customGroup to tagName or something like that
local TaggedSongs = {} 

-- Returns nil if the song has no tags or the name of the first tag it finds
-- If given a group parameter it will only return something if the song has that specific tag
-- TODO if a song is in multiple groups it will just return the first one it finds. Probably go through everything and put all results in a table instead
-- TODO take out custom song stuff and switch to tagName or something
function IsTaggedSong(song, group)
	local current_song = song
	for customSong in ivalues(TaggedSongs) do
		if current_song:GetMainTitle() ==  customSong['title'] and current_song:GetGroupName() == customSong['actualGroup'] then
			if group then
				if group == customSong['customGroup'] then return customSong['customGroup'] end
			else
				return customSong['customGroup']
			end
		end
	end
	return nil
end
	
---------------------------------------------------------------------------
-- returns an indexed table of group names as strings
-- uses the input sort type or the current sort type if none is entered
GetGroups = function(group)
	local group = group or SL.Global.GroupType
	if group == "Group" then
		return SONGMAN:GetSongGroupNames()
	else return SortGroups[group] end
end

---------------------------------------------------------------------------
-- helper function used to load tags and tagged songs
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

local WriteFileContents = function(path, contents)
	local contents = contents

	if FILEMAN:DoesFileExist(path) then
		-- create a generic RageFile that we'll use to read the contents
		local file = RageFileUtil.CreateRageFile()
		-- the second argument here (the 1) signifies
		-- that we are opening the file in read-only mode
		if file:Open(path, 2) then
			file:Write(contents)
		end

		-- destroy the generic RageFile now that we have the contents
		file:destroy()
	end
end

-- Splits a string by sep and returns a table 
function split (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

-- Add whatever tags we find in Tags.txt to the sort groups aka groups we can sort by
local function LoadTags()
	SortGroups.Tag = {}
	local path = THEME:GetCurrentThemeDirectory() .. "Other/Tags.txt"
	for name in ivalues(GetFileContents(path)) do
		table.insert(SortGroups.Tag, name)
	end
	table.insert(SortGroups.Tag, "No Tags Set")
end

-- Write whatever is in SortGroups.Tag to Tags.txt
local function SaveTags()
	local toWrite = ""
	for k,v in pairs(SortGroups.Tag) do
		if v ~= "No Tags Set" then
			toWrite = toWrite..v.."\n"
		end
	end
	local path = THEME:GetCurrentThemeDirectory() .. "Other/Tags.txt"
	WriteFileContents(path,toWrite)
end

-- Add whatever tagged songs we find in TaggedSongs.txt. They're needed to populate the tag groups
local function LoadTaggedSongs()
	TaggedSongs = {}
	local path = THEME:GetCurrentThemeDirectory() .. "Other/TaggedSongs.txt"
	for line in ivalues(GetFileContents(path)) do
		local toAdd = split(line, '\t')
		table.insert(TaggedSongs, {customGroup=toAdd[1], title=toAdd[2], actualGroup=toAdd[3]})
	end
end

-- Write whatever is in TaggedSongs to TaggedSongs.txt
local function SaveTaggedSongs()
	-- Overwrite CustomGroups-Songs.txt with the current Custom Songs table
	local toWrite = ""
	for k,v in pairs(TaggedSongs) do
		toWrite = toWrite..v['customGroup'].."\t"..v['title'].."\t"..v['actualGroup'].."\n"
	end
	local path = THEME:GetCurrentThemeDirectory() .. "Other/TaggedSongs.txt"
	WriteFileContents(path,toWrite)
end

function AddTag(toAdd)
	table.insert(SortGroups.Tag, #SortGroups.Tag, toAdd)
	SaveTags()
	PreloadedGroups["Tag"][tostring(toAdd)] = CreateSongList(tostring(toAdd), "Tag")
end
	
-- Called by ScreenSelectMusicExperiment overlay/TagMenu/Input.lua when the player wants to add a tag to a song
-- Adds a line to TaggedSongs, saves it, and then recreates the group so we can sort properly.
function AddTaggedSong(toAdd, song)
	-- Add the song to the CustomSong table
	local toAdd = split(toAdd, '\t')
	table.insert(TaggedSongs, {customGroup=toAdd[1], title=toAdd[2], actualGroup=toAdd[3]})
	SaveTaggedSongs()
	PreloadedGroups["Tag"][tostring(toAdd[1])] = CreateSongList(tostring(toAdd[1]),"Tag")
	-- If this song used to be in No Tags Set then remove it. TODO find out if it's faster to remove the song from the group or just recreate the group
	local index = FindInTable(song,PreloadedGroups["Tag"]["No Tags Set"])
	if index then table.remove(PreloadedGroups["Tag"]["No Tags Set"],index) end
end

-- Called by ScreenSelectMusicExperiment overlay/TagMenu/Input.lua when the player wants to remove a tag to a song
-- Adds a line to TaggedSongs, saves it, and then recreates the group so we can sort properly.
function RemoveTaggedSong(toRemove, song)
	local index = 1
	local toRemove = split(toRemove, '\t')
	for k,v in pairs(TaggedSongs) do
		if v['customGroup'] == toRemove[1] and v['title'] == toRemove[2] and v['actualGroup'] == toRemove[3] then
			index = k
			break
		end
	end
	table.remove(TaggedSongs,index)
	SaveTaggedSongs()
	PreloadedGroups["Tag"][tostring(toRemove[1])] = CreateSongList(tostring(toRemove[1]),"Tag")
	--if this song no longer has any tags then add it to "No Tags Set"
	if not IsTaggedSong(song) then table.insert(PreloadedGroups["Tag"]["No Tags Set"],song) end
end

-- To keep load times down we only want to create groups once. However, tag groups and grade groups are not static.
-- This function is called by Setup.lua each time we go back to ScreenSelectMusicExperiment with a song set (aka not the first time)
-- Remove the current song from whatever grade groups it was in and add it to whatever grade groups it should be in now
function UpdateGradeGroups(song)
	local current_song = song
	--first remove the song from all current grade groups it's in
	--if the current song is in no grade we don't need to bother checking everything else
	local index = FindInTable(current_song,GetSongList("No_Grade","Grade"))
	if index then
		table.remove(PreloadedGroups["Grade"]["No_Grade"],index)
	else
		for group in ivalues(GetGroups("Grade")) do
			if group ~= "No_Grade" then --don't need to check no grade twice
				index = FindInTable(current_song,GetSongList(group,"Grade"))
				if index then
					table.remove(PreloadedGroups["Grade"][tostring(group)],index)
				end
			end
		end
	end
	-- next add it to all relevant groups
	local isPlayed = false
	for steps in ivalues(current_song:GetStepsByStepsType(GetStepsType())) do
		local highScore = PROFILEMAN:GetProfile(0):GetHighScoreList(current_song,steps):GetHighScores()[1]
		if highScore then
			if highScore:GetGrade() then --TODO this won't work for player 2!
				table.insert(PreloadedGroups["Grade"][tostring(highScore:GetGrade())],current_song)
				isPlayed = true
			end
		end
	end
	-- TODO this is dumb because we just tried to take it out of No_Grade so really we should check there
	-- but i'm lazy and it's easier to just add it back in down here...
	if not isPlayed then table.insert(PreloadedGroups["Grade"]["No_Grade"],current_song) end
end

---------------------------------------------------------------------------
-- a steps_type like "StepsType_Dance_Single" is needed so we can filter out steps that aren't suitable
-- (there has got to be a better way to do this...)
-- returns a String containing the steps type for the current game mode
GetStepsType = function()
	local game_name = GAMESTATE:GetCurrentGame():GetName()
	-- "single" and  "versus" both map to "Single" here
	local style = "Single"

	if GAMESTATE:GetCurrentStyle():GetName() == "double" then
		style = "Double"
	end

	local steps_type = "StepsType_"..game_name:gsub("^%l", string.upper).."_"..style

	-- techno is a special case with steps_type like "StepsType_Techno_Single8"
	if game_name == "techno" then steps_type = steps_type.."8" end
	return steps_type
end

-- for the groups that are just numbers (Length, BPM) or ugly enums (Grade) we want to make it more descriptive
-- called by GroupMT.lua
GetGroupDisplayName = function(groupName)
	local name
	if SL.Global.GroupType == "Length" then
		if groupName == 1 then name = groupName.." Minute"
		else name = groupName.." Minutes" end
	elseif SL.Global.GroupType == "BPM" then
		name = groupName.." BPM"
	elseif SL.Global.GroupType == "Difficulty" then
		name = "Level "..groupName
		if tonumber(groupName) == 25 then name = name.."+" end
	elseif SL.Global.GroupType == "Grade" then
		name = SL.GroupNames["Grade"][groupName]
	else name = groupName end
	return name
end

---------------------------------------------------------------------------
-- Called by __index InitCommand in GroupMT.lua (ScreenSelectMusicExperiment overlay)
-- Returns a string containing the group the current song is part of
GetCurrentGroup = function()
	--no song if we're on Close This Folder so use the last seen song
	local current_song = GAMESTATE:GetCurrentSong() or SL.Global.LastSeenSong
	local starting_group = current_song:GetMainTitle()
	if SL.Global.GroupType == "Title" then 
		if string.find(starting_group, "^%d") then
			starting_group = "Num"
		elseif string.find(starting_group, "^%W") then
			starting_group = "Other"
		else
			starting_group = string.sub(starting_group, 1, 1)
		end
	elseif SL.Global.GroupType == "Tag" then starting_group = IsTaggedSong(current_song) or "No Tags Set"
	elseif SL.Global.GroupType == "Group" then starting_group = current_song:GetGroupName()
	elseif SL.Global.GroupType == "BPM" then 
		local speed = current_song:GetDisplayBpms()[2]
		starting_group = speed - (speed % 10)
		if starting_group > 300 then starting_group = 300
		elseif starting_group < 110 then starting_group = 100
		end
	elseif SL.Global.GroupType == "Length" then
		local length = current_song:MusicLengthSeconds()
		starting_group = math.floor(length/60)
		if starting_group < 1 then starting_group = 10
		elseif starting_group > 10 then starting_group = 10
		end
	elseif SL.Global.GroupType == "Difficulty" then
		starting_group = GAMESTATE:GetCurrentSteps('PlayerNumber_P1'):GetMeter() --TODO this won't work for player 2!
	elseif SL.Global.GroupType == "Grade" then
		local highScore = PROFILEMAN:GetProfile(0):GetHighScoreList(current_song,GAMESTATE:GetCurrentSteps(0)):GetHighScores()[1]
		if highScore then starting_group = highScore:GetGrade()
		else starting_group = "No_Grade" end
	else starting_group = current_song:GetGroupName() end
	SL.Global.CurrentGroup = starting_group
	return starting_group
end

-------------------------------------------------------------------------------------------------------
-- given a table of all possible groups, return the index of the group that the current song is part of or 1 if it can't find the group
GetGroupIndex = function(groups)
	local group_index = 1
	local current_song = GAMESTATE:GetCurrentSong() or SL.Global.LastSeenSong
	for k,group in ipairs(groups) do
		if SL.Global.GroupType == "Tag" then
			if IsTaggedSong(current_song) == group then group_index = k
			elseif group == "No Tags Set" and not IsTaggedSong(current_song) then group_index = k end
		elseif SL.Global.GroupType == "Group" then
			if current_song:GetGroupName() == group then
				group_index = k
				break
			end
		elseif SL.Global.GroupType == "Title" then
			if group == "Num" then
				 if string.find(current_song:GetMainTitle(), "^%d") then group_index = k end
			elseif group == "Other" then
				if string.find(current_song:GetMainTitle(), "^%W") then group_index = k end
			elseif string.sub(current_song:GetMainTitle(), 1, 1) == string.sub(group, 1, 1) then group_index = k end
		elseif SL.Global.GroupType == "BPM" then
			if tonumber(group) == 100 then
				 if current_song:GetDisplayBpms()[2] < 110 then
					group_index = k
				end
			elseif tonumber(group) == 300 then
				if current_song:GetDisplayBpms()[2] >= 300 then
					group_index = k
				end
			elseif current_song:GetDisplayBpms()[2] < tonumber(group) + 10 and current_song:GetDisplayBpms()[2] >= tonumber(group) then
				group_index = k
			end
		elseif SL.Global.GroupType == "Length" then
			if tonumber(group) == 10 then
				if current_song:MusicLengthSeconds() >= 600 then group_index = k end
			elseif tonumber(group) == 1 then
				if current_song:MusicLengthSeconds() < 120 then group_index = k end
			elseif current_song:MusicLengthSeconds() >= tonumber(group) * 60 and current_song:MusicLengthSeconds() < ((tonumber(group) * 60) + 60) then
				group_index = k
			end
		elseif SL.Global.GroupType == "Difficulty" then
			if tonumber(group) == GAMESTATE:GetCurrentSteps('PlayerNumber_P1'):GetMeter() then --TODO this won't work for player 2!
				group_index = k
			elseif tonumber(group) > 25 and GAMESTATE:GetCurrentSteps('PlayerNumber_P1'):GetMeter() > 25 then
				group_index = k
			end
		elseif SL.Global.GroupType == "Grade" then
			local highScore = PROFILEMAN:GetProfile(0):GetHighScoreList(current_song,GAMESTATE:GetCurrentSteps(0)):GetHighScores()[1]
			if highScore then 
				if group == highScore:GetGrade() then --TODO this won't work for player 2!
					group_index = k
				end
			else
				if group == "No_Grade" then
					group_index = k
				end
			end
		end
	end
	return group_index
end

---------------------------------------------------------------------------
-- functions related to creating groups
-----------------------------------------------------------------------------

local CreateGroup = Def.ActorFrame{
	--------------------------------------------------------------------------------------
	-- provided a group title as a string, make a list of songs that fit that group
	-- returns an indexed table of song objects
	
	-- TODO songs are currently tracked separately from groups so if you go in later
	-- and delete the group, when creating the "No Tags Set" folder it won't populate
	-- things that are in custom groups that no longer exist.
	Tag = function(group)
		local songs = {}
		for song in ivalues(SONGMAN:GetAllSongs()) do
			-- this should be guaranteed by this point, but better safe than segfault
			if song:HasStepsType(GetStepsType()) then
				if not IsTaggedSong(song) then if group == "No Tags Set" then songs[#songs+1] = song end
				else
					if IsTaggedSong(song, group) then
						songs[#songs+1] = song
					end
				end
			end
		end
		return songs
	end,

	--------------------------------------------------------------------------------------
	-- provided a group title as a string, make a list of songs that fit that group
	-- returns an indexed table of song objects
	Grade = function(group)
		local songs = {}
		for song in ivalues(SONGMAN:GetAllSongs()) do
			local played = false
			-- this should be guaranteed by this point, but better safe than segfault
			if song:HasStepsType(GetStepsType()) then
				for steps in ivalues(song:GetStepsByStepsType(GetStepsType())) do
					local highScore = PROFILEMAN:GetProfile(0):GetHighScoreList(song,steps):GetHighScores()[1]
					if highScore then
						played = true
						if highScore:GetGrade() == group then --TODO this won't work for player 2!
							songs[#songs+1] = song
							break
						end
					end
				end
				if not played then if group == "No_Grade" then songs[#songs+1] = song end end
			end	
		end
		return songs
	end,
	--------------------------------------------------------------------------------------
	--provided a group title as a string, make a list of songs that fit that group
	--returns an indexed table of song objects
	Difficulty = function(group)
		local songs = {}
		for song in ivalues(SONGMAN:GetAllSongs()) do
			-- this should be guaranteed by this point, but better safe than segfault
			if song:HasStepsType(GetStepsType()) then
				for steps in ivalues(song:GetStepsByStepsType(GetStepsType())) do
					if steps:GetMeter() == tonumber(group) then
						songs[#songs+1] = song
						break
					elseif tonumber(group) == 25 and steps:GetMeter() > 25 then
						songs[#songs+1] = song
						break
					end
				end
			end
		end
		return songs
	end,
	--------------------------------------------------------------------------------------
	--provided a group title as a string, make a list of songs that fit that group
	--returns an indexed table of song objects
	Length = function(group)
		local songs = {}
		for song in ivalues(SONGMAN:GetAllSongs()) do
			-- this should be guaranteed by this point, but better safe than segfault
			if song:HasStepsType(GetStepsType()) then
				if tonumber(group) == 10 then
					if song:MusicLengthSeconds() >= 600 then
						songs[#songs+1] = song
					end
				elseif tonumber(group) == 1 then
					if song:MusicLengthSeconds() < 120 then
						songs[#songs+1] = song
					end
				elseif song:MusicLengthSeconds() >= tonumber(group) * 60 and song:MusicLengthSeconds() < ((tonumber(group) * 60) + 60) then
					songs[#songs+1] = song
				end
			end
		end

		return songs
	end,

	--------------------------------------------------------------------------------------
	--provided a group title as a string, make a list of songs that fit that group
	--returns an indexed table of song objects
	Title = function(group)
		local songs = {}
		for song in ivalues(SONGMAN:GetAllSongs()) do
			-- this should be guaranteed by this point, but better safe than segfault
			if song:HasStepsType(GetStepsType()) then
				if group == "Num" then
					 if string.find(song:GetMainTitle(), "^%d") then
						songs[#songs+1] = song
					end
				elseif group == "Other" then
					if string.find(song:GetMainTitle(), "^%W") then
						songs[#songs+1] = song
					end
				elseif group == string.sub(song:GetMainTitle(), 1, 1) then
					songs[#songs+1] = song
				end
			end
		end

		return songs
	end,
	--------------------------------------------------------------------------------------
	--provided a group title as a string, make a list of songs that fit that group
	--returns an indexed table of song objects
	BPM = function(group)
		local songs = {}
		for song in ivalues(SONGMAN:GetAllSongs()) do
			-- this should be guaranteed by this point, but better safe than segfault
			if song:HasStepsType(GetStepsType()) then
				if tonumber(group) == 100 then
					 if song:GetDisplayBpms()[2] < 110 then
						songs[#songs+1] = song
					end
				elseif tonumber(group) == 300 then
					if song:GetDisplayBpms()[2] >= 300 then
						songs[#songs+1] = song
					end
				elseif song:GetDisplayBpms()[2] < tonumber(group) + 10 and song:GetDisplayBpms()[2] >= tonumber(group) then
						songs[#songs+1] = song
				end
			end
		end

		return songs
	end,

	--------------------------------------------------------------------------------------
	--provided a group title as a string, make a list of songs that fit that group
	--returns an indexed table of song objects
	Group = function(group)
		local songs = {}

		for i,song in ipairs(SONGMAN:GetSongsInGroup(group)) do
			-- this should be guaranteed by this point, but better safe than segfault
			if song:HasStepsType(GetStepsType()) then
				songs[#songs+1] = song
			end
		end
		
		return songs
	end,
}

----------------------------------------------------------------------------------------------
--Controls the order songs should be displayed from within a group
--Default is alphabetical
----------------------------------------------------------------------------------------------

GetSortFunction = function()
	if SL.Global.Order == "Alphabetical" then
		return function(k1,k2)
			return string.lower(k1:GetMainTitle()) < string.lower(k2:GetMainTitle())
		end
	elseif SL.Global.Order == "BPM" then
		return function(k1,k2)
			if k1:GetDisplayBpms()[2] == k2:GetDisplayBpms()[2] then
				return string.lower(k1:GetMainTitle()) < string.lower(k2:GetMainTitle())
			else
				return k1:GetDisplayBpms()[2] < k2:GetDisplayBpms()[2]
			end
		end
	elseif SL.Global.Order == "Difficulty/BPM" then
		return function(k1,k2)
			--Difficulty/BPM takes a normal songlist before adding additional params and sorting again
			--So if there are no additional params set then just return a normal alphabetical sorted list
			if not k1.song then return string.lower(k1:GetMainTitle()) < string.lower(k2:GetMainTitle()) end 
			if k1.difficulty == k2.difficulty then
				if k1.bpm == k2.bpm then
					return string.lower(k1.song:GetMainTitle()) < string.lower(k2.song:GetMainTitle())
				else 
					return k1.bpm < k2.bpm
				end
			else
				return k1.difficulty < k2.difficulty
			end
		end
	else
		return string.lower(k1:GetMainTitle()) < string.lower(k2:GetMainTitle()) --default to alphabetical if order doesn't match something here
	end
end
-------------------------------------------------------------------------------------
--depending on the group name supplied
--returns an indexed table of song objects
--if groupType isn't given it will use whatever the current sort is
--cycles through every song loaded so can take a while if you have too many songs
CreateSongList = function(group_name, groupType)
	local groupType = groupType or SL.Global.GroupType
	local songList = CreateGroup[groupType](group_name)
	return songList
end

-- instead of cycling through every song to create a group uses the preloaded groups
-- that were created when screenselectmusicExperiment first runs
GetSongList = function(group_name, group_type)
	local group_type = group_type or SL.Global.GroupType
	local songList = PreloadedGroups[group_type][tostring(group_name)]
	table.sort(songList, GetSortFunction())
	return songList
end

CreateSpecialSongList = function(songList)
	local songList = songList
	DifficultyBPM = {}
	for song in ivalues(songList) do
		for i = 1,#song:GetStepsByStepsType(GetStepsType()) do
			table.insert(DifficultyBPM,{song=song,difficulty=song:GetStepsByStepsType(GetStepsType())[i]:GetMeter(),bpm=song:GetDisplayBpms()[2]})
		end
	end
	table.sort(DifficultyBPM, GetSortFunction())
	local specialList = {}
	for item in ivalues(DifficultyBPM) do
		specialList[#specialList+1] = item.song
	end
	return specialList
end

GetDifficultyBPM = function(index)
	return DifficultyBPM[index]
end
----------------------------------------------------------------------------------------
-- Create groups for every item in the SortGroups table
InitPreloadedGroups = function()
	-- Add normal groups to SortGroups. I'd like to do this earlier but I guess the game needs to load for SONGMAN to become available
	SortGroups["Group"] = SONGMAN:GetSongGroupNames()
	-- Add song lists to PreloadedGroups
	for sortType,groupList in pairs(SortGroups) do
		PreloadedGroups[tostring(sortType)] = {}
		for groupName in ivalues(groupList) do
			PreloadedGroups[tostring(sortType)][tostring(groupName)] = CreateSongList(groupName, sortType)
		end
	end
end

-- Get custom songs ready --
LoadTaggedSongs()
LoadTags()
