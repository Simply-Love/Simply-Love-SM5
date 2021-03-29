-- ----------------------------------------------------------------
-- This file (SL-ChartParserHelpers.lua) is used to populate auxilliary
-- data which is oftem based off the data parsed form ChartParseInfo.

-- The main use case is when this auxilliary information might depend on 
-- extra information that isn't available during the Chart Parsing stage.

-- For example, getting the information for the measure counter depends on
-- the value chosen for notesPerMeasure threshold, which isn't/shouldn't be
-- known during the chart parsing stage.


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
	-- Count every measure as stream/non-stream.
	-- We can then later choose how we want to display the information.
	local measureSequenceThreshold = 1

	local counter = 1
	local streamEnd = nil

	-- First add an initial break if it's larger than measureSequenceThreshold
	if #streamMeasures > 0 then
		local breakStart = 0
		local k, curVal = next(streamMeasures) -- first element of a table
		local breakEnd = curVal - 1
		if (breakEnd - breakStart >= measureSequenceThreshold) then
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

-- Generate Breakdown text using commonly known stream notation.
-- We also include an option for compressing the output text based off of a
-- 'minimization level'.
--
-- We use the following mapping for stream notations:
--    "-" = Break between [0, 4] measures
--    "/" = Break between [5, 32) measures
--    "|" = Break greater than or equal to 32 measures
--
-- For the "*" notation, we also accumulate the "-" breaks as part of the
-- reported number.
--
-- Refer to the following example for what's the expected output.
--
-- minimization_level = 0  ->  No Minimization
--    20 (2) 30 (1) 10 (32) 16 (8) 4
--
-- minimization_level = 1  -> Basic Stream Notation
--    20-30-10|16/4
--
-- minimization_level = 2  -> Adding "broken" notation
--    63*/16/4
--
-- minimization_level = 3  -> Aggregating total streams
--    80 Total
GenerateBreakdownText = function(pn, minimization_level)
	if #SL[pn].Streams.NotesPerMeasure == 0 then return 'No Streams!' end

	-- Assume 16ths for the breakdown text
	local segments = GetStreamSequences(SL[pn].Streams.NotesPerMeasure, 16)

	local text_segments = {}
	
	if minimization_level <= 2 then
		-- Variables for level 2 minimization
		local segment_sum = 0
		local is_broken = false

		for i, segment in ipairs(segments) do
			local size = segment.streamEnd - segment.streamStart
			if segment.isBreak then
				-- Never include leading and trailing breaks.
				if i ~= 1 and i ~= #segments then
					if minimization_level == 0 then
						text_segments[#text_segments+1] = " (" .. tostring(size) .. ") "
					else
						if size <= 4 then
							if minimization_level == 1 then
								text_segments[#text_segments+1] = "-"
							else
								segment_sum = segment_sum + size
								is_broken = true
							end
						elseif size < 32 then
							if minimization_level == 2 and segment_sum ~= 0 then
								text_segments[#text_segments+1] = tostring(segment_sum) .. (is_broken and "*" or "")
							end
							text_segments[#text_segments+1] = "/"
							is_broken = false
							segment_sum = 0
						else
							if minimization_level == 2 and segment_sum ~= 0 then
								text_segments[#text_segments+1] = tostring(segment_sum) .. (is_broken and "*" or "")
							end
							text_segments[#text_segments+1] = "|"
							is_broken = false
							segment_sum = 0
						end
					end
				end
			else
				if minimization_level == 2 then
					-- These segments get added to the text_segments table when we encounter a large enough break.
					segment_sum = segment_sum + size
				else
					text_segments[#text_segments+1] = tostring(size)
				end
			end
		end
		
		-- Add any trailing segments we haven't accounted for yet.
		if minimization_level == 2 and segment_sum ~= 0 then
			text_segments[#text_segments+1] = tostring(segment_sum) .. (is_broken and "*" or "")
		end
	else
		local sum = 0
		for i, segment in ipairs(segment) do
			if not segment.isBreak then
				sum = sum + segment.streamEnd - segment.streamStart
			end
		end
	end

	if #text_segments == 0 then
		return 'No Streams!'
	else
		return table.concat(text_segments, '')
	end
end