local NumEntries = 13
local RowHeight = 24
local RpgYellow = color("#CDAA9B")
local RpgText = Color.White
local ItlPink = color("1,0.2,0.406,1")

local paneWidth1Player = 330
local paneWidth2Player = 230
local paneWidth = (GAMESTATE:GetNumSidesJoined() == 1) and paneWidth1Player or paneWidth2Player
local paneHeight = 360
local borderWidth = 2

local SetRpgStyle = function(eventAf)
	eventAf:GetChild("MainBorder"):diffuse(RpgYellow)
	eventAf:GetChild("BackgroundImage"):visible(true)
	eventAf:GetChild("BackgroundColor"):diffuse(color("0,0,0.1,0.8"))
	eventAf:GetChild("BackgroundColor2"):visible(true):diffuse(color("1,1,1,0.05")):faderight(0.1):fadeleft(0.1)
	eventAf:GetChild("HeaderBorder"):diffuse(RpgYellow)
	
	local idx = SL.Global.ActiveColorIndex
	local faction_name = SL.SRPG8.GetFactionName(idx)

	if faction_name == "Stamina Nation" then
		eventAf:GetChild("HeaderBackground")
				:diffusetopedge(color("#523328"))
				:diffusebottomedge(color("#815354"))
	elseif faction_name == "Democratic People's Republic of Timing" then
		eventAf:GetChild("HeaderBackground")
				:diffusetopedge(color("#15313D"))
				:diffusebottomedge(color("#34605D"))
    elseif faction_name == "Footspeed Empire" then
		eventAf:GetChild("HeaderBackground")
				:diffusetopedge(color("#412147"))
				:diffusebottomedge(color("#634B80"))
	else
		-- "Unaffiliated"
		eventAf:GetChild("HeaderBackground")
				:diffusetopedge(color("#14362D"))
				:diffusebottomedge(color("#376648"))
	end

	eventAf:GetChild("Header"):diffuse(RpgText)
	eventAf:GetChild("EX"):visible(false)
	eventAf:GetChild("BodyText"):diffuse(Color.White)
	eventAf:GetChild("PaneIcons"):GetChild("Text"):diffuse(RpgText)

	local leaderboard = eventAf:GetChild("Leaderboard")
	for i=1, NumEntries do
		local entry = leaderboard:GetChild("LeaderboardEntry"..i)
		entry:GetChild("Rank"):diffuse(Color.White)
		entry:GetChild("Name"):diffuse(Color.White)
		entry:GetChild("Score"):diffuse(Color.White)
		entry:GetChild("Date"):diffuse(Color.White)
	end
end

local SetItlStyle = function(eventAf)
	eventAf:GetChild("MainBorder"):diffuse(ItlPink)
	eventAf:GetChild("BackgroundImage"):visible(false)
	eventAf:GetChild("BackgroundColor"):diffuse(Color.Black):diffusealpha(1)
	eventAf:GetChild("BackgroundColor2"):visible(false)
	eventAf:GetChild("HeaderBorder"):diffuse(ItlPink)
	eventAf:GetChild("HeaderBackground"):diffusetopedge(color("0.3,0.3,0.3,1")):diffusebottomedge(color("0.157,0.157,0.165,1"))
	eventAf:GetChild("Header"):diffuse(Color.White)
	eventAf:GetChild("EX"):diffuse(Color.White):visible(false)
	eventAf:GetChild("BodyText"):diffuse(Color.White)
	eventAf:GetChild("PaneIcons"):GetChild("Text"):diffuse(ItlPink)

	local leaderboard = eventAf:GetChild("Leaderboard")
	for i=1, NumEntries do
		local entry = leaderboard:GetChild("LeaderboardEntry"..i)
		entry:GetChild("Rank"):diffuse(Color.White)
		entry:GetChild("Name"):diffuse(Color.White)
		entry:GetChild("Score"):diffuse(Color.White)
		entry:GetChild("Date"):diffuse(Color.White)
	end
end

-- Returns an actorframe that contains both the banner and the song title to
-- be used in the event overlay.
local BannerAndSong = function(x, y, zoom)
	local af = Def.ActorFrame{ 
		Name="BannerAndSong",
		InitCommand=function(self) 
			self:xy(x, y):zoom(zoom):vertalign("top") 
		end,
		ResetCommand=function(self)
			self:visible(false)
		end
	}

	af[#af+1] = Def.Banner{
		Name="Banner",
		InitCommand=function(self)
			local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			if SongOrCourse and SongOrCourse:HasBanner() then
					--song or course banner, if there is one
				if GAMESTATE:IsCourseMode() then
					self:LoadFromCourse( GAMESTATE:GetCurrentCourse() )
				else
					self:LoadFromSong( GAMESTATE:GetCurrentSong() )
				end
			end
			self:setsize(418, 164)
		end
	}
	af[#af+1] = LoadFont("Common Normal")..{
		Name="SongName",
		InitCommand=function(self)
			local songtitle = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse():GetDisplayFullTitle()) or GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
			if songtitle then self:settext(songtitle):zoom(2):maxwidth(500):vertalign("top"):y(90):diffuse(color("1,0.972,0.792,1")) end
		end
	}
	
	return af
end

local SetEntryText = function(rank, name, score, date, actor)
	if actor == nil then return end

	actor:GetChild("Rank"):settext(rank)
	actor:GetChild("Name"):settext(name)
	actor:GetChild("Score"):settext(score)
	actor:GetChild("Date"):settext(date)
end

local SetLeaderboardData = function(eventAf, leaderboardData, event)
	if leaderboardData == nil then return end

	local entryNum = 1
	local rivalNum = 1
	local leaderboard = eventAf:GetChild("Leaderboard")
	local defaultTextColor = event == "itl" and Color.White or Color.White

	-- Hide the rival and self highlights.
	-- They will be unhidden and repositioned as needed below.
	for i=1,3 do
		leaderboard:GetChild("Rival"..i):visible(false)
	end
	leaderboard:GetChild("Self"):visible(false)

	for gsEntry in ivalues(leaderboardData) do
		local entry = leaderboard:GetChild("LeaderboardEntry"..entryNum)
		SetEntryText(
			gsEntry["rank"]..".",
			gsEntry["name"],
			string.format("%.2f%%", gsEntry["score"]/100),
			ParseGroovestatsDate(gsEntry["date"]),
			entry
		)
		if gsEntry["isRival"] then
			if gsEntry["isFail"] then
				entry:GetChild("Rank"):diffuse(Color.Black)
				entry:GetChild("Name"):diffuse(Color.Black)
				entry:GetChild("Score"):diffuse(Color.Red)
				entry:GetChild("Date"):diffuse(Color.Black)
			else
				entry:diffuse(Color.Black)
			end
			leaderboard:GetChild("Rival"..rivalNum):y(entry:GetY()):visible(true)
			rivalNum = rivalNum + 1
		elseif gsEntry["isSelf"] then
			if gsEntry["isFail"] then
				entry:GetChild("Rank"):diffuse(Color.Black)
				entry:GetChild("Name"):diffuse(Color.Black)
				entry:GetChild("Score"):diffuse(Color.Red)
				entry:GetChild("Date"):diffuse(Color.Black)
			else
				entry:diffuse(Color.Black)
			end
			leaderboard:GetChild("Self"):y(entry:GetY()):visible(true)
		else
			entry:diffuse(defaultTextColor)
		end

		-- Why does this work for normal entries but not for Rivals/Self where
		-- I have to explicitly set the colors for each child??
		if gsEntry["isFail"] then
			entry:GetChild("Score"):diffuse(Color.Red)
		end
		entryNum = entryNum + 1
	end

	-- Empty out any remaining entries.
	for i=entryNum, NumEntries do
		local entry = leaderboard:GetChild("LeaderboardEntry"..i)
		-- We didn't get any scores if i is still == 1.
		if i == 1 then
			SetEntryText("", "No Scores", "", "", entry)
		else
			-- Empty out the remaining rows.
			SetEntryText("", "", "", "", entry)
		end
	end
end

local GetRpgPaneFunctions = function(eventAf, rpgData, player)
	local score, scoreDelta, rate, rateDelta = 0, 0, 0, 0
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
	local paneTexts = {}
	local paneFunctions = {}

	if rpgData["result"] == "score-added" then
		score = pss:GetPercentDancePoints() * 100
		scoreDelta = score
		rate = SL.Global.ActiveModifiers.MusicRate or 1.0
		rateDelta = rate
	elseif rpgData["result"] == "improved" or rpgData["result"] == "score-not-improved" then
		score = pss:GetPercentDancePoints() * 100
		scoreDelta = rpgData["scoreDelta"] and rpgData["scoreDelta"]/100.0 or 0.0
		rate = SL.Global.ActiveModifiers.MusicRate or 1.0
		rateDelta = rpgData["rateDelta"] and rpgData["rateDelta"]/100.0 or 0.0
	else
		-- song-not-ranked (invalid case)
		return paneFunctions
	end

	local statImprovements = {}
	local skillImprovements = {}
	local quests = {}
	local progress = rpgData["progress"]
	if progress then
		if progress["statImprovements"] then
			for improvement in ivalues(progress["statImprovements"]) do
				if improvement["gained"] > 0 then
					table.insert(
						statImprovements,
						string.format("+%d %s", improvement["gained"], string.upper(improvement["name"]))
					)
				end
			end
		end

		if progress["skillImprovements"] then
			skillImprovements = progress["skillImprovements"]
		end

		if progress["questsCompleted"] then
			for quest in ivalues(progress["questsCompleted"]) do
				local questStrings = {}
				table.insert(questStrings, string.format(
					"Completed \"%s\"!\n",
					quest["title"]
				))

				-- Group all the rewards by type.
				local allRewards = {}
				for reward in ivalues(quest["rewards"]) do
					if allRewards[reward["type"]] == nil then
						allRewards[reward["type"]] = {}
					end
					table.insert(allRewards[reward["type"]], reward["description"])
				end

				for rewardType, rewardDescriptions in pairs(allRewards) do
					table.insert(questStrings, string.format(
						"%s"..
						"%s\n",
						rewardType == "ad-hoc" and "" or string.upper(rewardType)..":\n",
						table.concat(rewardDescriptions, "\n")
					))
				end

				table.insert(quests, table.concat(questStrings, "\n"))
			end
		end
	end

	table.insert(paneTexts, string.format(
		"Skill Improvements\n\n"..
		"%.2f%% (%+.2f%%) at\n"..
		"%.2fx (%+.2fx) rate\n\n"..
		"%s"..
		"%s",
		score, scoreDelta,
		rate, rateDelta,
		#statImprovements == 0 and "" or table.concat(statImprovements, "\n").."\n\n",
		#skillImprovements == 0 and "" or table.concat(skillImprovements, "\n").."\n\n"
	))

	for quest in ivalues(quests) do
		table.insert(paneTexts, quest)
	end

	for text in ivalues(paneTexts) do
		table.insert(paneFunctions, function(eventAf)
			SetRpgStyle(eventAf)
			eventAf:GetChild("Header"):settext(rpgData["name"])
			eventAf:GetChild("Leaderboard"):visible(false)
			local bodyText = eventAf:GetChild("BodyText")

			-- We don't want text to run out through the bottom.
			-- Incrementally adjust the zoom while adjust wrapwdithpixels until it fits.
			-- Not the prettiest solution but it works.
			for zoomVal=1.0, 0.1, -0.05 do
				bodyText:zoom(zoomVal)
				bodyText:wrapwidthpixels(paneWidth/(zoomVal))
				bodyText:settext(text):visible(true)
				if bodyText:GetHeight() * zoomVal <= paneHeight - RowHeight*1.5 then
					break
				end
			end
			local offset = 0

			while offset <= #text do
				-- Search for all numbers (decimals included).
				-- They may include the +/- prefixes and also potentially %/x as suffixes.
				local i, j = string.find(text, "[-+]?[%d]*%.?[%d]+[%%x]?", offset)
				-- No more numbers found. Break out.
				if i == nil then
					break
				end
				-- Extract the actual numeric text.
				local substring = string.sub(text, i, j)

				local clr = Color.Green

				-- Except negatives should be red.
				if substring:sub(1, 1) == "-" then
					clr = Color.Red
				-- And positives should be green.
				elseif substring:sub(1, 1) == "+" then
					clr = Color.Green
				end

				bodyText:AddAttribute(i-1, {
					Length=#substring,
					Diffuse=clr
				})

				offset = j + 1
			end

			offset = 0

			while offset <= #text do
				-- Search for all quoted strings.
				local i, j = string.find(text, "\".-\"", offset)
				-- No more found. Break out.
				if i == nil then
					break
				end
				-- Extract the actual numeric text.
				local substring = string.sub(text, i, j)

				bodyText:AddAttribute(i-1, {
					Length=#substring,
					Diffuse=Color.Green
				})

				offset = j + 1
			end
		end)
	end

	table.insert(paneFunctions, function(eventAf)
		SetRpgStyle(eventAf)
		eventAf:GetChild("Header"):settext(rpgData["name"])
		SetLeaderboardData(eventAf, rpgData["rpgLeaderboard"], "rpg")
		eventAf:GetChild("Leaderboard"):visible(true)
		eventAf:GetChild("BodyText"):visible(false)
	end)

	return paneFunctions
end

local GetItlPaneFunctions = function(eventAf, itlData, player)
	local pn = ToEnumShortString(player)
	local paneTexts = {}
	local paneFunctions = {}
	
	local score = CalculateExScore(player)
	local scoreDelta = itlData["scoreDelta"]/100.0

	local steps = GAMESTATE:GetCurrentSteps(player)
	local chartName = steps:GetChartName()

	local maxPoints = 0
	local hash = SL[pn].Streams.Hash
	if itlData["maxPoints"] ~= nil then
		-- First try and fetch the maxPoints from the response.
		maxPoints = itlData["maxPoints"]
	elseif SL[pn].ITLData["hashMap"][hash] ~= nil then
		-- Then if it doesn't exist, try and parse it from ITL hashMap
		maxPoints = SL[pn].ITLData["hashMap"][hash]["maxPoints"]
	else
		-- Then if it still doesn't exist, try and parse it from the chartName.

		-- Note that playing OUTSIDE of the ITL pack will result in 0 points for all
		-- upscores since it won't have the relevant points data.
		local pointsStr = chartName:gsub(" pts", "")
		maxPoints = tonumber(pointsStr)
	end

	if maxPoints == nil then
		maxPoints = 0
	end

	local currentPoints = GetITLPointsForSong(maxPoints, score)
	local previousPoints = itlData["topScorePoints"]
	local pointDelta = currentPoints - previousPoints

	local currentRankingPointTotal = itlData["currentRankingPointTotal"]
	local previousRankingPointTotal = itlData["previousRankingPointTotal"]
	local rankingDelta = currentRankingPointTotal - previousRankingPointTotal

	local currentSongPointTotal = itlData["currentSongPointTotal"]
	local previousSongPointTotal = itlData["previousSongPointTotal"]
	local totalSongDelta = currentSongPointTotal - previousSongPointTotal

	local currentExPointTotal = itlData["currentExPointTotal"]
	local previousExPointTotal = itlData["previousExPointTotal"]
	local totalExDelta = currentExPointTotal - previousExPointTotal

	local currentPointTotal = itlData["currentPointTotal"]
	local previousPointTotal = itlData["previousPointTotal"]
	local totalDelta = currentPointTotal - previousPointTotal

	local isDoubles = itlData["isDoubles"]

	-- Also pass the response data to the progress box.
	local progressBox = SCREENMAN:GetTopScreen()
			:GetChild("Overlay")
			:GetChild("ScreenEval Common")
			:GetChild(pn.."_AF_Upper")
			:GetChild("EventProgress"..pn)
	if progressBox ~= nil then
		progressBox:playcommand("SetData",{
			itlData = {
				["name"] = itlData["name"]..(isDoubles and " Doubles" or ""),
				["score"] = score,
				["scoreDelta"] = scoreDelta,
				["currentPoints"] = currentPoints,
				["pointDelta"] = pointDelta,
				["currentRankingPointTotal"] = currentRankingPointTotal,
				["rankingDelta"] = rankingDelta,
				["currentSongPointTotal"] = currentSongPointTotal,
				["totalSongDelta"] = totalSongDelta,
				["currentExPointTotal"] = currentExPointTotal,
				["totalExDelta"] = totalExDelta,
				["currentPointTotal"] = currentPointTotal,
				["totalDelta"] = totalDelta
			},
		})
	end


	local statImprovements = {}
	local quests = {}
	local progress = itlData["progress"]
	if progress then
		if progress["statImprovements"] then
			for improvement in ivalues(progress["statImprovements"]) do
				if improvement["gained"] > 0 then
					if improvement["name"] == "clearType" then
						local clearTypeMap = {
							[0] = "No Play",
							[1] = "Clear",
							[2] = "FC",
							[3] = "FEC",
							[4] = "FFC",
							[5] = "FBFC",
						}
						local curr = improvement["current"]
						local prev = curr - improvement["gained"]

						table.insert(
							statImprovements,
							string.format("Clear Type: %s >>> %s", clearTypeMap[prev], clearTypeMap[curr]))
					elseif improvement["name"] == "grade" then
						local curr = improvement["current"]
						local prev = curr - improvement["gained"]

						local gradeMap = {
							[0] = "Other",
							[1] = "Quad",
							[2] = "Quint",
						}

						if curr ~= 0 and prev ~= current then
							table.insert(
								statImprovements,
								string.format("New %s!", gradeMap[curr])
							)
						end
					else
						local statName = improvement["name"]:gsub("Level", ""):gsub("^%l", string.upper)
						table.insert(
							statImprovements,
							string.format("%s Lvl: %d (+%d)", statName, improvement["current"], improvement["gained"])
						)
					end
				end
			end
		end

		if progress["questsCompleted"] then
			for quest in ivalues(progress["questsCompleted"]) do
				local questStrings = {}
				table.insert(questStrings, string.format(
					"Completed \"%s\"!\n",
					quest["title"]
				))

				-- Group all the rewards by type.
				local allRewards = {}
				for reward in ivalues(quest["rewards"]) do
					if allRewards[reward["type"]] == nil then
						allRewards[reward["type"]] = {}
					end
					table.insert(allRewards[reward["type"]], reward["description"])
				end

				for rewardType, rewardDescriptions in pairs(allRewards) do
					table.insert(questStrings, string.format(
						"%s"..
						"%s\n",
						rewardType == "ad-hoc" and "" or string.upper(rewardType)..":\n",
						table.concat(rewardDescriptions, "\n")
					))
				end

				table.insert(quests, table.concat(questStrings, "\n"))
			end
		end
	end

	table.insert(paneTexts, string.format(
		"EX Score: %.2f%% (%+.2f%%)\n"..
		"Points: %d (%+d)\n\n"..
		"Ranking Points: %d (%+d)\n"..
		"Song Points: %d (%+d)\n"..
		"EX Points: %d (%+d)\n"..
		"Total Points: %d (%+d)\n\n"..
		"%s",
		score, scoreDelta,
		currentPoints, pointDelta,
		currentRankingPointTotal, rankingDelta,
		currentSongPointTotal, totalSongDelta,
		currentExPointTotal, totalExDelta,
		currentPointTotal, totalDelta,
		#statImprovements == 0 and "" or table.concat(statImprovements, "\n").."\n\n"
	))

	for quest in ivalues(quests) do
		table.insert(paneTexts, quest)
	end

	for text in ivalues(paneTexts) do
		table.insert(paneFunctions, function(eventAf)
			SetItlStyle(eventAf)
			local isDoubles = itlData["isDoubles"]
			eventAf:GetChild("Header"):settext(itlData["name"]:gsub("ITL Online", "ITL")..(isDoubles and "  Doubles" or ""))
			eventAf:GetChild("Leaderboard"):visible(false)
			eventAf:GetChild("EX"):visible(true)
			local bodyText = eventAf:GetChild("BodyText")

			-- We don't want text to run out through the bottom.
			-- Incrementally adjust the zoom while adjust wrapwdithpixels until it fits.
			-- Not the prettiest solution but it works.
			for zoomVal=1.0, 0.1, -0.05 do
				bodyText:zoom(zoomVal)
				bodyText:wrapwidthpixels(paneWidth/(zoomVal))
				bodyText:settext(text):visible(true)
				if bodyText:GetHeight() * zoomVal <= paneHeight - RowHeight*1.5 then
					break
				end
			end
			local offset = 0

			while offset <= #text do
				-- Search for all numbers (decimals included).
				-- They may include the +/- prefixes and also potentially %/x as suffixes.
				local i, j = string.find(text, "[-+]?[%d]*%.?[%d]+[%%x]?", offset)
				-- No more numbers found. Break out.
				if i == nil then
					break
				end
				-- Extract the actual numeric text.
				local substring = string.sub(text, i, j)

				-- Numbers should be a pinkish hue by default.
				local clr = ItlPink

				-- Except negatives should be red.
				if substring:sub(1, 1) == "-" then
					clr = Color.Red
				-- And positives should be green.
				elseif substring:sub(1, 1) == "+" then
					clr = Color.Green
				end

				bodyText:AddAttribute(i-1, {
					Length=#substring,
					Diffuse=clr
				})

				offset = j + 1
			end

			offset = 0

			while offset <= #text do
				-- Search for all quoted strings.
				local i, j = string.find(text, "\".-\"", offset)
				-- No more found. Break out.
				if i == nil then
					break
				end
				-- Extract the actual quoted text.
				local substring = string.sub(text, i, j)

				bodyText:AddAttribute(i-1, {
					Length=#substring,
					Diffuse=Color.Green
				})

				offset = j + 1
			end

			-- Colorize the clearType improvements
			offset = 0
			local i, j = string.find(text, "Clear Type: ", offset)
			if i ~= nil then
				offset = j + 1
				local clearTypeMap = {
					["FC"] = SL.JudgmentColors["ITG"][3],
					["FEC"] = SL.JudgmentColors["ITG"][2],
					["FFC"] = SL.JudgmentColors["ITG"][1],
					["FBFC"] = ItlPink,
				}

				local search = "No Play Clear FC FEC FFC FBFC"
				for a=1,2 do
					for ct in search:gmatch("%S+") do 
						i, j = string.find(text, ct, offset)
						if i ~= nil then
							-- Extract the actual clear type.
							local substring = string.sub(text, i, j)
							bodyText:AddAttribute(i-1, {
								Length=#substring,
								Diffuse=(clearTypeMap[substring] and clearTypeMap[substring] or Color.White)
							})
							offset = j + 1
						end
					end
				end
			end

			-- Colorize the grade improvements
			offset = 0
			local i, j = string.find(text, "New ", offset)
			if i ~= nil then
				offset = j + 1
				local gradeMap = {
					["Quad"] = SL.JudgmentColors["ITG"][1],
					["Quint"] = ItlPink,
				}

				local search = "Quad Quint"
				for a=1,2 do
					for grade in search:gmatch("%S+") do 
						i, j = string.find(text, grade, offset)
						if i ~= nil then
							-- Extract the actual clear type.
							local substring = string.sub(text, i, j)
							bodyText:AddAttribute(i-1, {
								Length=#substring,
								Diffuse=(gradeMap[substring] and gradeMap[substring] or Color.White)
							})
							offset = j + 1
						end
					end
				end
			end
		end)
	end

	table.insert(paneFunctions, function(eventAf)
		SetItlStyle(eventAf)
		SetLeaderboardData(eventAf, itlData["itlLeaderboard"], "itl")
		eventAf:GetChild("Header"):settext(itlData["name"]:gsub("ITL Online", "ITL"))
		eventAf:GetChild("Leaderboard"):visible(true)
		eventAf:GetChild("EX"):visible(true)
		eventAf:GetChild("BodyText"):visible(false)
	end)

	return paneFunctions
end

local af = Def.ActorFrame{
	Name="EventOverlay",
	InitCommand=function(self)
		self:visible(false)
	end,
	-- Slightly darken the entire screen
	Def.Quad {
		InitCommand=function(self) self:FullScreen():diffuse(Color.Black):diffusealpha(0.8) end
	},

	-- Press START to dismiss text.
	LoadFont("Common Normal")..{
		Text=THEME:GetString("Common", "PopupDismissText"),
		InitCommand=function(self) self:xy(_screen.cx, _screen.h-50):zoom(1.1) end
	}
}

for player in ivalues(PlayerNumber) do
	af[#af+1] = Def.ActorFrame{
		Name=ToEnumShortString(player).."EventAf",
		InitCommand=function(self)
			self.PaneFunctions = {}
			self:visible(false)
			if GAMESTATE:GetNumSidesJoined() == 1 then
				self:xy(_screen.cx, _screen.cy - 15)
			else
				self:xy(_screen.cx + 160 * (player==PLAYER_1 and -1 or 1), _screen.cy - 15)
			end
		end,
		PlayerJoinedMessageCommand=function(self)
			self:visible(GAMESTATE:IsSideJoined(player))
		end,
		ShowCommand=function(self, params)
			local pn = ToEnumShortString(player)
			self.PaneFunctions = {}

			if params.data["rpg"] then
				local rpgData = params.data["rpg"]
				for func in ivalues(GetRpgPaneFunctions(self, rpgData, player)) do
					self.PaneFunctions[#self.PaneFunctions+1] = func
				end
			end
			
			if params.data["itl"] then
				local itlData = params.data["itl"]
				for func in ivalues(GetItlPaneFunctions(self, itlData, player)) do
					self.PaneFunctions[#self.PaneFunctions+1] = func
				end

				-- If the ITL song was played outside of the pack for the first time,
				-- write the ITL data for it.
				-- All other cases should be handled by normal ItlFile.lua write.
				local song = GAMESTATE:GetCurrentSong()
				local song_dir = song:GetSongDir()
				if SL[pn].ITLData["pathMap"][song_dir] == nil then
					UpdateItlData(player)
				end
			end

			self.PaneIndex = 1
			if #self.PaneFunctions > 0 then
				self.PaneFunctions[self.PaneIndex](self)
				self:visible(true)
			end
		end,
		EventOverlayInputEventMessageCommand=function(self, event)
			if #self.PaneFunctions == 0 then return end

			if event.PlayerNumber == player then
				if event.type == "InputEventType_FirstPress" then
					-- We don't use modulus because #Leaderboards might be zero.
					if event.GameButton == "MenuLeft" then
						self.PaneIndex = self.PaneIndex - 1
						if self.PaneIndex == 0 then
							-- Wrap around if we decremented from 1 to 0.
							self.PaneIndex = #self.PaneFunctions
						end
					elseif event.GameButton == "MenuRight" then
						self.PaneIndex = self.PaneIndex + 1
						if self.PaneIndex > #self.PaneFunctions then
							-- Wrap around if we incremented past #Leaderboards
							self.PaneIndex = 1
						end
					elseif event.GameButton == "Select" then
						MESSAGEMAN:Broadcast("Code", { Name="Screenshot", PlayerNumber=player })
					end

					if event.GameButton == "MenuLeft" or event.GameButton == "MenuRight" then
						self.PaneFunctions[self.PaneIndex](self)
					end
				end
			end
		end,
		-- White border
		Def.Quad {
			Name="MainBorder",
			InitCommand=function(self)
				self:zoomto(paneWidth + borderWidth, paneHeight + borderWidth + 1)
			end
		},

		-- Main Black cement background
		Def.Sprite {
			Name="BackgroundImage",
			Texture=THEME:GetPathG("", "_VisualStyles/SRPG8/Overlay-BG.jpg"),
			InitCommand=function(self)
				self:CropTo(paneWidth, paneHeight)
			end
		},

		-- A quad that goes over the BackgroundImage to try and lighten/darken it however we want.
		Def.Quad {
			Name="BackgroundColor",
			InitCommand=function(self)
				self:zoomto(paneWidth, paneHeight)
			end
		},

		-- Yet another quad that goes over all the background assets.
		Def.Quad {
			Name="BackgroundColor2",
			InitCommand=function(self)
				self:zoomto(paneWidth, paneHeight)
			end
		},
		
		-- Header border
		Def.Quad {
			Name="HeaderBorder",
			InitCommand=function(self)
				self:zoomto(paneWidth + borderWidth, RowHeight + borderWidth + 1):y(-paneHeight/2 + RowHeight/2)
			end
		},

		-- Green Header
		Def.Quad {
			Name="HeaderBackground",
			InitCommand=function(self)
				self:zoomto(paneWidth, RowHeight):y(-paneHeight/2 + RowHeight/2)
			end
		},

		-- Header Text
		LoadFont("Wendy/_wendy small").. {
			Name="Header",
			Text="Stamina RPG",
			InitCommand=function(self)
				self:zoom(0.5)
				self:y(-paneHeight/2 + 12)
			end
		},

		-- EX Score text (if applicable)
		LoadFont("Wendy/_wendy small").. {
			Name="EX",
			Text="EX",
			InitCommand=function(self)
				self:zoom(0.5)
				self:y(-paneHeight/2 + 12)
				self:x(paneWidth/2 - 18)
				self:visible(false)
			end
		},

		-- Main Body Text
		LoadFont("Common Normal").. {
			Name="BodyText",
			Text="",
			InitCommand=function(self)
				self:valign(0)
				self:wrapwidthpixels(paneWidth)
				self:y(-paneHeight/2 + RowHeight * 3/2)
			end,
			ResetCommand=function(self)
				self:zoom(1)
				self:wrapwidthpixels(paneWidth)
				self:setext("")
			end,
		},

		-- This is always visible as we will always have multiple panes for RPG
		Def.ActorFrame{
			Name="PaneIcons",
			InitCommand=function(self)
				self:y(paneHeight/2 - RowHeight/2)
			end,

			LoadFont("Common Normal").. {
				Name="LeftIcon",
				Text="&MENULEFT;",
				InitCommand=function(self)
					self:x(-paneWidth2Player/2 + 10)
				end,
				OnCommand=function(self) self:queuecommand("Bounce") end,
				BounceCommand=function(self)
					self:decelerate(0.5):addx(10):accelerate(0.5):addx(-10)
					self:queuecommand("Bounce")
				end,
			},

			LoadFont("Common Normal").. {
				Name="Text",
				Text="More Information",
				InitCommand=function(self)
					self:addy(-2)
				end,
			},

			LoadFont("Common Normal").. {
				Name="RightIcon",
				Text="&MENURiGHT;",
				InitCommand=function(self)
					self:x(paneWidth2Player/2 - 10)
				end,
				OnCommand=function(self) self:queuecommand("Bounce") end,
				BounceCommand=function(self)
					self:decelerate(0.5):addx(-10):accelerate(0.5):addx(10)
					self:queuecommand("Bounce")
				end,
			},
		}
	}

	local af2 = af[#af]
	-- The Leaderboard for the RPG data. Currently hidden until we want to display it.
	af2[#af2+1] = Def.ActorFrame{
		Name="Leaderboard",
		InitCommand=function(self)
			self:visible(false)
		end,
		-- Highlight backgrounds for the leaderboard.
		Def.Quad {
			Name="Rival1",
			InitCommand=function(self)
				self:diffuse(color("#BD94FF")):zoomto(paneWidth, RowHeight)
			end,
		},

		Def.Quad {
			Name="Rival2",
			InitCommand=function(self)
				self:diffuse(color("#BD94FF")):zoomto(paneWidth, RowHeight)
			end,
		},

		Def.Quad {
			Name="Rival3",
			InitCommand=function(self)
				self:diffuse(color("#BD94FF")):zoomto(paneWidth, RowHeight)
			end,
		},

		Def.Quad {
			Name="Self",
			InitCommand=function(self)
				self:diffuse(color("#A1FF94")):zoomto(paneWidth, RowHeight)
			end,
		},
		BannerAndSong(0, 112, 0.34),
	}

	local af3 = af2[#af2]
	for i=1, NumEntries do
		--- Each entry has a Rank, Name, and Score subactor.
		af3[#af3+1] = Def.ActorFrame{
			Name="LeaderboardEntry"..i,
			InitCommand=function(self)
				self:x(-(paneWidth-paneWidth2Player)/2)
				if NumEntries % 2 == 1 then
					self:y(RowHeight*(i - (NumEntries+1)/2) )
				else
					self:y(RowHeight*(i - NumEntries/2))
				end
			end,

			LoadFont("Common Normal").. {
				Name="Rank",
				Text="",
				InitCommand=function(self)
					self:horizalign(right)
					self:maxwidth(30)
					self:x(-paneWidth2Player/2 + 30 + borderWidth)
				end,
			},

			LoadFont("Common Normal").. {
				Name="Name",
				Text="",
				InitCommand=function(self)
					self:horizalign(center)
					self:maxwidth(130)
					self:x(-paneWidth2Player/2 + 100)
				end,
			},

			LoadFont("Common Normal").. {
				Name="Score",
				Text="",
				InitCommand=function(self)
					self:horizalign(right)
					self:x(paneWidth2Player/2-borderWidth)
				end,
			},

			LoadFont("Common Normal").. {
				Name="Date",
				Text="",
				InitCommand=function(self)
					self:horizalign(right)
					self:x(paneWidth2Player/2 + 100 - borderWidth)
					self:visible(GAMESTATE:GetNumSidesJoined() == 1)
				end,
			},
		}
	end
end

return af
