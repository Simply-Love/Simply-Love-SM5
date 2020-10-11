local GetTrailBPMs = function(player, trail)
	if not player then return false end
	trail = trail or GAMESTATE:GetCurrentTrail(player)
	if not trail then return false end

	local lowest, highest

	for i, entry in ipairs(trail:GetTrailEntries()) do
		-- TrailEntry:GetSteps() will return nil for (auto)generated courses :(
		local steps = entry:GetSteps()
		if steps==nil then return end

		local bpms = steps:GetDisplayBpms()

		-- if either display BPM is negative or 0, use the actual BPMs instead...
		if bpms[1] <= 0 or bpms[2] <= 0 then
			bpms = steps:GetTimingData():GetActualBPM()
		end

		-- on the first iteration, lowest and highest will both be nil
		-- so set lowest to this song's lower bpm
		-- and highest to this song's higher bpm
		if not lowest  then lowest  = bpms[1] end
		if not highest then highest = bpms[2] end

		-- on each subsequent iteration, compare
		lowest = math.min(lowest,  bpms[1])
		highest= math.max(highest, bpms[2])
	end

	if lowest and highest then
		-- return a table containing the range of bpms
		return {lowest, highest}
	end
end


-- GetDisplayBPMs() will attempt to return a table of numeric {lower, upper} DISPLAYBPM values
-- it handles CourseMode and normal gameplay and factors in the current MusicRate
--
-- if StepsOrTrail is provided, that will be used (useful for EvalSummary)
-- if a player is provided without a StepsOrTrail, it will use the CurrentSteps() of that player (useful for SelectMusic, Eval, etc.)
-- if a player is not provided, it will use the CurrentSteps() of the MasterPlayer
--
-- the SM engine does not allow bpm values <= 0, but it does allow stepartists to
-- manually specify DISPLAYBPM values <= 0; if such a DISPLAYBPM value is found,
-- this function will use actual bpm values instead to preserve sanity

GetDisplayBPMs = function(player, StepsOrTrail, MusicRate)
	player       = player       or GAMESTATE:GetMasterPlayerNumber()
	StepsOrTrail = StepsOrTrail or (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	MusicRate    = MusicRate    or SL.Global.ActiveModifiers.MusicRate

	-- steps are not always set in the Engine in Casual mode (prior to the first stage being played) so
	-- GAMESTATE:GetCurrentSteps() will sometimes return nil; but, it's okay. We don't need such rigorous BPM
	-- analysis there anyway.  Don't worry about split timing and just use BPM values for the first playable chart.
	if SL.Global.GameMode == "Casual" then
		-- there is no CourseMode in Casual, so no need to worry about trails here
		local steps = SongUtil.GetPlayableSteps( GAMESTATE:GetCurrentSong() )
		if steps and steps[1] then StepsOrTrail = steps[1] end
	end

	if not StepsOrTrail then return end

	local bpms

	-- if in CourseMode
	if GAMESTATE:IsCourseMode() then
		bpms = GetTrailBPMs(player, StepsOrTrail)

	-- otherwise, we are not in CourseMode, i.e. in "normal" mode
	else
		bpms = StepsOrTrail:GetDisplayBpms()
	end

	-- ensure there are 2 values before attempting to index them
	if not (bpms and bpms[1] and bpms[2]) then return end

	-- if the stepartist has specified a DISPLAYBPM <= 0, that's cute but
	-- 1. the engine doens't actually permit that and will ignore it
	-- 2. trying to accommodate it themeside is complicated and error-prone
	-- so get the honest BPM data from the step's TimingData
	if bpms[1] <= 0 or bpms[2] <= 0 then
		bpms = StepsOrTrail:GetTimingData():GetActualBPM()
		-- again, ensure there are 2 values
		if not bpms[1] or not bpms[2] then return end
	end

	return {
		bpms[1] * MusicRate,
		bpms[2] * MusicRate
	}
end

-- StringifyDisplayBPMs() uses the values provided by GetDisplayBPMs() and returns
-- a formatted string that can be displayed on-screen and shown to players.
-- This is used in SelectMusic, Eval, EvalSummary, PlayerOptions, etc.
-- really anywhere the player should see a BPM or BPM range.
--
-- All three arguments are optional.  Provide them if you need a printable
-- BPM for a specific song/stepchart (like on EvalSummary).
--
-- If arguments are not provided, the current song/stepchart will be used
-- (like on SelectMusic and PlayerOptions).

StringifyDisplayBPMs = function(player, StepsOrTrail, MusicRate)
	player       = player       or GAMESTATE:GetMasterPlayerNumber()
	StepsOrTrail = StepsOrTrail or (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	MusicRate    = MusicRate    or SL.Global.ActiveModifiers.MusicRate

	local bpms = GetDisplayBPMs(player, StepsOrTrail, MusicRate)

	if not (bpms and bpms[1] and bpms[2]) then return "" end

	-- format DisplayBPMs to not show decimals unless a musicrate
	-- modifier is in effect, in which case show 1 decimal of precision
	local fmt = MusicRate==1 and "%.0f" or "%.1f"
	local s

	-- lower and upper bpms match
	if bpms[1] == bpms[2] then
		s = fmt:format(bpms[1])
		-- musicrate will show one decimal place of precision
		-- remove it if came out to be something.0
		-- to reduce visual noise and save a few pixels of UI space
		if MusicRate ~= 1 then
			s = s:gsub("%.0", "")
		end

	-- lower and upper bpms were different
	-- so format the string to display a range
	else
		if MusicRate == 1 then
			s = ("%s - %s"):format(fmt:format(bpms[1]), fmt:format(bpms[2]))
		else
			s = ("%s - %s"):format(fmt:format(bpms[1]):gsub("%.0", ""), fmt:format(bpms[2]):gsub("%.0", ""))
		end
	end

	return s
end
