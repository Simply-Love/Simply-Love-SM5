return function(SongNumberInCourse)
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do

		-- get the PlayerOptions string for any human players and store it now
		-- we'll retrieve it the next time ScreenSelectMusic loads and re-apply those same mods
		-- in this way, we can override the effects of songs that forced modifiers during gameplay
		-- the old-school (ie. ITG) way of GAMESTATE:ApplyGameCommand()
		local pn = ToEnumShortString(player)
		SL[pn].PlayerOptionsString = GAMESTATE:GetPlayerState(player):GetPlayerOptionsString("ModsLevel_Preferred")


		-- Check if MeasureCounter is turned on.  We may need to parse the chart.
		local mods = SL[pn].ActiveModifiers
		if mods.MeasureCounter and mods.MeasureCounter ~= "None" then

			local steps = nil

			if GAMESTATE:IsCourseMode() then
				local trail = GAMESTATE:GetCurrentTrail(player):GetTrailEntries()[SongNumberInCourse+1]
				steps = trail:GetSteps()
			else
				steps = GAMESTATE:GetCurrentSteps(player)
			end

			local steps_type = ToEnumShortString( steps:GetStepsType() ):gsub("_", "-"):lower()
			local difficulty = ToEnumShortString( steps:GetDifficulty() )
			local notes_per_measure = tonumber(mods.MeasureCounter:match("%d+"))

			-- if any of these don't match what we're currently looking for...
			if SL[pn].Streams.Steps ~= steps or SL[pn].Streams.StepsType ~= steps_type or SL[pn].Streams.Difficulty ~= difficulty then

				-- ...then parse the simfile, given the current parameters
				SL[pn].Streams.Measures = GetStreams(steps, steps_type, difficulty, notes_per_measure)

				-- and set these so we can check again next time.
				SL[pn].Streams.Steps      = steps
				SL[pn].Streams.StepsType  = steps_type
				SL[pn].Streams.Difficulty = difficulty
			end
		end
	end
end