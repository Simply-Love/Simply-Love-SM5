function GetCourseModeBPMs()
	local Players, player, trail, trailEntries, lowest, highest, text, range

	Players = GAMESTATE:GetHumanPlayers()
	player = Players[1]

	if player then
		trail = GAMESTATE:GetCurrentTrail(player)

		if trail then
			trailEntries = trail:GetTrailEntries()

			for k,trailEntry in ipairs(trailEntries) do
				local song = trailEntry:GetSong()
				local bpms = song:GetDisplayBpms()

				-- if either display BPM is negative or 0, use the actual BPMs instead...
				if bpms[1] <= 0 or bpms[2] <= 0 then
					bpms = song:GetTimingData():GetActualBPM()
				end

				-- on the first iteration, lowest and highest will both be nil
				-- so set lowest to this song's lower bpm
				-- and highest to this song's higher bpm
				if not lowest then
					lowest = bpms[1]
				end
				if not highest then
					highest = bpms[2]
				end

				-- on each subsequent iteration, compare
				if lowest > bpms[1] then
					lowest = bpms[1]
				end
				if highest < bpms[2] then
					highest = bpms[2]
				end
			end
			if lowest and highest then
				range = {lowest, highest}
				return range
			end
		end
	end
end


function GetDisplayBPMs()
	local text = ""

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
				text = round(bpm[1])

			-- if we have a range of bpms
			else
				text = round(bpm[1]) .. " - " .. round(bpm[2])
			end
		end

	-- if we ARE in CourseMode
	else
		local range = GetCourseModeBPMs()
		if range then
			local lowest = range[1]
			local highest = range[2]


			if lowest and highest then
				if lowest == highest then
					text = round(lowest)
				else
					text = round(lowest) .. " - " .. round(highest)
				end
			end
		end
	end

	return text
end