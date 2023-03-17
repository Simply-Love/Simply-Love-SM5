-- -----------------------------------------------------------------------
IsItlSong = function(player)
	local song = GAMESTATE:GetCurrentSong()
	local song_dir = song:GetSongDir()
	local group = string.lower(song:GetGroupName())
	local pn = ToEnumShortString(player)
	return string.find(group, "itl online 2023") or string.find(group, "itl 2023") or SL[pn].ITLData["pathMap"][song_dir] ~= nil
end


IsItlActive = function()
	-- The file is only written to while the event is active.
	-- These are just placeholder dates.
	local startTimestamp = 20230317
	local endTimestamp = 20230619

	local year = Year()
	local month = MonthOfYear()+1
	local day = DayOfMonth()
	local today = year * 10000 + month * 100 + day

	return startTimestamp <= today and today <= endTimestamp
end


-- -----------------------------------------------------------------------
-- The ITL file is a JSON file that contains two mappings:
--
-- {
--    pathMap = {
--      '<song_dir>': '<song_hash>',
--    },
--    hashMap = {
--      '<song_hash': { ..itl metadata .. }
--    }
-- }
--
-- The pathMap maps a song directory corresponding to an ITL chart to its song hash
-- The hashMap is a mapping from that hash to the relevant data stored for the event.
--
-- This set up lets us display song wheel grades for ITL both from playing within the
-- ITL pack and also outside of it.
-- Note that songs resynced for ITL but played outside of the pack will not be covered in the pathMap.
local itlFilePath = "itl2023.json"


-- Takes the ITLData loaded in memory and writes it to the local profile.
WriteItlFile = function(player)
	local profile_slot = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}
	
	local dir = PROFILEMAN:GetProfileDir(profile_slot[player])
	local pn = ToEnumShortString(player)
	-- We require an explicit profile to be loaded.
	if not dir or #dir == 0 then return end

	local path = dir .. itlFilePath
	local f = RageFileUtil:CreateRageFile()

	if f:Open(path, 2) then
		f:Write(JsonEncode(SL[pn].ITLData))
		f:Close()
	end
	f:destroy()
end

-- Generally to be called only once when a profile is loaded.
-- This parses the ITL data file and stores it in memory for the song wheel to reference.
ReadItlFile = function(player)
	local profile_slot = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}
	
	local dir = PROFILEMAN:GetProfileDir(profile_slot[player])
	local pn = ToEnumShortString(player)
	-- We require an explicit profile to be loaded.
	if not dir or #dir == 0 then return end

	local path = dir .. itlFilePath
	local itlData = { 
		["pathMap"] = {},
		["hashMap"] = {},
	}
	if FILEMAN:DoesFileExist(path) then
		local f = RageFileUtil:CreateRageFile()
		local existing = ""
		if f:Open(path, 1) then
			existing = f:Read()
			f:Close()
		end
		f:destroy()
		itlData = JsonDecode(existing)
	end
	SL[pn].ITLData = itlData
end

-- Helper function used within UpdateItlData() below.
-- Curates all the ITL data to be written to the ITL file for the played song.
local DataForSong = function(player)
	local GetClearType = function(judgments)
		-- 1 = Pass
		-- 2 = FGC
		-- 3 = FEC
		-- 4 = Quad
		-- 5 = Quint
		local clearType = 1

		-- Dropping a hold or roll will always be a Pass
		local droppedHolds = judgments["totalRolls"] - judgments["Rolls"]
		local droppedRolls = (judgments["totalHolds"] - judgments["Holds"])
		if droppedHolds > 0 or droppedRolls > 0 then
			return 1
		end

		local totalTaps = judgments["Miss"]

		if judgments["W5"] ~= nil then
			totalTaps = totalTaps + judgments["W5"]
		end

		if judgments["W4"] ~= nil then
			totalTaps = totalTaps + judgments["W4"]
		end

		if totalTaps == 0 then clearType = 2 end

		totalTaps = totalTaps + judgments["W3"]
		if totalTaps == 0 then clearType = 3 end

		totalTaps = totalTaps + judgments["W2"]
		if totalTaps == 0 then clearType = 4 end

		totalTaps = totalTaps + judgments["W1"]
		if totalTaps == 0 then clearType = 5 end

		return clearType
	end

	-- EX score is a number like 92.67
	local GetPointsForSong = function(maxPoints, exScore)
		local thresholdEx = 50.0
		local percentPoints = 40.0

		-- Helper function to take the logarithm with a specific base.
		local logn = function(x, y)
			return math.log(x) / math.log(y)
		end

		-- The first half (logarithmic portion) of the scoring curve.
		local first = logn(
			math.min(exScore, thresholdEx) + 1,
			math.pow(thresholdEx + 1, 1 / percentPoints)
		)

		-- The seconf half (exponential portion) of the scoring curve.
		local second = math.pow(
			100 - percentPoints + 1,
			math.max(0, exScore - thresholdEx) / (100 - thresholdEx)
		) - 1

		-- Helper function to round to a specific number of decimal places.
		-- We want 100% EX to actually grant 100% of the points.
		-- We don't want to  lose out on any single points if possible. E.g. If
		-- 100% EX returns a number like 0.9999999999999997 and the chart points is
		-- 6500, then 6500 * 0.9999999999999997 = 6499.99999999999805, where
		-- flooring would give us 6499 which is wrong.
		local roundPlaces = function(x, places)
			local factor = 10 ^ places
			return math.floor(x * factor + 0.5) / factor
		end

		local percent = roundPlaces((first + second) / 100.0, 6)
		return math.floor(maxPoints * percent)
	end

	local pn = ToEnumShortString(player)

	local steps = GAMESTATE:GetCurrentSteps(player)
	local chartName = steps:GetChartName()

	local maxPoints = chartName:gsub(" pts", "")
	if #maxPoints == 0 then
		maxPoints = 0
	else
		maxPoints = tonumber(maxPoints)
	end

	local year = Year()
	local month = MonthOfYear()+1
	local day = DayOfMonth()

	local judgments = GetExJudgmentCounts(player)
	local ex = CalculateExScore(player, judgments)
	local clearType = GetClearType(judgments)
	local points = GetPointsForSong(maxPoints, ex)
	local hash = SL[pn].Streams.Hash
	local usedCmod = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):CMod() ~= nil
	local date = ("%04d-%02d-%02d"):format(year, month, day)
	
	return {
		["judgments"] = judgments,
		["ex"] = ex * 100,
		["clearType"] = clearType,
		["points"] = points,
		["hash"] = hash,
		["usedCmod"] = usedCmod,
		["date"] = date,
	}
end


-- Should be called during ScreenEvaluation to update the ITL data loaded.
-- Will also write the contents to the file.
UpdateItlData = function(player)
	local pn = ToEnumShortString(player)
	local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
		
	-- Do the same validation as GrooveStats.
	-- This checks important things like timing windows, addition/removal of arrows, etc.
	local _, valid = ValidForGrooveStats(player)

	-- ITL additionally requires the music rate to be 1.00x.
	local so = GAMESTATE:GetSongOptionsObject("ModsLevel_Song")
	local rate = so:MusicRate()

	-- We also require mines to be on.
	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")
	local minesEnabled = not po:NoMines()

	if (GAMESTATE:IsHumanPlayer(player) and
				valid and
				rate == 1.0 and
				minesEnabled and
				not stats:GetFailed()) then
		local data = DataForSong(player)
		local hash = data["hash"]

		-- Update the pathMap as needed.
		local song = GAMESTATE:GetCurrentSong()
		local song_dir = song:GetSongDir()
		if song_dir ~= nil and #song_dir ~= 0 then
			local pathMap = SL[pn].ITLData["pathMap"]
			pathMap[song_dir] = hash
		end
		
		-- Then maybe update the hashMap.
		local hashMap = SL[pn].ITLData["hashMap"]
		local updated = false
	
		if hashMap[hash] == nil then
			-- New score, just copy things over.
			hashMap[hash] = {
				["judgments"] = DeepCopy(data["judgments"]),
				["ex"] = data["ex"],
				["clearType"] = data["clearType"],
				["points"] = data["points"],
				["usedCmod"] = data["usedCmod"],
				["date"] = data["date"],
			}
			updated = true
		else
			-- TODO: Check if CMod is allowed for this song?

			if data["ex"] >= hashMap[hash]["ex"] then
				hashMap[hash]["ex"] = data["ex"]
				hashMap[hash]["points"] = data["points"]
				
				if data["ex"] > hashMap[hash]["ex"] then
					-- EX count is strictly better, copy the judgments over.
					hashMap[hash]["judgments"] = DeepCopy(data["judgments"])
					updated = true
				else
					-- EX count is tied.
					-- "Smart" update judgment counts by picking the one with the highest top judgment.
					local better = false
					local keys = { "W0", "W1", "W2", "W3", "W4", "W5", "Miss" }
					for key in ivalues(keys) do
						local prev = hashMap[hash]["judgments"][key]
						local cur = data["judgments"][key]
						if (cur ~= nil and prev ~= nil and cur > prev) or (cur ~= nil and prev == nil) then
							better = true
							break
						end
					end

					if better then
						hashMap[hash]["judgments"] = DeepCopy(data["judgments"])
					end
					updated = true
				end
			end	

			if data["clearType"] > hashMap[hash]["clearType"] then
				hashMap[hash]["clearType"] = data["clearType"]
				updated = true
			end

			if updated then
				hashMap[hash]["usedCmod"] = data["usedCmod"]
				hashMap[hash]["date"] = data["date"]
			end
		end

		if updated then
			WriteItlFile(player)
		end
	end
end