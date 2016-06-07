if not Branch then Branch = {} end

Branch.AllowScreenNameEntry = function()

	-- If we're in Casual mode, don't allow NameEntry, and don't
	-- bother saving the profile(s). Skip directly to GameOver.
	if SL.Global.GameMode == "Casual" then
		return Branch.AfterProfileSaveSummary()

	elseif ThemePrefs.Get("AllowScreenNameEntry") then
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

Branch.AllowScreenSelectProfile = function()
	if ThemePrefs.Get("AllowScreenSelectProfile") then
		return "ScreenSelectProfile"
	else
		return Branch.AllowScreenSelectColor()
	end	
end

Branch.AllowScreenSelectColor = function()
	if ThemePrefs.Get("AllowScreenSelectColor") and not ThemePrefs.Get("RainbowMode") then
		return "ScreenSelectColor"
	else
		return Branch.AfterScreenSelectColor()
	end
end

Branch.AfterScreenSelectColor = function()
	local preferred_style = ThemePrefs.Get("AutoStyle")
	if preferred_style ~= "none" then
		-- If "versus" ensure that both players are actually considered joined.
		if preferred_style == "versus" then
			GAMESTATE:JoinPlayer(PLAYER_1)
			GAMESTATE:JoinPlayer(PLAYER_2)
		end
		GAMESTATE:SetCurrentStyle( preferred_style )
		-- set this here to be used later with the continue system
		SL.Global.Gamestate.Style = preferred_style

		return "ScreenSelectPlayMode"
	end

	return "ScreenSelectStyle"
end

Branch.AfterEvaluationStage = function()
	-- If we're in Casual mode, don't save the profile(s).
	if SL.Global.GameMode == "Casual" then
		return Branch.AfterProfileSave()
	else
		return "ScreenProfileSave"
	end
end

Branch.AfterSelectPlayMode = function()
	if GAMESTATE:GetPlayMode() == "PlayMode_Nonstop" then
		return "ScreenSelectCourseNonstop"
	else
		return "ScreenSelectMusic"
	end
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

Branch.PlayerOptions = function()
	if SCREENMAN:GetTopScreen():GetGoToOptions() then
		return "ScreenPlayerOptions"
	else
		return "ScreenGameplay"
	end
end

Branch.SSMCancel = function()

	if GAMESTATE:GetCurrentStageIndex() > 0 then
		return Branch.AllowScreenEvalSummary()
	end

	return Branch.TitleMenu()
end

Branch.AfterProfileSave = function()

	if PREFSMAN:GetPreference("EventMode") then
		return SelectMusicOrCourse()

	elseif GAMESTATE:IsCourseMode() then
		return Branch.AllowScreenNameEntry()

	else

		local song = GAMESTATE:GetCurrentSong()
		local SMSongCost = (song:IsMarathon() and 3) or (song:IsLong() and 2) or 1
		SL.Global.Stages.Remaining = SL.Global.Stages.Remaining - SMSongCost

		-- calculate if stages should be "added back" because of rate mod
		if SL.Global.ActiveModifiers.MusicRate ~= 1 then
			local ActualSongCost = 1
			local StagesToAddBack = 0

			local Duration = song:GetLastSecond()
			local DurationWithRate = Duration / SL.Global.ActiveModifiers.MusicRate

			local LongCutoff = PREFSMAN:GetPreference("LongVerSongSeconds")
			local MarathonCutoff = PREFSMAN:GetPreference("MarathonVerSongSeconds")

			local IsMarathon = DurationWithRate/MarathonCutoff > 1 and true or false
			local IsLong 	 = DurationWithRate/LongCutoff > 1 and true or false

			ActualSongCost = (IsMarathon and 3) or (IsLong and 2) or 1
			StagesToAddBack = SMSongCost - ActualSongCost

			SL.Global.Stages.Remaining = SL.Global.Stages.Remaining + StagesToAddBack
		end


		-- This is somewhat hackish, but it serves to counteract Lua Hacks.
		-- If ScreenGameplay was reloaded by a "gimmick" chart, then it is
		-- very possible that the Engine's concept of remaining stages will
		--  be incongruent with the Theme's.  Add stages back, engine-side, if necessary.
		if GAMESTATE:GetNumStagesLeft(GAMESTATE:GetMasterPlayerNumber()) < SL.Global.Stages.Remaining then
			StagesToAddBack = math.abs(SL.Global.Stages.Remaining - GAMESTATE:GetNumStagesLeft(GAMESTATE:GetMasterPlayerNumber()))
			local Players = GAMESTATE:GetHumanPlayers()
			for pn in ivalues(Players) do
				for i=1, StagesToAddBack do
					GAMESTATE:AddStageToPlayer(pn)
				end
			end
		end

		-- If we don't allow players to fail out of a set early
		if ThemePrefs.Get("AllowFailingOutOfSet") == false then

			-- check first to see how many songs are remaining
			-- if none...
			if SL.Global.Stages.Remaining <= 0 then

				if SL.Global.ContinuesRemaining > 0 then

					local CoinsNeeded = PREFSMAN:GetPreference("CoinsPerCredit")
					local premium = PREFSMAN:GetPreference("Premium")

					if premium == "Premium_DoubleFor1Credit" then
						if SL.Global.Gamestate.Style == "versus" then
							CoinsNeeded = CoinsNeeded * 2
						end

					elseif premium == "Premium_Off" then
						if SL.Global.Gamestate.Style == "versus" or SL.Global.Gamestate.Style == "double" then
							CoinsNeeded = CoinsNeeded * 2
						end
					end

					if GAMESTATE:GetCoins() >= CoinsNeeded then
						return "ScreenPlayAgain"
					else
						return Branch.AllowScreenEvalSummary()
					end
				else
					return Branch.AllowScreenEvalSummary()
				end


			-- otherwise, there are some stages remaining
			else

				-- However, if the player(s) just failed, then SM thinks there are no stages remaining
				-- so IF the player(s) did fail, reinstate the appropriate number of stages.
				-- If we don't do this, and simply send the player(s) back to ScreenSelectMusic,
				-- the MusicWheel will be empty (because SM believes there are no stages remaining)!
				if STATSMAN:GetCurStageStats():AllFailed() then
					local Players = GAMESTATE:GetHumanPlayers()
					for pn in ivalues(Players) do
						for i=1, SL.Global.Stages.Remaining do
							GAMESTATE:AddStageToPlayer(pn)
						end
					end
				end

				return SelectMusicOrCourse()
			end

		-- else we DO allow players to possibly fail out of a set
		else

			if STATSMAN:GetCurStageStats():AllFailed() or GAMESTATE:GetSmallestNumStagesLeftForAnyHumanPlayer() == 0 then
				local credits = GetCredits()
				if credits.Credits > 0 then
					return "ScreenPlayAgain"
				else
					return Branch.AllowScreenEvalSummary()
				end

			else
				return SelectMusicOrCourse()
			end

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