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

	if PREFSMAN:GetPreference("EventMode") then
		return SelectMusicOrCourse()

	elseif GAMESTATE:IsCourseMode() then
		return Branch.AllowScreenNameEntry()

	else

		-- deduct the number of stages that stock StepMania says the song is
		local song = GAMESTATE:GetCurrentSong()
		local SMSongCost = (song:IsMarathon() and 3) or (song:IsLong() and 2) or 1
		SL.Global.Stages.Remaining = SL.Global.Stages.Remaining - SMSongCost

		-- check if stages should be "added back" to SL.Global.Stages.Remaining because of an active rate mod
		if SL.Global.ActiveModifiers.MusicRate ~= 1 then
			local ActualSongCost = 1
			local StagesToAddBack = 0

			local Duration = song:GetLastSecond()
			local DurationWithRate = Duration / SL.Global.ActiveModifiers.MusicRate

			local LongCutoff = PREFSMAN:GetPreference("LongVerSongSeconds")
			local MarathonCutoff = PREFSMAN:GetPreference("MarathonVerSongSeconds")

			local IsMarathon = (DurationWithRate/MarathonCutoff > 1)
			local IsLong     = (DurationWithRate/LongCutoff > 1)

			ActualSongCost = (IsMarathon and 3) or (IsLong and 2) or 1
			StagesToAddBack = SMSongCost - ActualSongCost

			SL.Global.Stages.Remaining = SL.Global.Stages.Remaining + StagesToAddBack
		end

		-- Now, check if StepMania and SL disagree on the stage count. If necessary, add stages back.
		-- This might be necessary because:
		-- a) a Lua chart reloaded ScreenGameplay, or
		-- b) everyone failed, and StepmMania zeroed out the stage numbers
		if GAMESTATE:GetNumStagesLeft(GAMESTATE:GetMasterPlayerNumber()) < SL.Global.Stages.Remaining then
			local StagesToAddBack = math.abs(SL.Global.Stages.Remaining - GAMESTATE:GetNumStagesLeft(GAMESTATE:GetMasterPlayerNumber()))
			local Players = GAMESTATE:GetHumanPlayers()
			for pn in ivalues(Players) do
				for i=1, StagesToAddBack do
					GAMESTATE:AddStageToPlayer(pn)
				end
			end
		end

		-- now, check if this set is over.
		local setOver
		-- This is only true if the set would have been over naturally,
		setOver = (SL.Global.Stages.Remaining <= 0)
		-- OR if we allow players to fail a set early and the players actually failed.
		if ThemePrefs.Get("AllowFailingOutOfSet") == true then
			setOver = setOver or STATSMAN:GetCurStageStats():AllFailed()
		end
		-- this style is more verbose but avoids obnoxious if statements

		if setOver then
			return Branch.AllowScreenEvalSummary()
		else
			return SelectMusicOrCourse()
		end
	end

	-- just in case?
	return SelectMusicOrCourse()
end

Branch.AfterProfileSaveSummary = function()
	if ThemePrefs.Get("AllowScreenGameOver") then
		return "ScreenGameOver"
	else
		return Branch.AfterInit()
	end
end
