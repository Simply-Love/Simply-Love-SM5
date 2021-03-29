GetSimfileString = function(steps)

	-- steps:GetFilename() returns the filename of the sm or ssc file, including path, as it is stored in SM's cache
	local filename = steps:GetFilename()
	if not filename then return end

	-- get the file extension like "sm" or "SM" or "ssc" or "SSC" or "sSc" or etc.
	-- convert to lowercase
	local filetype = filename:match("[^.]+$"):lower()
	-- if file doesn't match "ssc" or "sm", it was (hopefully) something else (.dwi, .bms, etc.)
	-- that isn't supported by SL-ChartParser
	if not (filetype=="ssc" or filetype=="sm") then return end

	-- create a generic RageFile that we'll use to read the contents
	-- of the desired .ssc or .sm file
	local f = RageFileUtil.CreateRageFile()
	local contents

	-- the second argument here (the 1) signals
	-- that we are opening the file in read-only mode
	if f:Open(filename, 1) then
		contents = f:Read()
	end

	-- destroy the generic RageFile now that we have the contents
	f:destroy()
	return contents, filetype
end

-- ----------------------------------------------------------------
-- SOURCE: https://github.com/JonathanKnepp/SM5StreamParser


-- Utility function to replace regex special characters with escaped characters
local regexEncode = function(var)
	return (var:gsub('%%', '%%%'):gsub('%^', '%%^'):gsub('%$', '%%$'):gsub('%(', '%%('):gsub('%)', '%%)'):gsub('%.', '%%.'):gsub('%[', '%%['):gsub('%]', '%%]'):gsub('%*', '%%*'):gsub('%+', '%%+'):gsub('%-', '%%-'):gsub('%?', '%%?'))
end

-- GetSimfileChartString() accepts four arguments:
--    SimfileString - the contents of the ssc or sm file as a string
--    StepsType     - a string like "dance-single" or "pump-double"
--    Difficulty    - a string like "Beginner" or "Challenge" or "Edit"
--    Filetype      - either "sm" or "ssc"
--
-- GetSimfileChartString() returns one value:
--    NoteDataString, a substring from SimfileString that contains the just the requested note data

local GetSimfileChartString = function(SimfileString, StepsType, Difficulty, StepsDescription, Filetype)
	local NoteDataString = nil

	-- ----------------------------------------------------------------
	-- StepMania uses each steps' "Description" attribute to uniquely
	-- identify Edit charts. (This is important, because there can be more
	-- than one Edit chart.)
	--
	-- ssc files use a dedicated #DESCRIPTION for this purpose
	-- but sm files have the description as part of an inline comment like
	--
	-- //---------------dance-single - test----------------
	--
	-- that^ edit stepchart would have a description of "test"
	-- ----------------------------------------------------------------

	if Filetype == "ssc" then
		-- SSC File
		-- Loop through each chart in the SSC file
		for chart in SimfileString:gmatch("#NOTEDATA.-#NOTES:[^;]*") do
			-- Find the chart that matches our difficulty and game type
			if(chart:match("#STEPSTYPE:"..regexEncode(StepsType)) and chart:match("#DIFFICULTY:"..regexEncode(Difficulty))) then
				-- ensure that we've located the correct edit stepchart within the ssc file
				-- there can be multiple Edit stepcharts but each is guaranteed to have a unique #DESCIPTION tag
				if (Difficulty ~= "Edit") or (Difficulty=="Edit" and chart:match("#DESCRIPTION:"..regexEncode(StepsDescription))) then
					-- Find just the notes
					NoteDataString = chart:match("#NOTES:[\r\n]+([^;]*)\n?$")
					-- remove possible comments
					NoteDataString = NoteDataString:gsub("\\[^\r\n]*", "")
					NoteDataString = NoteDataString:gsub("//[^\r\n]*", "")
					-- put the semicolon back so that the line-by-line loop knows when to stop
					NoteDataString = NoteDataString .. ";"
					break
				end
			end
		end
	elseif Filetype == "sm" then
		-- SM FILE
		-- Loop through each chart in the SM file
		for chart in SimfileString:gmatch("#NOTES[^;]*") do
			-- split the entire chart string into pieces on ":"
			local pieces = {}
			for str in chart:gmatch("[^:]+") do
				pieces[#pieces+1] = str
			end

			-- the pieces table should contain 7 numerically indexed items
			-- 2, 4, and 7 are the indices we care about for finding the correct chart
			-- index 2 will contain the steps_type (like "dance-single")
			-- index 4 will contain the difficulty (like "challenge")

			-- use gsub to scrub out line breaks (and other irrelevant characters?)
			local st = pieces[2]:gsub("[^%w-]", "")
			local diff = pieces[4]:gsub("[^%w]", "")
			-- trim leading whitespace
			local description = pieces[3]:gsub("^%s*", "")

			-- if this particular chart's steps_type matches the desired StepsType
			-- and its difficulty string matches the desired Difficulty
			if (st == StepsType) and (diff == Difficulty) and (diff ~= "Edit" or description == StepsDescription) then
				-- then index 7 contains the notedata that we're looking for
				-- use gsub to remove comments, store the resulting string,
				-- and break out of the chart loop now
				NoteDataString = pieces[7]:gsub("//[^\r\n]*","") .. ";"
				break
			end
		end
	end

	return NoteDataString
end

-- Figure out which measures are considered a stream of notes
local GetMeasureInfo = function(Steps, measuresString)
	-- Stream Measures Variables
	-- Which measures are considered a stream?
	local notesPerMeasure = {}
	local measureCount = 1
	local notesInMeasure = 0

	-- NPS and Density Graph Variables
	local NPSperMeasure = {}
	local NPSForThisMeasure, peakNPS = 0, 0
	local timingData = Steps:GetTimingData()

	-- Loop through each line in our string of measures, trimming potential leading whitespace (thanks, TLOES/Mirage Garden)
	for line in measuresString:gmatch("[^%s*\r\n]+") do
		-- If we hit a comma or a semi-colon, then we've hit the end of our measure
		if(line:match("^[,;]%s*")) then
			-- Does the number of notes in this measure meet our threshold to be considered a stream?
			table.insert(notesPerMeasure, notesInMeasure)

			-- NPS Calculation
			durationOfMeasureInSeconds = timingData:GetElapsedTimeFromBeat((measureCount+1) * 4) - timingData:GetElapsedTimeFromBeat(measureCount*4)

			-- FIXME: We subtract the time at the current measure from the time at the next measure to determine
			-- the duration of this measure in seconds, and use that to calculate notes per second.
			--
			-- Measures *normally* occur over some positive quantity of seconds.  Measures that use warps,
			-- negative BPMs, and negative stops are normally reported by the SM5 engine as having a duration
			-- of 0 seconds, and when that happens, we safely assume that there were 0 notes in that measure.
			--
			-- This doesn't always hold true.  Measures 48 and 49 of "Mudkyp Korea/Can't Nobody" use a properly
			-- timed negative stop, but the engine reports them as having very small but positive durations
			-- which erroneously inflates the notes per second calculation.
			if durationOfMeasureInSeconds == 0 then
				NPSForThisMeasure = 0
			else
				NPSForThisMeasure = notesInMeasure/durationOfMeasureInSeconds
			end

			NPSperMeasure[measureCount] = NPSForThisMeasure

			-- determine whether this measure contained the PeakNPS
			if NPSForThisMeasure > peakNPS then
				peakNPS = NPSForThisMeasure
			end

			-- Reset iterative variables
			notesInMeasure = 0
			measureCount = measureCount + 1
		else
			-- Is this a note? (Tap, Hold Head, Roll Head)
			if(line:match("[124]")) then
				notesInMeasure = notesInMeasure + 1
			end
		end
	end

	return notesPerMeasure, peakNPS, NPSperMeasure
end

local MaybeCopyFromOppositePlayer = function(pn, filename, stepsType, difficulty, description)
	local opposite_player = pn == "P1" and "P2" or "P1"

	-- Check if we already have the data stored in the opposite player's cache.
	if (SL[opposite_player].Streams.Filename == filename and
			SL[opposite_player].Streams.StepsType == stepsType and
			SL[opposite_player].Streams.Difficulty == difficulty and
			SL[opposite_player].Streams.Description == description) then
		-- If so then just copy everything over.
		SL[pn].Streams.NotesPerMeasure = SL[opposite_player].Streams.NotesPerMeasure
		SL[pn].Streams.PeakNPS = SL[opposite_player].Streams.PeakNPS
		SL[pn].Streams.NPSperMeasure = SL[opposite_player].Streams.NPSperMeasure

		SL[pn].Streams.Filename = SL[opposite_player].Streams.Filename
		SL[pn].Streams.StepsType = SL[opposite_player].Streams.StepsType
		SL[pn].Streams.Difficulty = SL[opposite_player].Streams.Difficulty
		SL[pn].Streams.Description = SL[opposite_player].Streams.Description

		MESSAGEMAN:Broadcast(pn.."ChartParsed")
	end
end
		
ParseChartInfo = function(steps, pn)
	-- The filename for these steps in the StepMania cache 
	local filename = steps:GetFilename()
	-- StepsType, a string like "dance-single" or "pump-double"
	local stepsType = ToEnumShortString( steps:GetStepsType() ):gsub("_", "-"):lower()
	-- Difficulty, a string like "Beginner" or "Challenge"
	local difficulty = ToEnumShortString( steps:GetDifficulty() )
	-- An arbitary but unique string provided by the stepartist, needed here to identify Edit charts
	local description = steps:GetDescription()

	MaybeCopyFromOppositePlayer(pn, filename, stepsType, difficulty, description)

	-- Only parse the file if it's not what's already stored in SL Cache.
	if (SL[pn].Streams.Filename ~= filename or
			SL[pn].Streams.StepsType ~= stepsType or
			SL[pn].Streams.Difficulty ~= difficulty or
			SL[pn].Streams.Description ~= description) then
		local simfileString, fileType = GetSimfileString( steps )
		if simfileString then
			-- Parse out just the contents of the notes
			local chartString = GetSimfileChartString(simfileString, stepsType, difficulty, description, fileType)
			if chartString then
				-- Which measures have enough notes to be considered as part of a stream?
				-- We cam also extract the PeakNPS and the NPSperMeasure table info in the same pass.
				local NotesPerMeasure, PeakNPS, NPSperMeasure = GetMeasureInfo(steps, chartString)

				-- Which sequences of measures are considered a stream?
				SL[pn].Streams.NotesPerMeasure = NotesPerMeasure
				SL[pn].Streams.PeakNPS = PeakNPS
				SL[pn].Streams.NPSperMeasure = NPSperMeasure

				SL[pn].Streams.Filename = filename
				SL[pn].Streams.StepsType = stepsType
				SL[pn].Streams.Difficulty = difficulty
				SL[pn].Streams.Description = description

				MESSAGEMAN:Broadcast(pn.."ChartParsed")
			end
		end
	end
end
