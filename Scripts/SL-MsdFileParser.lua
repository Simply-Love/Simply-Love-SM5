-- Parse the generic MsdFile (used for SSC and SM files).
-- Translated directly from the source here:
-- https://github.com/stepmania/stepmania/blob/master/src/MsdFile.cpp#L32


-- The original MSD format is simply:

-- #PARAM0:PARAM1:PARAM2:PARAM3;
-- #NEXTPARAM0:PARAM1:PARAM2:PARAM3;

-- (The first field is typically an identifier, but doesn't have to be.)

-- The semicolon is not optional, though if we hit a # on a new line, eg:
-- #VALUE:PARAM1
-- #VALUE2:PARAM2
-- we'll recover.

function ParseMsdFile(steps)
	local function AddParam(t, p, plen, fileType)
		-- table.concat(table_name, separator, start, end)
		local param = table.concat(p, '', 1, plen)

		-- Normalize all line endings to \n and remove all leading and trailing whitespace.
		param = param:gsub('\r\n?', '\n'):match('^%s*(.-)%s*$')

		-- Field specific modifications. We length check the last table to make sure we're
		-- actually parsing what we want.
		-- TODO(teejusb): We should probably do this for most fields for consistency.
		if #t[#t] == 6 and (t[#t][1] == 'NOTES' or t[#t][1] == 'NOTES2') and fileType == "sm" then
			-- Remove all whitespace that isn't the \n character.
			-- NOTE(teejusb): NOTES in the SM file has multiple parts. We specifically only want to strip
			-- the 6th part (the chart data), as the others can contain spaces e.g. chart description.
			param = param:gsub('[\r\t\f\v ]+', '')
		elseif #t[#t] == 1 and (t[#t][1] == 'NOTES' or t[#t][1] == 'NOTES2') and fileType == "ssc" then
			-- Remove all whitespace that isn't the \n character.
			-- NOTE(teejusb): NOTES in an SSC file only contains the chart data itself.
			param = param:gsub('[\r\t\f\v ]+', '')
		elseif #t[#t] == 1 and t[#t][1] == 'BPMS' then
			-- Whitespace doesn't matter for BPMs, remove them all.
			param = param:gsub('%s+', '')
		end

		table.insert(t[#t], param)
	end

	local simfileString, fileType = GetSimfileString(steps)
	if not simfileString then return {} end

	local final = {}
	local length = simfileString:len()
	local ReadingValue = false
	local processed = {}
	for i = 0, length - 1 do
		table.insert(processed, '\0')
	end
	local i = 0
	local processedLen = -1

	-- Lua doesn't have continue so use a bool to emulate it and skip the operations we don't want to perform.
	local continue = false

	while i < length do
		-- We create a local variable that we can reuse to minimize the number of sub() calls.
		local curChar = simfileString:sub(i+1, i+1)

		if i + 1 < length then
			if curChar == '/' and simfileString:sub(i+2, i+2) == '/' then
				-- Skip a comment entirely; don't copy the comment to the value/parameter
				i = simfileString:find('\n', i+1)
				if i == nil then
					-- If we can't find an endline, then assume we're done.
					i = simfileString:len()
				else
					-- s:find() will return the index of the character found. We want the value before it.
					i = i - 1
				end

				continue = true
			end
		end

		if not continue and ReadingValue and curChar == '#' then
			-- Unfortunately, many of these files are missing ;'s.
			-- If we get a # when we thought we were inside a value, assume we
			-- missed the ;.  Back up and end the value.
			-- Make sure this # is the first non-whitespace character on the line.
			local firstChar = true
			local j = processedLen
			while j > 0 and processed[j] ~= '\r' and processed[j] ~= '\n' do
				if(processed[j] == ' ' or processed[j] == '\t') then
					j = j - 1
				else
					firstChar = false
					break
				end
			end

			if not firstChar then
				-- We're not the first char on a line.  Treat it as if it were a normal character.
				processed[processedLen+1] = curChar
				processedLen = processedLen + 1
				i = i + 1
				continue = true
			end

			if not continue then
				-- Skip newlines and whitespace before adding the value.
				processedLen = j
				while (processedLen > 0 and
					   (processed[processedLen] == '\r' or
					    processed[processedLen] == '\n' or
					    processed[processedLen] == ' ' or
					    processed[processedLen] == '\t')) do
					processedLen = processedLen - 1
				end

				AddParam(final, processed, processedLen, fileType)

				processedLen = 0
				ReadingValue = false
			end
		end

		-- # starts a new value.
		if not continue and not ReadingValue and curChar == '#' then
			table.insert(final, {})
			ReadingValue = true
		end

		if not continue and not ReadingValue then
			if curChar == '\\' then
				i = i + 2
			else
				i = i + 1
			end
			-- nothing else is meaningful outside of a value
			continue = true
		end

		-- : and ; end the current param, if any.
		if not continue and processedLen ~= -1 and (curChar == ':' or curChar == ';') then
			AddParam(final, processed, processedLen, fileType)
		end

		-- # and : begin new params.
		if not continue and (curChar == '#' or curChar == ':') then
			i = i + 1
			processedLen = 0
			continue = true
		end

		-- ; ends the current value.
		if not continue and curChar == ';' then
			ReadingValue = false
			i = i + 1
			continue = true
		end

		-- We've gone through all the control characters.  All that is left is either an escaped character,
		-- ie \#, \\, \:, etc., or a regular character.
		-- NOTE: There is usually an 'unescape' bool passed to this top level function,
		-- but when reading SM/SSC files it's always set to true so we assume that.
		if not continue and i < length and curChar == '\\' then
			i = i + 1
		end

		-- Add any unterminated value at the very end.
		if not continue and i < length then
			processed[processedLen+1] = curChar
			processedLen = processedLen + 1
			i = i + 1
		end

		continue = false
	end

	if ReadingValue then
		AddParam(final, processed, processedLen, fileType)
	end

	return final, fileType
end