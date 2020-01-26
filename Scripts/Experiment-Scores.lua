local function GetSongDirs()
	local songs = SONGMAN:GetAllSongs()
	local list = {}
	for item in ivalues(songs) do
		list[item:GetSongDir()]={title = item:GetMainTitle(), song = item}
	end
	return list
end

local function AddToHashLookup()
	local songs = GetSongDirs()
	local newChartsFound = false
	for dir,song in pairs(songs) do
		if not SL.Global.HashLookup[dir] then SL.Global.HashLookup[dir] = {} end
		local allSteps = song.song:GetAllSteps()
		for _,steps in pairs(allSteps) do
			local stepsType = ToEnumShortString(steps:GetStepsType()) --TODO this only works with dance-single and dance-double
			stepsType = string.lower(stepsType):gsub("_","-")
			local difficulty = ToEnumShortString(steps:GetDifficulty())
			if not SL.Global.HashLookup[dir] or not SL.Global.HashLookup[dir][difficulty] or not SL.Global.HashLookup[dir][difficulty][stepsType] then
				local hash = GenerateHash(stepsType,difficulty,song.song)
				if #hash > 0 then
					if not SL.Global.HashLookup[dir][difficulty] then SL.Global.HashLookup[dir][difficulty] = {} end
					SL.Global.HashLookup[dir][difficulty][stepsType] = hash
					newChartsFound = true
				end
			end
		end
	end
	if newChartsFound then SaveHashLookup() end
end

function LoadHashLookup()
	local contents
	local hashLookup = {}
	local path = THEME:GetCurrentThemeDirectory() .. "Other/HashLookup.txt"
	if FILEMAN:DoesFileExist(path) then
		contents = GetFileContents(path)
		local dir
		for line in ivalues(contents) do
			local item = Split(line,"\t")
			if #item == 1 then
				dir = item[1]
				if not hashLookup[dir] then hashLookup[dir] = {} end
			elseif #item == 3 then
				if not hashLookup[dir][item[1]] then hashLookup[dir][item[1]] = {} end
				hashLookup[dir][item[1]][item[2]] = item[3]
			end
		end
		SL.Global.HashLookup = hashLookup
	end 
	AddToHashLookup()
end

function SaveHashLookup()
	if SL.Global.HashLookup then
		local toWrite = ""
		for dir,charts in pairs(SL.Global.HashLookup) do
			toWrite = toWrite..dir.."\r\n"
			for diff,stepTypes in pairs(charts) do
				for stepType, hash in pairs(stepTypes) do
					toWrite = toWrite..diff.."\t"..stepType.."\t"..hash.."\r\n"
				end
			end
		end
		local path = THEME:GetCurrentThemeDirectory() .. "Other/HashLookup.txt"
		WriteFileContents(path,toWrite,true)
	end
end

-- Checks to see if any songs that have scores in stats but weren't loaded when we first ran LoadFromStats
-- are now on the machine.
function LoadNewFromStats(player)
	local songs = SONGMAN:GetAllSongs()
	local pn = ToEnumShortString(player)
	for song in ivalues(songs) do
		for chart in ivalues(song:GetAllSteps()) do
			local difficulty = ToEnumShortString(chart:GetDifficulty())
			local stepsType = ToEnumShortString(chart:GetStepsType()):gsub("_","-"):lower()
			local hash 
			if next(SL.Global.HashLookup[song:GetSongDir()]) and SL.Global.HashLookup[song:GetSongDir()][difficulty] and SL.Global.HashLookup[song:GetSongDir()][difficulty][stepsType] then
				hash = SL.Global.HashLookup[song:GetSongDir()][difficulty][stepsType]
			end
			if hash and not GetScores(player,hash) and #PROFILEMAN:GetProfile(pn):GetHighScoreList(song,chart):GetHighScores() > 0 then
				local lastPlayed = "1980-01-01 12:12:00"
				for highScore in ivalues(PROFILEMAN:GetProfile(pn):GetHighScoreList(song,chart):GetHighScores()) do
						local TapNoteScores = {
							Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
						}
						local RadarCategories = {
							Types = { 'Holds', 'Mines', 'Hands', 'Rolls' },
						}
						local stats = {}
						local mods = highScore:GetModifiers()
						stats.rate = string.find(mods, "xMusic") and string.gsub(mods,".*(%d.%d+)xMusic.*","%1") or 1
						stats.score = highScore:GetPercentDP()
						stats.grade = ToEnumShortString(highScore:GetGrade())
						stats.dateTime = highScore:GetDate()
						if DateToMinutes(stats.dateTime) > DateToMinutes(lastPlayed) then lastPlayed = stats.dateTime end
						for i=1,#TapNoteScores.Types do
							local window = TapNoteScores.Types[i]
							local number = highScore:GetTapNoteScore( "TapNoteScore_"..window )
							stats[window] = number
						end
						for index, RCType in ipairs(RadarCategories.Types) do
							local performance = highScore:GetRadarValues():GetValue( "RadarCategory_"..RCType )
							stats[RCType] = performance
						end
						if not SL[pn]['Scores'][hash] then SL[pn]['Scores'][hash] = {FirstPass='Never',NumTimesPlayed = 0} end
						if not SL[pn]['Scores'][hash]['HighScores'] then SL[pn]['Scores'][hash]['HighScores'] = {} end
						table.insert(SL[pn]['Scores'][hash]['HighScores'],stats)
					end
					SL[pn]['Scores'][hash].LastPlayed = lastPlayed
					SL[pn]['Scores'][hash].NumTimesPlayed = #PROFILEMAN:GetProfile('P1'):GetHighScoreList(song,chart):GetHighScores() --TODO need to parse stats for real num
					SL[pn]['Scores'][hash].title = song:GetMainTitle()
					SL[pn]['Scores'][hash].Difficulty = difficulty
					SL[pn]['Scores'][hash].group = song:GetGroupName()
					SL[pn]['Scores'][hash].StepsType = stepsType
					SL[pn]['Scores'][hash].hash = hash
					SL[pn]['Scores'][hash].FirstPass = "Unknown" --TODO this can also be more accurate with NumTimesPlayed
			end
		end
	end
end

-- If this is the first time loading a profile in Experiment mode then we won't have a list of song scores.
-- Read in from Stats.xml to start us off. 
local function LoadFromStats(pn)
	local profileDir
	if pn == 'P1' then profileDir = 'ProfileSlot_Player1' else profileDir = 'ProfileSlot_Player2' end
	local path = PROFILEMAN:GetProfileDir(profileDir)..'Stats.xml'
	local contents = ""
	local statsTable = {}
	local highScore = {}
	local hashLookup = {}
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
					if not hashLookup[groupSong] then hashLookup[groupSong] = {} end
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
					if not hashLookup[groupSong][Difficulty] then hashLookup[groupSong][Difficulty] = {} end
					hashLookup[groupSong][Difficulty][StepsType] = hash
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
				if not statsTable[hash]['HighScores'] then statsTable[hash]['HighScores'] = {} end
				table.insert(statsTable[hash]['HighScores'],highScore)
				if highScore.grade ~= "Failed" and DateToMinutes(highScore.dateTime) < tempFirstPass then
					tempFirstPass = DateToMinutes(highScore.dateTime)
					firstPass = highScore.dateTime
				end
				highScore = {}
			elseif string.find(line,"</HighScoreList>") and song then
				local tempStepsType = CapitalizeWords(StepsType):gsub("-","_")
				local profileScores = PROFILEMAN:GetProfile(pn):GetHighScoreList(song,song:GetOneSteps(tempStepsType,Difficulty)):GetHighScores() 
				if tonumber(numTimesPlayed) > #profileScores then firstPass = "Unknown" end --if we've played it more times then there are scores we can't tell when it was passed first
				local machineScores = PROFILEMAN:GetMachineProfile():GetHighScoreList(song,song:GetOneSteps(tempStepsType,Difficulty)):GetHighScores()
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

	return statsTable, hashLookup
end

-- Read scores from disk if they exist. If they don't, then load our initial values with LoadFromStats
function LoadScores(pn)
	local profileDir
	if pn == 'P1' then profileDir = 'ProfileSlot_Player1' else profileDir = 'ProfileSlot_Player2' end
	local contents
	local Scores = {}
	local hashLookup = {}
	if FILEMAN:DoesFileExist(PROFILEMAN:GetProfileDir(profileDir).."/Scores.txt") then
		contents = GetFileContents(PROFILEMAN:GetProfileDir(profileDir).."/Scores.txt")
		local hash
		for line in ivalues(contents) do
			local score = Split(line,"\t")
			if #score == 8 then
				hash = nil
				hash = score[8]
				if hash then
					if not Scores[hash] then Scores[hash] = {} end
					Scores[hash].title = score[1]
					Scores[hash].group = score[2]
					Scores[hash].Difficulty = score[3]
					Scores[hash].StepsType = score[4]
					Scores[hash].LastPlayed = score[5]
					Scores[hash].NumTimesPlayed = score[6]
					Scores[hash].FirstPass = score[7]
					Scores[hash].hash = hash
				end
			elseif #score == 14 and hash then
				if not Scores[hash]['HighScores'] then Scores[hash]['HighScores'] = {} end
				table.insert(Scores[hash]['HighScores'],{
					rate = score[1],
					score = score[2],
					W1 = score[3],
					W2 = score[4],
					W3 = score[5],
					W4 = score[6],
					W5 = score[7],
					Miss = score[8],
					Holds = score[9],
					Mines = score[10],
					Hands = score[11],
					Rolls = score[12],
					grade = score[13],
					dateTime = score[14]
					})
			end
		end
	--if there's no Scores.txt then import all the scores in Stats.xml to get started
	else 
		Scores, hashLookup = LoadFromStats(pn)
		SL.Global.HashLookup = hashLookup 
	end
	if SL[pn] then 
		SL[pn]['Scores'] = Scores

	end
end

-- Write rate scores to disk
function SaveScores(pn)
	if SL[pn]['Scores'] then
		local toWrite = ""
		for _,hash in pairs(SL[pn]['Scores']) do --TODO don't type this out manually
			if hash.hash then
				toWrite = toWrite..hash.title.."\t"..hash.group.."\t"..hash.Difficulty.."\t"..hash.StepsType.."\t"..hash.LastPlayed.."\t"..hash.NumTimesPlayed.."\t"
					..hash.FirstPass.."\t"..hash.hash.."\r\n"
				if hash["HighScores"] then
					for score in ivalues(hash["HighScores"]) do
						toWrite = toWrite..score.rate.."\t"..score.score.."\t"
						..score.W1.."\t"..score.W2.."\t"..score.W3.."\t"..score.W4.."\t"..score.W5.."\t"..score.Miss.."\t"
						..score.Holds.."\t"..score.Mines.."\t"..score.Hands.."\t"..score.Rolls.."\t"
						..score.grade.."\t"..score.dateTime.."\r\n"
					end
				end
			end
		end
		local profileDir
		if pn == 'P1' then profileDir = 'ProfileSlot_Player1' else profileDir = 'ProfileSlot_Player2' end
		WriteFileContents(PROFILEMAN:GetProfileDir(profileDir).."/Scores.txt",toWrite,true)
	end
end

-- Add a new score to SL[pn][Scores]
function AddScore(player)
	local pn = ToEnumShortString(player)
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
	local TapNoteScores = {
		Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	}
	local RadarCategories = {
		Types = { 'Holds', 'Mines', 'Hands', 'Rolls' },
	}
	local stats = {}
	local stepsType = string.lower(ToEnumShortString(GetStepsType()):gsub("_","-"))
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
	if #hash > 0 then
		if not SL[pn]['Scores'][hash] then SL[pn]['Scores'][hash] = {FirstPass='Never',NumTimesPlayed = 0} end
		if not SL[pn]['Scores'][hash]['HighScores'] then SL[pn]['Scores'][hash]['HighScores'] = {} end
		table.insert(SL[pn]['Scores'][hash]['HighScores'],stats)
		SL[pn]['Scores'][hash].LastPlayed = stats.dateTime
		SL[pn]['Scores'][hash].NumTimesPlayed = tonumber(SL[pn]['Scores'][hash].NumTimesPlayed) + 1
		SL[pn]['Scores'][hash].title = GAMESTATE:GetCurrentSong():GetMainTitle()
		SL[pn]['Scores'][hash].Difficulty = ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty())
		SL[pn]['Scores'][hash].group = GAMESTATE:GetCurrentSong():GetGroupName()
		SL[pn]['Scores'][hash].StepsType = stepsType
		SL[pn]['Scores'][hash].hash = hash
		if SL[pn]['Scores'][hash].FirstPass == "Never" and stats.grade ~= 'Grade_Failed' then SL[pn]['Scores'][hash].FirstPass = stats.dateTime end
	else SM("WARNING: Could not generate hash for: "..GAMESTATE:GetCurrentSong():GetMainTitle()) end
end

function GetScores(player, hash, checkRate, checkFailed)
	local pn = ToEnumShortString(player)
	local rate = SL.Global.ActiveModifiers.MusicRate
	local checkRate = checkRate or false
	local checkFailed = checkFailed or false
	local HighScores = {}
	if SL[pn]['Scores'][hash] and SL[pn]['Scores'][hash]['HighScores'] then
		if not checkRate and not checkFailed then HighScores = SL[pn]['Scores'][hash]['HighScores']
		else
			for score in ivalues(SL[pn]['Scores'][hash]['HighScores']) do
				if checkRate and not checkFailed then
					if tonumber(score.rate) == rate then HighScores[#HighScores+1] = score end
				elseif not checkRate and checkFailed then
					if score.grade ~= "Failed" then HighScores[#HighScores+1] = score end
				elseif checkRate and checkFailed then
					if tonumber(score.rate) == rate and score.grade ~= "Failed" then HighScores[#HighScores+1] = score end
				end
			end
		end
	end
	if #HighScores > 0 then
		table.sort(HighScores,function(k1,k2) return tonumber(k1.score) > tonumber(k2.score) end)
		return HighScores
	else return nil end
end

-- returns the hash stored in SL.Global.HashLookup
function GetCurrentHash(player)
	local pn = ToEnumShortString(player)
	local song = GAMESTATE:GetCurrentSong()
	local difficulty = ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty())
	local stepsType = ToEnumShortString(GetStepsType()):gsub("_","-"):lower()
	if next(SL.Global.HashLookup[song:GetSongDir()]) then --all songs should be listed in HashLookup but if we can't generate hashes it'll be an empty table
		return SL.Global.HashLookup[song:GetSongDir()][difficulty][stepsType]
	else
		return nil
	end
end

-- Overwrite the HashLookup table for the current song.
-- This is called in ScreenEvaluation Common when GenerateHash doesn't match the HashLookup
function AddCurrentHash()
	local song = GAMESTATE:GetCurrentSong()
	local dir = song:GetSongDir()
	SL.Global.HashLookup[dir] = {}
	local allSteps = song:GetAllSteps()
	for _,steps in pairs(allSteps) do
		local stepsType = ToEnumShortString(steps:GetStepsType()):gsub("_","-"):lower()
		local difficulty = ToEnumShortString(steps:GetDifficulty())
		if not SL.Global.HashLookup[dir] or not SL.Global.HashLookup[dir][difficulty] or not SL.Global.HashLookup[dir][difficulty][stepsType] then
			local hash = GenerateHash(stepsType,difficulty,song)
			if #hash > 0 then
				if not SL.Global.HashLookup[dir][difficulty] then SL.Global.HashLookup[dir][difficulty] = {} end
				SL.Global.HashLookup[dir][difficulty][stepsType] = hash
			end
		end
	end
	SaveHashLookup()
end