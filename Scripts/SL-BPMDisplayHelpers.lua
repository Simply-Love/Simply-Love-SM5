local GetCourseOrTrailBPMs = function(entries)
	local lowest, highest

	for i, entry in ipairs(entries) do
		-- courseEntry:GetSong() will return nil for randomly generated courses :(
		local song = entry:GetSong()
		if song==nil then return end

		local bpms = song:GetDisplayBpms()

		-- if either display BPM is negative or 0, use the actual BPMs instead...
		if bpms[1] <= 0 or bpms[2] <= 0 then
			bpms = song:GetTimingData():GetActualBPM()
		end

		-- on the first iteration, lowest and highest will both be nil
		-- so set lowest to this song's lower bpm
		-- and highest to this song's higher bpm
		if not lowest then lowest = bpms[1] end
		if not highest then highest = bpms[2] end

		-- on each subsequent iteration, compare
		lowest = math.min(lowest, bpms[1])
		highest= math.max(highest, bpms[2])
	end

	if lowest and highest then
		-- return a table containing the range of bpms
		return {lowest, highest}
	end
end

GetCourseModeBPMs = function(course)
	course = course or GAMESTATE:GetCurrentCourse( GAMESTATE:GetMasterPlayerNumber() )
	if not course then return false end

	local courseEntries = course:GetCourseEntries()
	return GetCourseOrTrailBPMs( courseEntries )
end

GetTrailBPMs = function(player)
	if not player then return false end
	local trail = GAMESTATE:GetCurrentTrail(player)
	if not trail then return false end

	local trailEntries = trail:GetTrailEntries()
	return GetCourseOrTrailBPMs( trailEntries )
end


-- GetDisplayBPMs() will attempt to return a table of {lower, upper} DISPLAYBPM values
-- it handles CourseMode and normal gameplay and factors in the current MusicRate
--
-- if a player is provided, it will prefer steps timing in case the ssc file has "split BPMs"
-- if a player is not provided, song timing will be used
--
-- the SM engine does not allow bpm values <= 0, but it does allow stepartists to
-- manually specify DISPLAYBPM values <= 0; if such a DISPLAYBPM value is found,
-- this function will use actual bpm values instead to preserve sanity

GetDisplayBPMs = function(player)
	player = player or GAMESTATE:GetMasterPlayerNumber()

	local MusicRate = SL.Global.ActiveModifiers.MusicRate
	local bpms

	-- if in CourseMode
	if GAMESTATE:IsCourseMode() then
		bpms = GetCourseModeBPMs() or GetTrailBPMs(GAMESTATE:GetMasterPlayerNumber())
		if not bpms then return end

	-- otherwise, we are not in CourseMode, i.e. in "normal" mode
	else
		-- prefer the simfile's provided DISPLAYBPM values for this stepchart (possible with .ssc files)
		-- if steps aren't available, try getting DISPLAYBPM values at the song level (normal for .sm files)
		local StepsOrSong = player and GAMESTATE:GetCurrentSteps(player) or GAMESTATE:GetCurrentSong()
		if not StepsOrSong then return end

		bpms = StepsOrSong:GetDisplayBpms()
	end

	-- ensure there are 2 values before attempting to index them
	if not bpms[1] or not bpms[2] then return end

	-- if the stepartist has specified a DISPLAYBPM <= 0, that's cute but
	-- 1. the engine doens't actually permit that and will ignore it
	-- 2. trying to accommodate it themeside is complicated and error-prone
	-- so get the honest BPM data from the step's TimingData
	if bpms[1] <= 0 or bpms[2] <= 0 then
		bpms = song:GetTimingData():GetActualBPM()
		-- again, ensure there are 2 values
		if not bpms[1] or not bpms[2] then return end
	end

	return {
		math.round( bpms[1] * MusicRate, 1 ),
		math.round( bpms[2] * MusicRate, 1 )
	}
end

StringifyDisplayBPMs = function(player)
	player = player or GAMESTATE:GetMasterPlayerNumber()
	local MusicRate = SL.Global.ActiveModifiers.MusicRate

	local bpms = GetDisplayBPMs(player)
	if not (bpms and bpms[1] and bpms[2]) then return end

	-- format DisplayBPMs to not show decimals unless a musicrate
	-- modifier is in effect, in which case show 1 decimal of precision
	local fmt = MusicRate==1 and "%.0f" or "%.1f"

	if bpms[1] == bpms[2] then
		return fmt:format(bpms[1])
	end

	return ( ("%s - %s"):format(fmt, fmt) ):format(bpms[1], bpms[2])
end