local GetSongDirs = function()
	local songs = SONGMAN:GetAllSongs()
	local list = {}
	for song in ivalues(songs) do
		list[song:GetSongDir()]=song:GetMainTitle()
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
		local group
		local song
		local groupSong
		local Difficulty
		local StepsType
		local songDir = GetSongDirs()
		for line in ivalues(contents) do
			if string.find(line,"<Song Dir=") then
				groupSong = "/"..string.gsub(line,"<Song Dir='(Songs/[%w%p ]*/)'>","%1"):gsub("&apos;","'"):gsub("&amp;","&")
				group = Split(groupSong,"/")[2]
				if songDir[groupSong] then song = songDir[groupSong]
				else song = Split(groupSong,"/")[3] end
			elseif string.find(line,"<Steps Difficulty='") then
				local iterator = string.gmatch("<Steps Difficulty='Challenge' StepsType='dance-single'>","[%w%p]*='([%w%p]*)'")
				Difficulty = iterator()
				StepsType = iterator()
				--for some reason in Stats.xml Dance_Single is listed as dance-single. Change it back to Dance_Single for consistency
				--TODO other step types will probably also come out wrong
				if StepsType == "dance-single" then StepsType = "Dance_Single" end
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
			elseif string.find(line,"</HighScore>") then
				highScore.group = group
				highScore.song = song
				highScore.Difficulty = Difficulty
				highScore.StepsType = StepsType
				table.insert(statsTable,highScore)
				highScore = {}
			end
		end
	end
	--local scoreTime = PROFILEMAN:GetProfile('P1'):GetHighScoreList(GAMESTATE:GetCurrentSong(),GAMESTATE:GetCurrentSteps('P1')):GetHighScores()[1]:GetDate()
	--local testTable = Split(string.gsub(scoreTime,'^(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)','%1 %2 %3 %4 %5 %6')," ")
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
			if #score == 18 then
				table.insert(Scores,{
					song = score[1],
					group = score[2],
					Difficulty = score[3],
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
					StepsType = score[18]})
			end
		end
	--if there's no Scores.txt then import all the scores in Stats.xml to get started
	else Scores = LoadFromStats(pn)
	end
	if SL[pn] then SL[pn]['Scores'] = Scores end
end

-- Write rate scores to disk
SaveScores = function(pn)
	if SL[pn]['Scores'] then
		toWrite = ""
		for score in ivalues(SL[pn]['Scores']) do --TODO don't type this out manually
			toWrite = toWrite..score.song.."\t"..score.group.."\t"..score.Difficulty.."\t"..score.rate.."\t"..score.score.."\t"
			..score.W1.."\t"..score.W2.."\t"..score.W3.."\t"..score.W4.."\t"..score.W5.."\t"..score.Miss.."\t"
			..score.Holds.."\t"..score.Mines.."\t"..score.Hands.."\t"..score.Rolls.."\t"
			..score.grade.."\t"..score.dateTime.."\t"..score.StepsType.."\r\n"
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
	stats.song = GAMESTATE:GetCurrentSong():GetMainTitle()
	stats.group = GAMESTATE:GetCurrentSong():GetGroupName()
	stats.Difficulty = ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty())
	stats.rate = SL.Global.ActiveModifiers.MusicRate
	stats.score = pss:GetPercentDancePoints()
	stats.grade = ToEnumShortString(pss:GetGrade())
	stats.dateTime = string.format("%04d",Year()).."-"..string.format("%02d", MonthOfYear()+1).."-"..string.format("%02d", DayOfMonth())
					 .." "..string.format("%02d", Hour())..":"..string.format("%02d", Minute())
	stats.StepsType = ToEnumShortString(GetStepsType())
	for i=1,#TapNoteScores.Types do
		local window = TapNoteScores.Types[i]
		local number = pss:GetTapNoteScores( "TapNoteScore_"..window )
		stats[window] = number
	end
	for index, RCType in ipairs(RadarCategories.Types) do
		local performance = pss:GetRadarActual():GetValue( "RadarCategory_"..RCType )
		stats[RCType] = performance
	end
	table.insert(SL[pn]['Scores'],stats)
end

GetRateScores = function(player, song, steps)
	local pn = ToEnumShortString(player)
	local currentSong = song:GetMainTitle()
	local group = song:GetGroupName()
	local difficulty = ToEnumShortString(steps:GetDifficulty())
	local rate = SL.Global.ActiveModifiers.MusicRate
	local RateScores = {}
	for score in ivalues(SL[pn]['Scores']) do
		if score.song == currentSong and score.group == group and score.Difficulty == difficulty
		and tonumber(score.rate) == rate then
			RateScores[#RateScores+1] = score
		end
	end
	if #RateScores > 0 then
		table.sort(RateScores,function(k1,k2) return tonumber(k1.score) > tonumber(k2.score) end)
		return RateScores
	else return nil end
end


--[[ This finds the rate based on the highscore list from Stats.xml
GetRateScores = function(player, song, steps)
	local pn = ToEnumShortString(player)
	local allScores = PROFILEMAN:GetProfile(pn):GetHighScoreList(GAMESTATE:GetCurrentSong(),GAMESTATE:GetCurrentSteps(pn)):GetHighScores()
	local rateScores = {}
	for highScore in ivalues(allScores) do
		if string.gsub(highScore:GetModifiers(),".*(%d.%d+)xMusic.?","%1") == tostring(SL.Global.ActiveModifiers.MusicRate) then
			rateScores[#rateScores+1] = highScore
		end
	end
	if #rateScores > 0 then return rateScores
	else return nil end
end
--]]