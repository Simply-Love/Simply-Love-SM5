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

Branch.AfterScreenSelectProfile = function()
local nsj = GAMESTATE:GetNumSidesJoined()
	
	if nsj == 1 and st ~= 2 then
		GAMESTATE:SetCurrentStyle("Single")
		return "ScreenSelectPlayMode2"
	elseif nsj == 2 then
		GAMESTATE:SetCurrentStyle("Versus")
		return "ScreenSelectPlayMode2"
	end
end

Branch.AfterScreenRankingDouble = function()
	return PREFSMAN:GetPreference("MemoryCards") and "ScreenMemoryCard" or "ScreenRainbow"
end

SelectMusicOrCourse = function()
	if GAMESTATE:IsCourseMode() then
		return "ScreenSelectCourse"
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
	if THEME:GetMetric("ScreenHeartEntry", "HeartEntryEnabled") then
		local go_to_heart= false
		for i, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
			local profile= PROFILEMAN:GetProfile(pn)
			if profile and profile:GetIgnoreStepCountCalories() then
				go_to_heart= true
			end
		end

		if go_to_heart then
			return "ScreenHeartEntry"
		end
	end

	return Branch.AfterHeartEntry()
end

Branch.AfterHeartEntry = function()
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
			-- continues are only allowed in Pay mode
			if PREFSMAN:GetPreference("CoinMode") == "CoinMode_Pay" then
				if SL.Global.ContinuesRemaining > 0 and EnoughCreditsToContinue() then
					return "ScreenPlayAgain"
				end
			end

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
