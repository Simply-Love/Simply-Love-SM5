-- Move as many functions that make sense here to clean up Input.lua

local function GetLastStyle()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'LastStyle')
	else
		value = DDStats.GetStat(PLAYER_2, 'LastStyle')
	end

	if value == nil then
		value = "Single"
	end

	return value
end


local function SetLastStyle(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'LastStyle', value)
		DDStats.Save(playerNum)
	end
end


local t = Def.ActorFrame{

	DDResetSortsFiltersMessageCommand=function(self)
		----- Default preference values
		local DefaultMainCourseSort = 1
		local DefaultLowerDifficulty = 0
		local DefaultUpperDifficulty = 0
		local DefaultLowerBPM = 49
		local DefaultUpperBPM = 49
		local DefaultLowerLength = 0
		local DefaultUpperLength = 0
		local DefaultGroovestats = 'No'

		if 
		SongSearchWheelNeedsResetting == true or
		SortMenuNeedsUpdating == true or
		GetMainCourseSortPreference() ~= DefaultMainSort or
		GetLowerDifficultyFilter() ~= DefaultLowerDifficulty or
		GetUpperDifficultyFilter() ~= DefaultUpperDifficulty or
		GetLowerBPMFilter() ~= DefaultLowerBPM or
		GetUpperBPMFilter() ~= DefaultUpperBPM or
		GetLowerLengthFilter() ~= DefaultLowerLength or
		GetUpperLengthFilter() ~= DefaultUpperLength or
		GetGroovestatsFilter() ~= DefaultGroovestats then
			SetMainCourseSortPreference(DefaultMainCourseSort)
			SetSubSortPreference(DefaultSubSort)
			SetLowerDifficultyFilter(DefaultLowerDifficulty)
			SetUpperDifficultyFilter(DefaultUpperDifficulty)
			SetLowerBPMFilter(DefaultLowerBPM)
			SetUpperBPMFilter(DefaultUpperBPM)
			SetLowerLengthFilter(DefaultLowerLength)
			SetUpperLengthFilter(DefaultUpperLength)
			SetGroovestatsFilter(DefaultGroovestats)
			SongSearchWheelNeedsResetting = false
			SortMenuNeedsUpdating = false
			MESSAGEMAN:Broadcast("ReloadSSCDD")
		else
			SM("Nothing to reset!")
		end
	end,


	DDSwitchStylesMessageCommand=function(self)
		local current_style = GAMESTATE:GetCurrentStyle():GetStyleType()
		if current_style == "StyleType_OnePlayerOneSide" then
			SetLastStyle("Double")
			GAMESTATE:SetCurrentStyle("Double")
		else
			SetLastStyle("Single")
			GAMESTATE:SetCurrentStyle("Single")
		end
		SongSearchWheelNeedsResetting = false
		MESSAGEMAN:Broadcast("ReloadSSCDD")

	end,
	
	SwitchSongCourseSelectMessageCommand=function(self)
		local current_GameMode = GAMESTATE:GetPlayMode()
		if current_GameMode == 'PlayMode_Regular' then
			GAMESTATE:SetCurrentSong(nil)
			local value = "Course"
			for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
				DDStats.SetStat(playerNum, 'AreCourseOrSong', value)
				DDStats.Save(playerNum)
			end
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenSelectCourseDD")
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		else
			GAMESTATE:SetCurrentCourse(nil)
			local value = "Song"
			for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
				DDStats.SetStat(playerNum, 'AreCourseOrSong', value)
				DDStats.Save(playerNum)
			end
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenSelectMusicDD")
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end,

}

return t