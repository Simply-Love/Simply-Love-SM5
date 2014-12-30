function SpeedModsType()
	local modList = { "x", "C", "M" }
	local t = {
		Name = "SpeedType",
		LayoutType = "ShowOneInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = true,
		Choices = modList,
		LoadSelections = function(self, list, pn)
			local userSpeedType = SL[ToEnumShortString(pn)].ActiveModifiers.SpeedModType
			local i = FindInTable(userSpeedType, modList) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			local sSave

			for i=1, #list do
				if list[i] then
					sSave=modList[i]
				end
			end

			MESSAGEMAN:Broadcast('SpeedModType'..ToEnumShortString(pn)..'Set',{SpeedModType=sSave})
		end
	}
	return t
end


function SpeedModsNew()

	local blank = {"       "}

	local t = {
		Name = "SpeedModNew",
		LayoutType = "ShowOneInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		Choices = blank,
		LoadSelections = function(self, list, pn)
			list[1] = true
		end,
		SaveSelections = function(self, list, pn)
			ApplySpeedMod(pn)
		end
	}
	return t
end





function ChangeSpeedMod(pn, direction)

	-- if using an XMod
	if SL[pn].ActiveModifiers.SpeedModType == "x" then

		if SL[pn].ActiveModifiers.SpeedMod + (0.05 * direction) >= 20 then
			SL[pn].ActiveModifiers.SpeedMod = 0.05
		elseif SL[pn].ActiveModifiers.SpeedMod + (0.05 * direction) <= 0 then
			SL[pn].ActiveModifiers.SpeedMod = 20.00
		else
			SL[pn].ActiveModifiers.SpeedMod = SL[pn].ActiveModifiers.SpeedMod + (0.05 * direction)
		end

	-- elseif using a CMod or an MMod
	elseif SL[pn].ActiveModifiers.SpeedModType == "C" or SL[pn].ActiveModifiers.SpeedModType == "M" then

		if SL[pn].ActiveModifiers.SpeedMod + (10 * direction) >= 2000 then
			SL[pn].ActiveModifiers.SpeedMod = 10
		elseif SL[pn].ActiveModifiers.SpeedMod + (10 * direction) <= 0 then
			SL[pn].ActiveModifiers.SpeedMod = 2000
		else
			SL[pn].ActiveModifiers.SpeedMod = SL[pn].ActiveModifiers.SpeedMod + (10 * direction)
		end
	end
end




function ApplySpeedMod(player)
	local type 	= SL[ToEnumShortString(player)].ActiveModifiers.SpeedModType or "x"
	local speed = SL[ToEnumShortString(player)].ActiveModifiers.SpeedMod or 1.00
	local topscreen = SCREENMAN:GetTopScreen():GetName()
	local modslevel = topscreen  == "ScreenEditOptions" and "ModsLevel_Stage" or "ModsLevel_Preferred"

	local playeroptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions(modslevel)

	-- it's necessary to manually apply a speedmod of 1x first, otherwise speedmods stack?
	playeroptions:XMod(1.00)

	if type == "x" then
		playeroptions:XMod(speed)
	elseif type == "C" then
		playeroptions:CMod(speed)
	elseif type == "M" then
		playeroptions:MMod(speed)
	end
end


function DisplaySpeedMod(pn)
	local bpm
	local display = ""
	local speed = SL[pn].ActiveModifiers.SpeedMod

	if GAMESTATE:IsCourseMode() then
		bpm = GetCourseModeBPMs()
	else
		bpm = GAMESTATE:GetCurrentSong():GetDisplayBpms()
		-- handle DisplayBPMs that are <= 0
		if bpm[1] <= 0 or bpm[2] <= 0 then
			bpm = GAMESTATE:GetCurrentSong():GetTimingData():GetActualBPM()
		end
	end

	-- if using an XMod
	if SL[pn].ActiveModifiers.SpeedModType == "x" then
		local musicrate = SL.Global.ActiveModifiers.MusicRate

		--if a single bpm suffices
		if bpm[1] == bpm[2] then
			display = string.format("%.2f", speed) .. "x (" .. round(speed * bpm[1] * musicrate) .. ")"

		-- if we have a range of bpms
		else
			display = string.format("%.2f", speed) .. "x (" .. round(speed * bpm[1] * musicrate) .. " - " .. round(speed * bpm[2] * musicrate) .. ")"
		end

	-- elseif using a CMod or an MMod
	elseif SL[pn].ActiveModifiers.SpeedModType == "C" or SL[pn].ActiveModifiers.SpeedModType == "M" then
		display = SL[pn].ActiveModifiers.SpeedModType .. tostring(speed)
	end

	return display
end


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