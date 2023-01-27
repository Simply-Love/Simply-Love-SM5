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
GenerateBreakdownText = function(pn, minimization_level)
	if #SL[pn].Streams.NotesPerMeasure == 0 then return 'Not available!' end

	-- Assume 16ths for the breakdown text
	local segments = GetStreamSequences(SL[pn].Streams.NotesPerMeasure, 16)
	local text_segments = {}

	-- The following is used for level 2 and 3 minimization levels.
	local segment_sum = 0
	local is_broken = false
	local total_sum = 0

	local AddNotationForSegment = function(
			notation, segment_size, minimization_level, text_segments, segment_sum, is_broken, total_sum)
		if minimization_level == 0 then
			text_segments[#text_segments+1] = " (" .. tostring(segment_size) .. ") "
		else
			if segment_sum ~= 0 then
				if minimization_level == 2 then
					text_segments[#text_segments+1] = tostring(segment_sum) .. (is_broken and "*" or "")
				elseif minimization_level == 3 then
					total_sum = total_sum + segment_sum
				end
			end
			if minimization_level ~= 3 then
				text_segments[#text_segments+1] = notation
			end

			is_broken = false
			segment_sum = 0
		end

		-- The variables that might get updated need to be returned.
		-- text_segments is "pass by value" so don't need to explicitly return it.
		return segment_sum, is_broken, total_sum
	end

	for i, segment in ipairs(segments) do
		local segment_size = segment.streamEnd - segment.streamStart
		if segment.isBreak then
			if i ~= 1 and i ~= #segments and segment_size <= 3 and (minimization_level == 2 or minimization_level == 3) then
				-- Don't count this as a true "break"
				is_broken = true
				-- For * notation, we want to add short breaks as part of the number.
				if minimization_level == 2 then
					segment_sum = segment_sum + segment_size
				end
			else
				-- Never include leading and trailing breaks.
				if i ~= 1 and i ~= #segments then
					-- Break segments of size 1 aren't handled here as they don't show up.
					-- Instead we handle them below when we see two stream sequences in succession.
					if segment_size <= 4 then
						segment_sum, is_broken, total_sum = AddNotationForSegment(
							"-", segment_size, minimization_level, text_segments, segment_sum, is_broken, total_sum)
					elseif segment_size < 32 then
						segment_sum, is_broken, total_sum = AddNotationForSegment(
							"/",  segment_size, minimization_level, text_segments, segment_sum, is_broken, total_sum)
					else
						segment_sum, is_broken, total_sum = AddNotationForSegment(
							" | ",  segment_size, minimization_level, text_segments, segment_sum, is_broken, total_sum)
					end
				end
			end
		else
			if minimization_level == 2 or minimization_level == 3 then
				if i > 1 and not segments[i-1].isBreak then
					-- Don't count this as a true "break"
					is_broken = true
					-- For * notation, we want to add short breaks as part of the number.
					if minimization_level == 2 then
						segment_sum = segment_sum + 1
					end
				end
				-- For minimization_level == 2, these segments get added to the text_segments table
				-- when we encounter a large enough break. For minimization_level == 3, these segments
				-- get summed up before reporting the total.
				segment_sum = segment_sum + segment_size
			else
				-- If we find two streams in sequence, then there's an implicit (1) in between.
				-- Make sure we still account for that for minimization levels 0 and 1.
				if i > 1 and not segments[i-1].isBreak then
					text_segments[#text_segments+1] = "-"
				end
				text_segments[#text_segments+1] = tostring(segment_size)
			end
		end
	end
	
	-- Add any trailing segments we haven't accounted for yet.
	if segment_sum ~= 0 then
		if minimization_level == 2 then
			text_segments[#text_segments+1] = tostring(segment_sum) .. (is_broken and "*" or "")
		elseif minimization_level == 3 then
			total_sum = total_sum + segment_sum
		end
	end

	if minimization_level == 3 then
		return string.format("%d Total", total_sum)
	elseif #text_segments == 0 then
		return 'No Streams!'
	else
		return table.concat(text_segments, '')
	end
end

-- ----------------------------------------------------------------
-- Returns the total amount of stream and break measures in a chart.
GetTotalStreamAndBreakMeasures = function(pn)
	local totalStream, totalBreak = 0, 0
	local edgeBreak = 0

	-- Assume 16ths for the breakdown text
	local segments = GetStreamSequences(SL[pn].Streams.NotesPerMeasure, 16)
	for i, segment in ipairs(segments) do
		local segment_size = segment.streamEnd - segment.streamStart
		if segment.isBreak and i < #segments and i ~= 1 then
			totalBreak = totalBreak + segment_size
		elseif segment.isBreak then
			edgeBreak = edgeBreak + segment_size
		else
			totalStream = totalStream + segment_size
		end
	end
	
	if totalStream + totalBreak < 10 or totalStream + totalBreak < edgeBreak then
		totalBreak = totalBreak + edgeBreak
	end

	return totalStream, totalBreak
end
