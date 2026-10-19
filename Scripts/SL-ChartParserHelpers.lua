-- ----------------------------------------------------------------
-- This file (SL-ChartParserHelpers.lua) contains helpers for deriving
-- auxiliary data from a chart's engine-cached notes-per-measure values.

-- For example, getting the information for the measure counter depends on
-- the value chosen for the notesPerMeasure threshold.


-- ----------------------------------------------------------------
-- Get the start/end of each stream and break sequence in our table of measures
-- TODO(teejusb): Make this smarter as we can probably automatically figure
-- out a good value for notesThreshold from the chart information.
GetStreamSequences = function(notesPerMeasure, notesThreshold)
	local streamMeasures = {}
	for i,n in ipairs(notesPerMeasure) do
		if n >= notesThreshold then
			table.insert(streamMeasures, i)
		end
	end

	local streamSequences = {}

	-- Count every "stream" measure.
	local streamSequenceThreshold = 1
	-- Ignore (1) breaks as those are implicitly determined already by virtue
	-- of seeing two streams in sequence (instead of one combined larger sequence).
	local breakSequenceThreshold = 2

	local counter = 1
	local streamEnd = nil

	-- First add an initial break if it's larger than breakSequenceThreshold
	if #streamMeasures > 0 then
		local breakStart = 0
		local k, curVal = next(streamMeasures) -- first element of a table
		local breakEnd = curVal - 1
		if (breakEnd - breakStart >= breakSequenceThreshold) then
			table.insert(streamSequences,
				{streamStart=breakStart, streamEnd=breakEnd, isBreak=true})
		end
	end

	-- Which sequences of measures are considered a stream?
	for k, curVal in pairs(streamMeasures) do
		local nextVal = streamMeasures[k+1] and streamMeasures[k+1] or -1

		-- Are we still in sequence?
		if curVal + 1 == nextVal then
			counter = counter + 1
			streamEnd = curVal + 1
		else
			-- Found the first section that counts as a stream
			if(counter >= streamSequenceThreshold) then
				if streamEnd == nil then
					streamEnd = curVal
				end
				local streamStart = (streamEnd - counter)
				-- Add the current stream.
				table.insert(streamSequences,
					{streamStart=streamStart, streamEnd=streamEnd, isBreak=false})
			end

			-- Add any trailing breaks if they're larger than breakSequenceThreshold
			local breakStart = curVal
			local breakEnd = (nextVal ~= -1) and nextVal - 1 or #notesPerMeasure
			if (breakEnd - breakStart >= breakSequenceThreshold) then
				table.insert(streamSequences,
					{streamStart=breakStart, streamEnd=breakEnd, isBreak=true})
			end
			counter = 1
			streamEnd = nil
		end
	end

	return streamSequences
end

-- ----------------------------------------------------------------
-- Get the breakdown text from the engine for the requested 'minimization level'.
--
-- Refer to the following example for what's the expected output.
--
-- minimization_level = 0  ->  No Minimization
--    20 (2) 30-10 (32) 16 (8) 4
--
-- minimization_level = 1  -> Basic Stream Notation
--    20-30-10|16/4
--
-- minimization_level = 2  -> Adding "broken" notation
--    61*/16/4
--
-- minimization_level = 3  -> Aggregating total streams
--    80 Total
GenerateBreakdownText = function(breakdown, minimization_level)
	local text
	if breakdown then
		if minimization_level == 3 then
			if breakdown.TotalStream ~= 0 then
				text = string.format("%d Total", breakdown.TotalStream)
			end
		else
			text = breakdown.Texts[minimization_level + 1]
		end
	end
	if not text or text == "" then return 'No streams!' end
	return text
end
