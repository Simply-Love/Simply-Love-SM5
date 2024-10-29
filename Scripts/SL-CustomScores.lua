function nilIfEmpty(s)
	if s == "" then
		return nil
	end
	return s
end

function WriteScores()
	local template = {
		Version = 1,
		Theme = THEME:GetThemeDisplayName(),
		ThemeVersion = tostring(GetThemeVersion()),
		ProductID = ProductID(),
		ProductVersion = ProductVersion(),
		MachineGuid = PROFILEMAN:GetMachineProfile():GetGUID(),
		GameMode = SL.Global.GameMode,
	}

	for player in ivalues(GAMESTATE:GetHumanPlayers()) do
		local content = {}
		for k, v in pairs(template) do
			content[k] = v
		end

		local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
		local highscore = pss:GetHighScore()
		local actualRadar = pss:GetRadarActual()
		local possibleRadar = pss:GetRadarPossible()

		content.Score = {
			Guid = CRYPTMAN:GenerateRandomUUID(),
			Grade = ToEnumShortString(highscore:GetGrade()),
			Score = highscore:GetScore(),
			PercentDP = highscore:GetPercentDP(),
			SurviveSeconds = highscore:GetSurvivalSeconds(),
			MaxCombo = highscore:GetMaxCombo(),
			Modifiers = highscore:GetModifiers(),
			DateTime = highscore:GetDate(),
			PlayerGuid = PROFILEMAN:GetProfile(player):GetGUID(),
			Disqualified = pss:IsDisqualified(),
			TapNoteScores = {
				W1 = highscore:GetTapNoteScore("TapNoteScore_W1"),
				W2 = highscore:GetTapNoteScore("TapNoteScore_W2"),
				W3 = highscore:GetTapNoteScore("TapNoteScore_W3"),
				W4 = highscore:GetTapNoteScore("TapNoteScore_W4"),
				W5 = highscore:GetTapNoteScore("TapNoteScore_W5"),
				Miss = highscore:GetTapNoteScore("TapNoteScore_Miss"),
				HitMine = highscore:GetTapNoteScore("TapNoteScore_HitMine"),
				AvoidMine = highscore:GetTapNoteScore("TapNoteScore_AvoidMine"),
				CheckpointMiss = highscore:GetTapNoteScore("TapNoteScore_CheckpointMiss"),
				CheckpointHit = highscore:GetTapNoteScore("TapNoteScore_CheckpointHit"),
			},
			HoldNoteScores = {
				LetGo = highscore:GetHoldNoteScore("HoldNoteScore_LetGo"),
				Held = highscore:GetHoldNoteScore("HoldNoteScore_Held"),
				MissedHold = highscore:GetHoldNoteScore("HoldNoteScore_MissedHold"),
			},
			Radar = {
				Notes = actualRadar:GetValue("RadarCategory_Notes"),
				TapsAndHolds = actualRadar:GetValue("RadarCategory_TapsAndHolds"),
				Jumps = actualRadar:GetValue("RadarCategory_Jumps"),
				Holds = actualRadar:GetValue("RadarCategory_Holds"),
				Mines = actualRadar:GetValue("RadarCategory_Mines"),
				Hands = actualRadar:GetValue("RadarCategory_Hands"),
				Rolls = actualRadar:GetValue("RadarCategory_Rolls"),
			},
		}

		local song = GAMESTATE:GetCurrentSong()
		local course = GAMESTATE:GetCurrentCourse()

		if course ~= nil then
			local trail = GAMESTATE:GetCurrentTrail(player)

			-- There is no GetFullTitle() method, so we have to
			-- fake it by temporarily overwriting the
			-- ShowNativeLanguage preference.
			local showNativeLanguage = PREFSMAN:GetPreference("ShowNativeLanguage")
			PREFSMAN:SetPreference('ShowNativeLanguage', true)
			local fullTitle = course:GetDisplayFullTitle()
			PREFSMAN:SetPreference('ShowNativeLanguage', showNativeLanguage)

			local radarValues
			if possibleRadar:GetValue("RadarCategory_Notes") == -1 then
				radarValues = nil
			else
				radarValues = {
					Notes = possibleRadar:GetValue("RadarCategory_Notes"),
					TapsAndHolds = possibleRadar:GetValue("RadarCategory_TapsAndHolds"),
					Jumps = possibleRadar:GetValue("RadarCategory_Jumps"),
					Holds = possibleRadar:GetValue("RadarCategory_Holds"),
					Mines = possibleRadar:GetValue("RadarCategory_Mines"),
					Hands = possibleRadar:GetValue("RadarCategory_Hands"),
					Rolls = possibleRadar:GetValue("RadarCategory_Rolls"),
				}
			end


			content.Course = {
				Path = nilIfEmpty(course:GetCourseDir()),
				FullTitle = fullTitle,
				TranslitFullTitle = course:GetTranslitFullTitle(),
				Scripter = nilIfEmpty(course:GetScripter()),
				Description = nilIfEmpty(course:GetDescription()),
			}
			content.Trail = {
				Difficulty = ToEnumShortString(trail:GetDifficulty()),
				Meter = trail:GetMeter(),
				StepsType = ToEnumShortString(trail:GetStepsType()):lower():gsub('_', '-'),
				LengthSeconds = trail:GetLengthSeconds(),
				Radar = radarValues,
			}
		elseif song ~= nil then
			local steps = GAMESTATE:GetCurrentSteps(player)

			-- There are no GetArtist() and GetSubTitle() methods,
			-- so we have to fake them by temporarily overwriting
			-- the ShowNativeLanguage preference.
			local showNativeLanguage = PREFSMAN:GetPreference("ShowNativeLanguage")
			PREFSMAN:SetPreference('ShowNativeLanguage', true)
			local artist = song:GetDisplayArtist()
			local subtitle = song:GetDisplaySubTitle()
			PREFSMAN:SetPreference('ShowNativeLanguage', showNativeLanguage)

			content.Song = {
				Dir = song:GetSongDir(),
				Group = song:GetGroupName(),
				Title = song:GetMainTitle(),
				SubTitle = nilIfEmpty(subtitle),
				Artist = nilIfEmpty(artist),
				TranslitTitle = song:GetTranslitMainTitle(),
				TranslitSubTitle = nilIfEmpty(song:GetTranslitSubTitle()),
				TranslitArtist = nilIfEmpty(song:GetTranslitArtist()),
				Genre = nilIfEmpty(song:GetGenre()),
				BPM = song:GetDisplayBpms(),
				RandomBPM = song:IsDisplayBpmRandom(),
				MusicLengthSeconds = song:MusicLengthSeconds(),
			}
			content.Steps = {
				Difficulty = ToEnumShortString(steps:GetDifficulty()),
				Meter = steps:GetMeter(),
				StepsType = ToEnumShortString(steps:GetStepsType()):lower():gsub('_', '-'),
				AuthorCredit = steps:GetAuthorCredit(),
				Description = steps:GetDescription(),
				Radar = {
					Notes = possibleRadar:GetValue("RadarCategory_Notes"),
					TapsAndHolds = possibleRadar:GetValue("RadarCategory_TapsAndHolds"),
					Jumps = possibleRadar:GetValue("RadarCategory_Jumps"),
					Holds = possibleRadar:GetValue("RadarCategory_Holds"),
					Mines = possibleRadar:GetValue("RadarCategory_Mines"),
					Hands = possibleRadar:GetValue("RadarCategory_Hands"),
					Rolls = possibleRadar:GetValue("RadarCategory_Rolls"),
				},
			}
		end

		-- Don't store scores for guest profiles or autoplay
		if PROFILEMAN:IsPersistentProfile(player) and GAMESTATE:IsSideJoined(player) and IsHumanPlayer(player) then
			local profileSlot = {
				[PLAYER_1] = "ProfileSlot_Player1",
				[PLAYER_2] = "ProfileSlot_Player2"
			}
			local profileDir  = PROFILEMAN:GetProfileDir(profileSlot[player])
			local date = highscore:GetDate()

			-- Remove colons from date, because they are not
			-- allowed on FAT file systems (especially important
			-- for USB profiles)
			local filename = date:gsub(':', '') .. ".json"

			local f = RageFileUtil.CreateRageFile()
			if f:Open(profileDir .. "SL-Scores/" .. filename, 2) then
				f:Write(JsonEncode(content, true))
			end
			f:destroy()
		end
	end
end
