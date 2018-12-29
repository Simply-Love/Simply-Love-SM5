local GetCourseOrTrailBPMs = function(entries)
	local lowest, highest

	for i, entry in ipairs(entries) do
		-- courseEntry:GetSong() will return nil randomly generated courses :(
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

function GetCourseModeBPMs(course)
	local course = course or GAMESTATE:GetCurrentCourse( GAMESTATE:GetMasterPlayerNumber() )
	if not course then return false end

	local courseEntries = course:GetCourseEntries()
	return GetCourseOrTrailBPMs( courseEntries )
end

function GetTrailBPMs(player)
	if not player then return false end
	local trail = GAMESTATE:GetCurrentTrail(player)
	if not trail then return false end

	local trailEntries = trail:GetTrailEntries()
	return GetCourseOrTrailBPMs( trailEntries )
end


function GetDisplayBPMs()
	local text = ""
	local MusicRate = SL.Global.ActiveModifiers.MusicRate

	-- if in "normal" mode
	if not GAMESTATE:IsCourseMode() then
		local song = GAMESTATE:GetCurrentSong()

		if song then
			local bpm = song:GetDisplayBpms()

			-- handle DisplayBPMs that are <= 0
			if bpm[1] <= 0 or bpm[2] <= 0 then
				bpm = song:GetTimingData():GetActualBPM()
			end

			--if a single bpm suffices
			if bpm[1] == bpm[2] then
				if MusicRate == 1 then
					text = round(bpm[1])
				else
					text = round(bpm[1] * MusicRate, 1)
				end

			-- if we have a range of bpms
			else
				if MusicRate == 1 then
					text = round(bpm[1]) .. " - " .. round(bpm[2])
				else
					text = round(bpm[1] * MusicRate, 1) .. " - " .. round(bpm[2] * MusicRate, 1)
				end
			end
		end

	-- if we are in CourseMode
	else
		local range = GetCourseModeBPMs() or GetTrailBPMs(GAMESTATE:GetMasterPlayerNumber())
		if range then
			local lowest = range[1]
			local highest = range[2]

			if lowest and highest then
				if lowest == highest then
					text = round(lowest * MusicRate)
				else
					text = round(lowest * MusicRate) .. " - " .. round(highest * MusicRate)
				end
			end
		end
	end

	return text
end