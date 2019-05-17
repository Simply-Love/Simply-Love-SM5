return function(SongNumberInCourse)
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do

		-- get the PlayerOptions string for any human players and store it now
		-- we'll retreive it the next time ScreenSelectMusic loads and re-apply those same mods
		-- in this way, we can override the effects of songs that forced modifiers during gameplay
		-- the old-school (ie. ITG) way of GAMESTATE:ApplyGameCommand()
		local pn = ToEnumShortString(player)
		SL[pn].CurrentPlayerOptions.String = GAMESTATE:GetPlayerState(player):GetPlayerOptionsString("ModsLevel_Preferred")


		-- Check if MeasureCounter is turned on.  We may need to parse the chart.
		local mods = SL[pn].ActiveModifiers
		if mods.MeasureCounter and mods.MeasureCounter ~= "None" then

			local song_dir, steps
			if GAMESTATE:IsCourseMode() then
				local trail = GAMESTATE:GetCurrentTrail(player):GetTrailEntries()[SongNumberInCourse+1]
				song_dir = trail:GetSong():GetSongDir()
				steps = trail:GetSteps()
			else
				song_dir = GAMESTATE:GetCurrentSong():GetSongDir()
				steps = GAMESTATE:GetCurrentSteps(player)
			end

			local steps_type = ToEnumShortString( steps:GetStepsType() ):gsub("_", "-"):lower()
			local difficulty = ToEnumShortString( steps:GetDifficulty() )
			local notes_per_measure = tonumber(mods.MeasureCounter:match("%d+"))
			local threshold_to_be_stream = 2

			-- if any of these don't match what we're currently looking for...
			if SL[pn].Streams.SongDir ~= song_dir or SL[pn].Streams.StepsType ~= step_type or SL[pn].Streams.Difficulty ~= difficulty then

				-- ...then parse the simfile, given the current parameters
				SL[pn].Streams.Measures = GetStreams(song_dir, steps_type, difficulty, notes_per_measure, threshold_to_be_stream)
				-- and set these so we can check again next time.
				SL[pn].Streams.SongDir = song_dir
				SL[pn].Streams.StepsType = steps_type
				SL[pn].Streams.Difficulty = difficulty
			end
		end
	end
end