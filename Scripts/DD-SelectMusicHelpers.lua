-- ----------------------------------------------------------------------------------------
-- functions used by ScreenSelectMusicDD

-- used by ScreenSelectMusicDD to play preview music of the current song
-- this is invoked each time the custom MusicWheel changes focus
play_sample_music = function()
	if GAMESTATE:IsCourseMode() then return end
	local song = GAMESTATE:GetCurrentSong()

	if song then
		local songpath = song:GetMusicPath()
		local sample_start = song:GetSampleStart()
		local sample_len = song:GetSampleLength()

		if songpath and sample_start and sample_len then
			SOUND:DimMusic(PREFSMAN:GetPreference("SoundVolume"), math.huge)
			SOUND:PlayMusicPart(songpath, sample_start,sample_len, 0.5, 1.5, false, true)
		else
			stop_music()
		end
	else
		stop_music()
	end
end

-- used by ScreenSelectMusicDD to stop playing preview music,
-- this is invoked every time the custom MusicWheel changes focus
-- if the new focus is on song item, play_sample_music() will be invoked immediately afterwards
-- ths is also invoked when the player closes the current group to choose some other group
stop_music = function()
	SOUND:PlayMusicPart("", 0, 0)
end


----------------------------------------------------------------------------------------
-- functions used by ScreenSelectMusic

-- TextBanner is an engine-defined ActorFrame that contains three BitmapText actors named
-- "Title", "Subtitle", and "Artist".  Digital Dance's MusicWheel only uses the first two.
--
-- It has two unique Metrics, "AfterSetCommand" and "ArtistPrependString"
-- Digital Dance is only concerned with "AfterSetCommand"
-- because the song Artist does not appear in each MusicWheelItem

TextBannerAfterSet = function(self)
	-- acquire handles to two of the BitmapText children of this TextBanner ActorFrame
	-- we'll use them to position each song's Title and Subtitle as they appear in the MusicWheel
	local Title = self:GetChild("Title")
	local Subtitle = self:GetChild("Subtitle")

	-- assume the song's Subtitle is an empty string by default and position the Title
	-- in the vertical middle of the MusicWheelItem
	Title:y(0)

	-- if the Subtitle isn't an empty string
	if Subtitle:GetText() ~= "" then
		-- offset the Title's y() by -6 pixels
		Title:y(-6)
		-- and offset the Subtitle's y() by 6 pixels
		Subtitle:y(6)
	end
end

----------------------------------------------------------------------------------------
-- functions used by both SSM and ScreenSelectMusicDD

SSM_Header_StageText = function()

	-- if the continue system is enabled, don't worry about determining "Final Stage"
	if ThemePrefs.Get("NumberOfContinuesAllowed") > 0 then
		return THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)
	end

	local topscreen = SCREENMAN:GetTopScreen()
	if topscreen then

		-- if we're on ScreenEval for normal gameplay
		-- we might want to display the text for StageFinal, or we might want to
		-- increment the Stages.PlayedThisGame by the cost of the song that was just played
		if topscreen:GetName() == "ScreenEvaluationStage" then
			local song = GAMESTATE:GetCurrentSong()
			local Duration = song:GetLastSecond()
			local DurationWithRate = Duration / SL.Global.ActiveModifiers.MusicRate

			local LongCutoff = PREFSMAN:GetPreference("LongVerSongSeconds")
			local MarathonCutoff = PREFSMAN:GetPreference("MarathonVerSongSeconds")

			local IsMarathon = (DurationWithRate/MarathonCutoff > 1)
			local IsLong 	 = (DurationWithRate/LongCutoff > 1)

			local SongCost = (IsMarathon and 3) or (IsLong and 2) or 1

			if SL.Global.Stages.PlayedThisGame + SongCost >= PREFSMAN:GetPreference("SongsPerPlay") then
				return THEME:GetString("Stage", "Final")
			else
				return THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + SongCost)
			end

		-- if we're on ScreenEval within Marathon Mode, generic text will suffice
		elseif topscreen:GetName() == "ScreenEvaluationNonstop" then
			return THEME:GetString("ScreenSelectPlayMode", "Marathon")

		-- if we're on ScreenSelectMusic, display the number of Stages.PlayedThisGame + 1
		-- the song the player actually selects may cost more than 1, but we cannot know that now
		else
			return THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)
		end
	end
end


--- Returns the grade for a given song and chart or nil if there isn't a high score.
--- @param player Enum
--- @param songParam Song
--- @param chartParam Steps
--- @param rateParam boolean
function GetTopGrade(player, songParam, chartParam)
	local song = GAMESTATE:GetCurrentSong()
	local chart = GAMESTATE:GetCurrentSteps(player)
	local grade
	local pn = ToEnumShortString(player)
	
	if song then
		local score = PROFILEMAN:GetProfile(pn):GetHighScoreList(song,chart):GetHighScores()[1]
		if score then
			grade = score:GetGrade()
		else
		end
		if grade then
			local converted_grade = Grade:Reverse()[grade]
			if converted_grade > 17 then converted_grade = 17 end
			return converted_grade
		end
	else end
	return nil
end