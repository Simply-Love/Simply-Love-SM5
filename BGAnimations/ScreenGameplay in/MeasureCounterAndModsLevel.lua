-- Get the start/end of each stream and break sequence in our table of measures
local GetStreamSequences = function(notesPerMeasure, notesThreshold)
	local streamMeasures = {}
	for i,n in ipairs(notesPerMeasure) do
		Trace(tostring(i)..": "..tostring(n))
		if n >= notesThreshold then
			table.insert(streamMeasures, i)
		end
	end

	local streamSequences = {}
	-- Count every measure as stream/non-stream.
	-- We can then later choose how we want to display the information.
	local measureSequenceThreshold = 1

	local counter = 1
	local streamEnd = nil

	-- First add an initial break if it's larger than measureSequenceThreshold
	if #streamMeasures > 0 then
		local breakStart = 0
		local k, v = next(streamMeasures) -- first element of a table
		local breakEnd = streamMeasures[k] - 1
		if (breakEnd - breakStart >= measureSequenceThreshold) then
			table.insert(streamSequences,
				{streamStart=breakStart, streamEnd=breakEnd, isBreak=true})
		end
	end

	-- Which sequences of measures are considered a stream?
	for k,v in pairs(streamMeasures) do
		local curVal = streamMeasures[k]
		local nextVal = streamMeasures[k+1] and streamMeasures[k+1] or -1

		-- Are we still in sequence?
		if curVal + 1 == nextVal then
			counter = counter + 1
			streamEnd = curVal + 1
		else
			-- Found the first section that counts as a stream
			if(counter >= measureSequenceThreshold) then
				if streamEnd == nil then
					streamEnd = curVal
				end
				local streamStart = (streamEnd - counter)
				-- Add the current stream.
				table.insert(streamSequences,
					{streamStart=streamStart, streamEnd=streamEnd, isBreak=false})
			end

			-- Add any trailing breaks if they're larger than measureSequenceThreshold
			local breakStart = curVal
			local breakEnd = (nextVal ~= -1) and nextVal - 1 or #notesPerMeasure
			if (breakEnd - breakStart >= measureSequenceThreshold) then
				table.insert(streamSequences,
					{streamStart=breakStart, streamEnd=breakEnd, isBreak=true})
			end
			counter = 1
			streamEnd = nil
		end
	end

	return streamSequences
end

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

			-- This will parse out and set all the required info for the chart in the SL.Streams cache,
			-- The function will only do work iff we're parsing a chart different than what's in the cache.
			ParseChartInfo(steps, pn)

			-- Set the actual stream information for the player based on their selected notes threshold.
			local notesThreshold = tonumber(mods.MeasureCounter:match("%d+"))
			SL[pn].Streams.Measures = GetStreamSequences(SL[pn].Streams.NotesPerMeasure, notesThreshold)
		end
	end
end