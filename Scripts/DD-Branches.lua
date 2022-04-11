------------------------------------------------------------
-- Helper Functions for Branches
------------------------------------------------------------

local EnoughCreditsToContinue = function()
	local credits = GetCredits().Credits

	local premium = ToEnumShortString(GAMESTATE:GetPremium())
	local styletype = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())

	if premium == "2PlayersFor1Credit" then
		return (credits > 0) -- any value greater than 0 is good enough

	elseif premium == "DoubleFor1Credit" then
		-- versus, routine, couple
		if styletype == "TwoPlayersTwoSides" or styletype == "TwoPlayersSharedSides" then
			return (credits > 1)

		-- single, double, solo
		else
			return (credits > 0)
		end

	elseif premium == "Off" then
		-- single, solo
		if styletype == "OnePlayerOneSide" then
			return (credits > 0)

		-- versus, double, routine, couple
		else
			return (credits > 1)
		end
	end

	return false
end

------------------------------------------------------------

if not Branch then Branch = {} end

Branch.AfterScreenProfileLoad = function()
	SetGameModePreferences()
	local nsj = GAMESTATE:GetNumSidesJoined()
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
	
	if nsj == 1 then
		local yo = GetLastStyle()
		local playerNum
		local value = "Song"
		GAMESTATE:SetCurrentStyle(yo)
		
		if GAMESTATE:IsPlayerEnabled(0) then
			playerNum = PLAYER_1
		else
			playerNum = PLAYER_2
		end
		local CourseOrSong = DDStats.GetStat(playerNum, 'AreCourseOrSong')

		if CourseOrSong == nil then
			DDStats.SetStat(playerNum, 'AreCourseOrSong', value)
			DDStats.Save(playerNum)
			GAMESTATE:SetCurrentPlayMode(0)
			return "ScreenSelectMusicDD"
		elseif CourseOrSong == 'Song' then
			GAMESTATE:SetCurrentPlayMode(0)
			return "ScreenSelectMusicDD"
		elseif CourseOrSong == 'Course' then
			GAMESTATE:SetCurrentPlayMode(1)
			return "ScreenSelectCourseDD"
		end
	elseif nsj == 2 then
		GAMESTATE:SetCurrentStyle("Versus")
		local Player1CourseOrSong = DDStats.GetStat(PLAYER_1, 'AreCourseOrSong')
		local Player2CourseOrSong = DDStats.GetStat(PLAYER_2, 'AreCourseOrSong')
		local value = "Song"
		-- If either player is set to Song go to song select.
		if Player1CourseOrSong == nil or Player2CourseOrSong == nil then
			DDStats.SetStat(PLAYER_1, 'AreCourseOrSong', value)
			DDStats.SetStat(PLAYER_2, 'AreCourseOrSong', value)
			DDStats.Save(PLAYER_1)
			DDStats.Save(PLAYER_2)
			GAMESTATE:SetCurrentPlayMode(0)
			return "ScreenSelectMusicDD"
		elseif Player1CourseOrSong == 'Song' or Player2CourseOrSong == 'Song' then
			DDStats.SetStat(PLAYER_1, 'AreCourseOrSong', value)
			DDStats.SetStat(PLAYER_2, 'AreCourseOrSong', value)
			DDStats.Save(PLAYER_1)
			DDStats.Save(PLAYER_2)
			GAMESTATE:SetCurrentPlayMode(0)
			return "ScreenSelectMusicDD"
		else
			GAMESTATE:SetCurrentPlayMode(1)
			return "ScreenSelectCourseDD"
		end
	end
end

Branch.AfterScreenRankingDouble = function()
	return PREFSMAN:GetPreference("MemoryCards") and "ScreenMemoryCard"
end

SelectMusicOrCourse = function()
	if GAMESTATE:IsCourseMode() then
		return "ScreenSelectCourseDD"
	else
		return "ScreenSelectMusicDD"
	end
end

Branch.AfterEvaluationStage = function()
	return "ScreenProfileSave"
end

Branch.AfterSelectPlayMode = function()
	return SelectMusicOrCourse()
end


Branch.AfterGameplay = function()
	local pm = ToEnumShortString(GAMESTATE:GetPlayMode())
	if( pm == "Regular" ) then return "ScreenEvaluationStage" end
	if( pm == "Nonstop" ) then return "ScreenEvaluationNonstop" end
end

Branch.AfterSelectMusic = function()
	if SCREENMAN:GetTopScreen():GetGoToOptions() then
		return "ScreenPlayerOptions"
	else
		-- routine mode specifically uses ScreenGameplayShared
		local style = GAMESTATE:GetCurrentStyle():GetName()
		if style == "routine" then
			return "ScreenGameplayShared"
		end

		-- while everything else (single, versus, double, etc.) uses ScreenGameplay
		return "ScreenGameplay"
	end
end

Branch.SSMCancel = function()

	if GAMESTATE:GetCurrentStageIndex() > 0 then
		return Branch.AllowScreenEvalSummary()
	end

	return Branch.TitleMenu()
end

Branch.AllowScreenNameEntry = function()

	if ThemePrefs.Get("AllowScreenNameEntry") then
		return "ScreenNameEntryTraditional"
	else
		return "ScreenProfileSaveSummary"
	end
end

Branch.AllowScreenEvalSummary = function()
	if ThemePrefs.Get("AllowScreenEvalSummary") then
		return "ScreenEvaluationSummary"
	else
		return Branch.AllowScreenNameEntry()
	end
end

Branch.AfterProfileSave = function()
	return SelectMusicOrCourse()
end

Branch.AfterProfileSaveSummary = function()
	if ThemePrefs.Get("AllowScreenGameOver") then
		return "ScreenGameOver"
	else
		return Branch.AfterInit()
	end
end
