local GetSongDirs = function()
	local songs = SONGMAN:GetAllSongs()
	local list = {}
	for item in ivalues(songs) do
		list[item:GetSongDir()]={title = item:GetMainTitle(), song = item}
	end
	return list
end

-- If this is the first time loading a profile in Experiment mode then we won't have a list of song scores.
-- Read in from Stats.xml to start us off. 
local LoadFromStats = function(pn)
	local profileDir
	if pn == 'P1' then profileDir = 'ProfileSlot_Player1' else profileDir = 'ProfileSlot_Player2' end
	local path = PROFILEMAN:GetProfileDir(profileDir)..'Stats.xml'
	local contents = ""
	local statsTable = {}
	local highScore = {}
	if FILEMAN:DoesFileExist(path) then
		contents = GetFileContents(path)
		local group, song, title, groupSong, Difficulty, StepsType, numTimesPlayed, lastPlayed, firstPass, tempFirstPass, hash
		local songDir = GetSongDirs()
		for line in ivalues(contents) do
			if string.find(line,"<Song Dir=") then
				groupSong = "/"..string.gsub(line,"<Song Dir='(Songs/[%w%p ]*/)'>","%1"):gsub("&apos;","'"):gsub("&amp;","&")
				group = Split(groupSong,"/")[2]
				if songDir[groupSong] then 
					song = songDir[groupSong].song
					title = songDir[groupSong].title
				else 
					title = Split(groupSong,"/")[3]
					song = nil
				end
			elseif string.find(line,"<Steps Difficulty='") then
				local iterator = string.gmatch(line,"[%w%p]*='([%w%p]*)'")
				Difficulty = iterator()
				StepsType = iterator()
				if song then
					hash = GenerateHash(StepsType,Difficulty,song)
					if not statsTable[hash] then statsTable[hash] = {} end
				end
				firstPass = "Never"
				tempFirstPass = DateToMinutes(GetCurrentDateTime())
			elseif string.find(line,"<NumTimesPlayed>") then
				numTimesPlayed = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line, "<LastPlayed>") then
				lastPlayed = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line,"<Grade>") then
				highScore.grade = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line,"<PercentDP>") then
				highScore.score = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line,"<Modifiers>") then
				highScore.rate = string.find(line, "xMusic") and string.gsub(line,".*(%d.%d+)xMusic.*","%1") or 1
			elseif string.find(line,"<DateTime>") then
				highScore.dateTime = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line,"<Miss>") then
				highScore.Miss = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line,"<W5>") then
				highScore.W5 = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line,"<W4>") then
				highScore.W4 = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line,"<W3>") then
				highScore.W3 = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line,"<W2>") then
				highScore.W2 = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line,"<W1>") then
				highScore.W1 = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line,"<Holds>") then
				highScore.Holds = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line,"<Mines>") then
				highScore.Mines = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line,"<Hands>") then
				highScore.Hands = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line,"<Rolls>") then
				highScore.Rolls = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")
			elseif string.find(line,"</HighScore>") and song then
				table.insert(statsTable[hash],highScore)
				if highScore.grade ~= "Failed" and DateToMinutes(highScore.dateTime) < tempFirstPass then
					tempFirstPass = DateToMinutes(highScore.dateTime)
					firstPass = highScore.dateTime
				end
				highScore = {}
			elseif string.find(line,"</HighScoreList>") and song then
				local temp
				if StepsType == 'dance-single' then temp = "Dance_Single"
				elseif StepsType == 'dance-double' then temp = "Dance_Double" end
				local profileScores = PROFILEMAN:GetProfile(pn):GetHighScoreList(song,song:GetOneSteps(temp,Difficulty)):GetHighScores() 
				if tonumber(numTimesPlayed) > #profileScores then firstPass = "Unknown" end --if we've played it more times then there are scores we can't tell when it was passed first
				local machineScores = PROFILEMAN:GetMachineProfile():GetHighScoreList(song,song:GetOneSteps(temp,Difficulty)):GetHighScores()
				if #machineScores == 0 then firstPass = "Never" end --if there are no machine scores then no one has passed
				statsTable[hash].group = group
				statsTable[hash].title = title
				statsTable[hash].Difficulty = Difficulty
				statsTable[hash].StepsType = StepsType
				statsTable[hash].LastPlayed = lastPlayed
				statsTable[hash].NumTimesPlayed = numTimesPlayed
				statsTable[hash].FirstPass = firstPass
				statsTable[hash].hash = hash
			end
		end
	end

	return statsTable
end

-- Read scores from disk if they exist. If they don't, then load our initial values with LoadFromStats
LoadScores = function(pn)
	local profileDir
	if pn == 'P1' then profileDir = 'ProfileSlot_Player1' else profileDir = 'ProfileSlot_Player2' end
	local contents
	local Scores = {}
	if FILEMAN:DoesFileExist(PROFILEMAN:GetProfileDir(profileDir).."/Scores.txt") then
		contents = GetFileContents(PROFILEMAN:GetProfileDir(profileDir).."/Scores.txt")
		for line in ivalues(contents) do
			local score = Split(line,"\t")
			if #score == 22 then
				local hash = score[22]
				if not Scores[hash] then Scores[hash] = {} end
				table.insert(Scores[hash],{
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
					grade = score[16],
					dateTime = score[17],
					})
				Scores[hash].title = score[1]
				Scores[hash].group = score[2]
				Scores[hash].Difficulty = score[3]
				Scores[hash].StepsType = score[18]
				Scores[hash].LastPlayed = score[19]
				Scores[hash].NumTimesPlayed = score[20]
				Scores[hash].FirstPass = score[21]
				Scores[hash].hash = hash
			end
		end
	--if there's no Scores.txt then import all the scores in Stats.xml to get started
	else Scores = LoadFromStats(pn) end
	if SL[pn] then SL[pn]['Scores'] = Scores end
end

-- Write rate scores to disk
SaveScores = function(pn)
	if SL[pn]['Scores'] then
		toWrite = ""
		for _,hash in pairs(SL[pn]['Scores']) do --TODO don't type this out manually
			for score in ivalues(hash) do
				toWrite = toWrite..hash.title.."\t"..hash.group.."\t"..hash.Difficulty.."\t"..score.rate.."\t"..score.score.."\t"
				..score.W1.."\t"..score.W2.."\t"..score.W3.."\t"..score.W4.."\t"..score.W5.."\t"..score.Miss.."\t"
				..score.Holds.."\t"..score.Mines.."\t"..score.Hands.."\t"..score.Rolls.."\t"
				..score.grade.."\t"..score.dateTime.."\t"..hash.StepsType.."\t"..hash.LastPlayed.."\t"..hash.NumTimesPlayed.."\t"
				..hash.FirstPass.."\t"..hash.hash.."\r\n"
			end
		end
		local profileDir
		if pn == 'P1' then profileDir = 'ProfileSlot_Player1' else profileDir = 'ProfileSlot_Player2' end
		WriteFileContents(PROFILEMAN:GetProfileDir(profileDir).."/Scores.txt",toWrite,true)
	end
end

-- Add a new score to SL[pn][Scores]
AddScore = function(player)
	local pn = ToEnumShortString(player)
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
	local TapNoteScores = {
		Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	}
	local RadarCategories = {
		Types = { 'Holds', 'Mines', 'Hands', 'Rolls' },
	}
	local stats = {}
	local stepsType = ToEnumShortString(GetStepsType())
	if stepsType == 'Dance_Single' then stepsType = 'dance-single' end
	if stepsType == 'Dance_Double' then stepsType = 'dance-double' end
	stats.rate = SL.Global.ActiveModifiers.MusicRate
	stats.score = pss:GetPercentDancePoints()
	stats.grade = ToEnumShortString(pss:GetGrade())
	stats.dateTime = GetCurrentDateTime()
	for i=1,#TapNoteScores.Types do
		local window = TapNoteScores.Types[i]
		local number = pss:GetTapNoteScores( "TapNoteScore_"..window )
		stats[window] = number
	end
	for index, RCType in ipairs(RadarCategories.Types) do
		local performance = pss:GetRadarActual():GetValue( "RadarCategory_"..RCType )
		stats[RCType] = performance
	end
	local hash = GenerateHash(stepsType,ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty()))
	if not SL[pn]['Scores'][hash] then SL[pn]['Scores'][hash] = {FirstPass='Never',NumTimesPlayed = 0} end
	table.insert(SL[pn]['Scores'][hash],stats)
	SL[pn]['Scores'][hash].LastPlayed = stats.dateTime
	SL[pn]['Scores'][hash].NumTimesPlayed = tonumber(SL[pn]['Scores'][hash].NumTimesPlayed) + 1
	SL[pn]['Scores'][hash].title = GAMESTATE:GetCurrentSong():GetMainTitle()
	SL[pn]['Scores'][hash].Difficulty = ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty())
	SL[pn]['Scores'][hash].group = GAMESTATE:GetCurrentSong():GetGroupName()
	SL[pn]['Scores'][hash].StepsType = stepsType
	SL[pn]['Scores'][hash].hash = hash
	if SL[pn]['Scores'][hash].FirstPass == "Never" and stats.grade ~= 'Grade_Failed' then SL[pn]['Scores'][hash].FirstPass = stats.dateTime end
end

GetScores = function(player, song, steps, rateCheck)
	local pn = ToEnumShortString(player)
	local currentSong = song:GetMainTitle()
	local group = song:GetGroupName()
	local difficulty = ToEnumShortString(steps:GetDifficulty())
	local stepsType = ToEnumShortString(steps:GetStepsType())
	if stepsType == 'Dance_Single' then stepsType = 'dance-single' end
	if stepsType == 'Dance_Double' then stepsType = 'dance-double' end
	local rate = SL.Global.ActiveModifiers.MusicRate
	local RateScores = {}
	local hash = GenerateHash(stepsType,difficulty,song)
	if SL[pn]['Scores'][hash] then
		for score in ivalues(SL[pn]['Scores'][hash]) do
			if rateCheck then
				if tonumber(score.rate) == rate and score.grade ~= "Failed" then RateScores[#RateScores+1] = score end
			else 
				RateScores[#RateScores+1] = score
			end
		end
	end
	if #RateScores > 0 then
		table.sort(RateScores,function(k1,k2) return tonumber(k1.score) > tonumber(k2.score) end)
		return RateScores
	else return nil end
end