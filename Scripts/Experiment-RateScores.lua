-- Read rate scores from disk if they exist
LoadRateScores = function(pn)
	local profileDir
	if pn == 'P1' then profileDir = 'ProfileSlot_Player1' else profileDir = 'ProfileSlot_Player2' end
	local contents
	local RateScores = {}
	if FILEMAN:DoesFileExist(PROFILEMAN:GetProfileDir(profileDir).."/RateScores.txt") then
		contents = GetFileContents(PROFILEMAN:GetProfileDir(profileDir).."/RateScores.txt")
		for line in ivalues(contents) do
			local score = Split(line,"\t")
			if #score == 22 then
				table.insert(RateScores,{
					name = score[1],
					group = score[2],
					difficulty = score[3],
					rate = score[4],
					score = score[5],
					W1 = score[6],
					W2 = score[7],
					W3 = score[8],
					W4 = score[9],
					W5 = score[10],
					Miss = score[11],
					Holds = score[12],
					Mines = score[13],
					Hands = score[14],
					Rolls = score[15],
					failed = score[16],
					grade = score[17],
					hour = score[18],
					minute = score[19],
					month = score[20],
					day = score[21],
					year = score[22]})
			end
		end
	end
	if SL[pn] then SL[pn]['RateScores'] = RateScores end
end

-- Write rate scores to disk
SaveRateScores = function(pn)
	if SL[pn]['RateScores'] then
		toWrite = ""
		for score in ivalues(SL[pn]['RateScores']) do --TODO don't type this out manually
			toWrite = toWrite..score.name.."\t"..score.group.."\t"..score.difficulty.."\t"..score.rate.."\t"..score.score.."\t"
			..score.W1.."\t"..score.W2.."\t"..score.W3.."\t"..score.W4.."\t"..score.W5.."\t"..score.Miss.."\t"
			..score.Holds.."\t"..score.Mines.."\t"..score.Hands.."\t"..score.Rolls.."\t"
			..tostring(score.failed).."\t"..score.grade.."\t"..score.hour.."\t"..score.minute
			.."\t"..score.month.."\t"..score.day.."\t"..score.year.."\r\n"
		end
		local profileDir
		if pn == 'P1' then profileDir = 'ProfileSlot_Player1' else profileDir = 'ProfileSlot_Player2' end
		WriteFileContents(PROFILEMAN:GetProfileDir(profileDir).."/RateScores.txt",toWrite,true)
	end
end

-- Add a new rate score to SL[pn][RateScores]
AddRateScore = function(player)
	if SL.Global.ActiveModifiers.MusicRate == 1 then return end --don't need to do anything if the rate is 1
	local pn = ToEnumShortString(player)
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
	local TapNoteScores = {
		Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	}
	local RadarCategories = {
		Types = { 'Holds', 'Mines', 'Hands', 'Rolls' },
	}
	local stats = {}
	stats.name = GAMESTATE:GetCurrentSong():GetMainTitle()
	stats.group = GAMESTATE:GetCurrentSong():GetGroupName()
	stats.difficulty = GAMESTATE:GetCurrentSteps(pn):GetDifficulty()
	stats.rate = SL.Global.ActiveModifiers.MusicRate
	stats.score = pss:GetPercentDancePoints()
	stats.failed = pss:GetFailed()
	stats.grade = pss:GetGrade()
	stats.hour = Hour()
	stats.minute = Minute()
	stats.month = MonthOfYear()
	stats.day = DayOfMonth()
	stats.year = Year()
	for i=1,#TapNoteScores.Types do
		local window = TapNoteScores.Types[i]
		local number = pss:GetTapNoteScores( "TapNoteScore_"..window )
		stats[window] = number
	end
	for index, RCType in ipairs(RadarCategories.Types) do
		local performance = pss:GetRadarActual():GetValue( "RadarCategory_"..RCType )
		stats[RCType] = performance
	end
	table.insert(SL[pn]['RateScores'],stats)
end

GetRateScores = function(player, song, steps)
	local pn = ToEnumShortString(player)
	local name = song:GetMainTitle()
	local group = song:GetGroupName()
	local difficulty = steps:GetDifficulty()
	local rate = SL.Global.ActiveModifiers.MusicRate
	local RateScores = {}
	for score in ivalues(SL[pn]['RateScores']) do
		if score.name == name and score.group == group and score.difficulty == difficulty
		and tonumber(score.rate) == rate then
			RateScores[#RateScores+1] = score
		end
	end
	if #RateScores > 0 then
		table.sort(RateScores,function(k1,k2) return k1.score > k2.score end)
		return RateScores
	else return nil end
end
	