if not IsServiceAllowed(SL.GrooveStats.AutoSubmit) or GAMESTATE:IsCourseMode() then return end

local NumEntries = 10

local SetEntryText = function(rank, name, score, date, actor)
	if actor == nil then return end

	actor:GetChild("Rank"):settext(rank)
	actor:GetChild("Name"):settext(name)
	actor:GetChild("Score"):settext(score)
	actor:GetChild("Date"):settext(date)
end

local GetMachineTag = function(gsEntry)
	if not gsEntry then return end	
	-- Groovestats username.
	if gsEntry["name"] then
		-- 4 Characters is the "intended" length.
		return gsEntry["name"]
	end

	if gsEntry["machineTag"] then
		-- User doesn't have a username (?).
		return gsEntry["machineTag"]:sub(1, 4):upper()
	end

	return ""
end

local GetJudgmentCounts = function(player)
	local counts = GetExJudgmentCounts(player)
	local translation = {
		["W0"] = "fantasticPlus",
		["W1"] = "fantastic",
		["W2"] = "excellent",
		["W3"] = "great",
		["W4"] = "decent",
		["W5"] = "wayOff",
		["Miss"] = "miss",
		["totalSteps"] = "totalSteps",
		["Holds"] = "holdsHeld",
		["totalHolds"] = "totalHolds",
		["Mines"] = "minesHit",
		["totalMines"] = "totalMines",
		["Rolls"] = "rollsHeld",
		["totalRolls"] = "totalRolls"
	}

	local judgmentCounts = {}

	for key, value in pairs(counts) do
		if translation[key] ~= nil then
			judgmentCounts[translation[key]] = value
		end
	end

	return judgmentCounts
end

local GetRescoredJudgmentCounts = function(player)
	local pn = ToEnumShortString(player)

	local translation = {
		["W0"] = "fantasticPlus",
		["W1"] = "fantastic",
		["W2"] = "excellent",
		["W3"] = "great",
		["W4"] = "decent",
		["W5"] = "wayOff",
	}

	local rescored = {
		["fantasticPlus"] = 0,
		["fantastic"] = 0,
		["excellent"] = 0,
		["great"] = 0,
		["decent"] = 0,
		["wayOff"] = 0
	}
	
	for i=1,GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() do
		for window, name in pairs(translation) do
			rescored[name] = rescored[name] + SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].column_judgments[i]["Early"][window]
		end
	end

	return rescored
end

local AttemptDownloads = function(res)
	local data = JsonDecode(res.body)
	for i=1,2 do
		local playerStr = "player"..i
		local events = {"rpg", "itl"}

		for event in ivalues(events) do
			if data and data[playerStr] and data[playerStr][event] then
				local eventData = data[playerStr][event]
				local eventName = eventData["name"] or "Unknown Event"
			
				-- See if any quests were completed.
				if eventData["progress"] and eventData["progress"]["questsCompleted"] then
					local quests = eventData["progress"]["questsCompleted"]
					-- Iterate through the quests...
					for quest in ivalues(quests) do
						-- ...and check for any unlocks.
						if quest["songDownloadUrl"] then
							local url = quest["songDownloadUrl"]
							local title = quest["title"] or ""

							if ThemePrefs.Get("SeparateUnlocksByPlayer") then
								local profileName = "NoName"
								local player = "PlayerNumber_P"..i
								if (PROFILEMAN:IsPersistentProfile(player) and
										PROFILEMAN:GetProfile(player)) then
									profileName = PROFILEMAN:GetProfile(player):GetDisplayName()
								end
								title = title.." - "..profileName
								DownloadEventUnlock(url, "["..eventName.."] "..title, eventName.." Unlocks - "..profileName)
							else
								DownloadEventUnlock(url, "["..eventName.."] "..title, eventName.." Unlocks")
							end
						end
					end
				end
			end
		end
	end
end

local AutoSubmitRequestProcessor = function(res, overlay)
	local P1SubmitText = overlay:GetChild("AutoSubmitMaster"):GetChild("P1SubmitText")
	local P2SubmitText = overlay:GetChild("AutoSubmitMaster"):GetChild("P2SubmitText")

	if res.error or res.statusCode ~= 200 then
		local error = res.error and ToEnumShortString(res.error) or nil
		if error == "Timeout" then
			if P1SubmitText then P1SubmitText:queuecommand("TimedOut") end
			if P2SubmitText then P2SubmitText:queuecommand("TimedOut") end
		elseif error or (res.statusCode ~= nil and res.statusCode ~= 200) then
			if P1SubmitText then P1SubmitText:queuecommand("SubmitFailed") end
			if P2SubmitText then P2SubmitText:queuecommand("SubmitFailed") end
		end
		return
	end

	local panes = overlay:GetChild("Panes")
	local shouldDisplayOverlay = false

	-- Hijack the leaderboard pane to display the GrooveStats leaderboards.
	if panes then
		local data = JsonDecode(res.body)
		local headers = res.headers
		for i=1,2 do
			local playerStr = "player"..i
			local entryNum = 1
			local rivalNum = 1
			-- Pane 8 is the groovestats highscores pane.
			local highScorePane = panes:GetChild("Pane8_SideP"..i):GetChild("")
			local QRPane = panes:GetChild("Pane7_SideP"..i):GetChild("")

			local RPGPane = panes:GetChild("Pane9_SideP"..i):GetChild("")
			local ITLPane = panes:GetChild("Pane10_SideP"..i):GetChild("")

			local boogie = false
			local boogie_ex = false
			if headers["bs-leaderboard-player-" .. i] == "BS" then
				boogie = true
				MESSAGEMAN:Broadcast("BoogieLogo",{ player = i })
			elseif headers["bs-leaderboard-player-" .. i] == "BS-EX" then
				boogie_ex = true
				MESSAGEMAN:Broadcast("BoogieEXLogo",{ player = i })
			end
		
			-- If only one player is joined, we then need to update both panes with only
			-- one players' data.
			local side = i
			if data and GAMESTATE:GetNumSidesJoined() == 1 then
				if data["player1"] then
					side = 1
				else
					side = 2
				end
				playerStr = "player"..side
			end

			if data and data[playerStr] then
				-- And then also ensure that the chart hash matches the currently parsed one.
				-- It's better to just not display anything than display the wrong scores.
				if SL["P"..side].Streams.Hash == data[playerStr]["chartHash"] then
					local personalRank = nil
					local showExScore = SL["P"..side].ActiveModifiers.ShowEXScore and data[playerStr]["exLeaderboard"]

					local leaderboardData = nil
					if showExScore then
						leaderboardData = data[playerStr]["exLeaderboard"]
					elseif data[playerStr]["gsLeaderboard"] then
						leaderboardData = data[playerStr]["gsLeaderboard"]
					end

					if leaderboardData then
						for gsEntry in ivalues(leaderboardData) do
							local entry = highScorePane:GetChild("HighScoreList"):GetChild("HighScoreEntry"..entryNum)
							entry:stoptweening()
							entry:diffuse(Color.White)
							SetEntryText(
								gsEntry["rank"]..".",
								GetMachineTag(gsEntry),
								string.format("%.2f%%", gsEntry["score"]/100),
								ParseGroovestatsDate(gsEntry["date"]),
								entry
							)

							-- TODO(teejusb): Determine how we want to easily display EX scores.
							-- For now just highlight blue because it's simple.
							if showExScore then
								entry:GetChild("Score"):diffuse(SL.JudgmentColors["FA+"][1])
							else
								entry:GetChild("Score"):diffuse(Color.White)
							end

							if gsEntry["isRival"] then
								entry:diffuse(color("#BD94FF"))
								rivalNum = rivalNum + 1
							elseif gsEntry["isSelf"] then
								entry:diffuse(color("#A1FF94"))
								personalRank = gsEntry["rank"]
							end

							if gsEntry["isFail"] then
								entry:GetChild("Score"):diffuse(Color.Red)
							end
							entryNum = entryNum + 1
						end

						QRPane:GetChild("QRCode"):queuecommand("Hide")
						QRPane:GetChild("HelpText"):settext("Score has already been submitted :)")
						if i == 1 and P1SubmitText then
							P1SubmitText:queuecommand("Submit")
						elseif i == 2 and P2SubmitText then
							P2SubmitText:queuecommand("Submit")
						end
					end

					if data[playerStr]["rpg"] then
						local rpgEntry = 1
						local rpgRival = 1
						for gsEntry in ivalues(data[playerStr]["rpg"]["rpgLeaderboard"]) do
							local entry = RPGPane:GetChild("HighScoreList"):GetChild("HighScoreEntry"..rpgEntry)
							entry:stoptweening()
							entry:diffuse(Color.White)
							SetEntryText(
								gsEntry["rank"]..".",
								GetMachineTag(gsEntry),
								string.format("%.2f%%", gsEntry["score"]/100),
								ParseGroovestatsDate(gsEntry["date"]),
								entry
							)
							if gsEntry["isRival"] then
								entry:diffuse(color("#BD94FF"))
								rpgRival = rpgRival + 1
							elseif gsEntry["isSelf"] then
								entry:diffuse(color("#A1FF94"))
								-- personalRank = gsEntry["rank"]
							end

							if gsEntry["isFail"] then
								entry:GetChild("Score"):diffuse(Color.Red)
							end
							rpgEntry = rpgEntry + 1
						end
					end

					if data[playerStr]["itl"] then
						local itlEntry = 1
						local itlRival = 1
						for gsEntry in ivalues(data[playerStr]["itl"]["itlLeaderboard"]) do
							local entry = ITLPane:GetChild("HighScoreList"):GetChild("HighScoreEntry"..itlEntry)
							entry:stoptweening()
							entry:diffuse(Color.White)
							SetEntryText(
								gsEntry["rank"]..".",
								GetMachineTag(gsEntry),
								string.format("%.2f%%", gsEntry["score"]/100),
								ParseGroovestatsDate(gsEntry["date"]),
								entry
							)
							if gsEntry["isRival"] then
								entry:diffuse(color("#BD94FF"))
								itlRival = itlRival + 1
							elseif gsEntry["isSelf"] then
								entry:diffuse(color("#A1FF94"))
								-- personalRank = gsEntry["rank"]
							end

							if gsEntry["isFail"] then
								entry:GetChild("Score"):diffuse(Color.Red)
							end
							itlEntry = itlEntry + 1
						end
					end

					-- Only display the overlay on the sides that are actually joined.
					if ToEnumShortString("PLAYER_P"..i) == "P"..side and (data[playerStr]["rpg"] or data[playerStr]["itl"]) then
						local eventAf = overlay:GetChild("AutoSubmitMaster"):GetChild("EventOverlay"):GetChild("P"..i.."EventAf")
						eventAf:playcommand("Show", {data=data[playerStr]})
						shouldDisplayOverlay = true
					end

					-- Only update PB/WR messages on the side that is joined
					if ToEnumShortString("PLAYER_P"..i) == "P"..side then
						local upperPane = overlay:GetChild("P"..side.."_AF_Upper")
						if upperPane then
							if data[playerStr]["result"] == "score-added" or data[playerStr]["result"] == "improved" then
								local recordText = overlay:GetChild("AutoSubmitMaster"):GetChild("P"..side.."RecordText")
								local GSIcon = overlay:GetChild("AutoSubmitMaster"):GetChild("P"..side.."GrooveStats_Logo")
								local BSIcon = overlay:GetChild("AutoSubmitMaster"):GetChild("P"..side.."BoogieStats_Logo")
								local BSEXIcon = overlay:GetChild("AutoSubmitMaster"):GetChild("P"..side.."BoogieStatsEX_Logo")

								recordText:visible(true)

								if boogie then BSIcon:visible(true)
								elseif boogie_ex then BSEXIcon:visible(true)
								else GSIcon:visible(true) end

								recordText:diffuseshift():effectcolor1(Color.White):effectcolor2(Color.Yellow):effectperiod(3)
								local soundDir = THEME:GetCurrentThemeDirectory() .. "Sounds/"
								if personalRank == 1 then
									local worldRecordText = "World Record!"
									if showExScore then
										worldRecordText = worldRecordText .. " (EX)"
									end
									recordText:settext(worldRecordText)
									-- Play random sound in Sounds/Evaluation WR/
									soundDir = soundDir .. "Evaluation WR/"
									audio_files = findFiles(soundDir)
									if #audio_files > 0 then
										SOUND:PlayOnce(audio_files[math.random(#audio_files)])
									end
								else
									recordText:settext("Personal Best!")
									-- Play random sound in Sounds/Evaluation PB/
									soundDir = soundDir .. "Evaluation PB/"
									audio_files = findFiles(soundDir)
									if #audio_files > 0 then
										SOUND:PlayOnce(audio_files[math.random(#audio_files)])
									end
								end
								local recordTextXStart = recordText:GetX() - recordText:GetWidth()*recordText:GetZoom()/2
								local GSIconWidth = GSIcon:GetWidth()*GSIcon:GetZoom()
								local BSIconWidth = BSIcon:GetWidth()*BSIcon:GetZoom()
								local BSEXIconWidth = BSEXIcon:GetWidth()*BSEXIcon:GetZoom()
								-- This will automatically adjust based on the length of the recordText length.
								GSIcon:xy(recordTextXStart - GSIconWidth/2, recordText:GetY())
								BSIcon:xy(recordTextXStart - BSIconWidth/2, recordText:GetY())
								BSEXIcon:xy(recordTextXStart - BSEXIconWidth/2, recordText:GetY())
							end
						end
					end
				end
			end

			-- Empty out any remaining entries on a successful response.
			-- For failed responses we fallback to the scores available in the machine.
			if res["status"] == "success" then
				for j=entryNum, NumEntries do
					local entry = highScorePane:GetChild("HighScoreList"):GetChild("HighScoreEntry"..j)
					entry:stoptweening()
					-- We didn't get any scores if i is still == 1.
					if j == 1 then
						SetEntryText("", "No Scores", "", "", entry)
					else
						-- Empty out the remaining rows.
						SetEntryText("---", "----", "------", "----------", entry)
					end
				end
			end
		end
	end

	if shouldDisplayOverlay then
		overlay:GetChild("AutoSubmitMaster"):GetChild("EventOverlay"):visible(true)
		overlay:queuecommand("DirectInputToEventOverlayHandler")
	end

	if ThemePrefs.Get("AutoDownloadUnlocks") then
		-- This will only download if the expected data exists.
		AttemptDownloads(res)
	end
end

local af = Def.ActorFrame {
	Name="AutoSubmitMaster",
	RequestResponseActor(17, 50)..{
		OnCommand=function(self)
			local sendRequest = false
			local headers = {}
			local query = {
				maxLeaderboardResults=NumEntries,
			}
			local body = {}

			local rate = SL.Global.ActiveModifiers.MusicRate * 100
			for i=1,2 do
				local player = "PlayerNumber_P"..i
				local pn = ToEnumShortString(player)

				if GAMESTATE:IsHumanPlayer(player) and GAMESTATE:IsSideJoined(player) then
					local _, valid = ValidForGrooveStats(player)
					local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
					local submitForPlayer = false

					if valid and not stats:GetFailed() and SL[pn].IsPadPlayer then
						local percentDP = stats:GetPercentDancePoints()
						local score = tonumber(("%.0f"):format(percentDP * 10000))

						local profileName = ""
						if PROFILEMAN:IsPersistentProfile(player) and PROFILEMAN:GetProfile(player) then
							profileName = PROFILEMAN:GetProfile(player):GetDisplayName()
						end

						if SL[pn].ApiKey ~= "" and SL[pn].Streams.Hash ~= "" then
							query["chartHashP"..i] = SL[pn].Streams.Hash
							headers["x-api-key-player-"..i] = SL[pn].ApiKey

							body["player"..i] = {
								rate=rate,
								score=score,
								judgmentCounts=GetJudgmentCounts(player),
								rescoreCounts=GetRescoredJudgmentCounts(player),
								usedCmod=(GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):CMod() ~= nil),
								comment=CreateCommentString(player),
							}
							sendRequest = true
							submitForPlayer = true
						end
					end

					if not submitForPlayer then
						-- Hide the submit text if we're not submitting a score for a player.
						-- For example in versus, if one player fails and the other passes, we
						-- want to show that the first player score won't be submitted.
						local submitText = self:GetParent():GetChild("P"..i.."SubmitText")
						submitText:visible(false)
					end
				end
			end
			-- Only send the request if it's applicable.
			if sendRequest then
				-- Unjoined players won't have the text displayed.
				self:GetParent():GetChild("P1SubmitText"):settext("Submitting ...")
				self:GetParent():GetChild("P2SubmitText"):settext("Submitting ...")

				self:playcommand("MakeGrooveStatsRequest", {
					endpoint="score-submit.php?"..NETWORK:EncodeQueryParameters(query),
					method="POST",
					headers=headers,
					body=JsonEncode(body),
					timeout=30,
					callback=AutoSubmitRequestProcessor,
					args=SCREENMAN:GetTopScreen():GetChild("Overlay"):GetChild("ScreenEval Common"),
				})
			end
		end
	}
}

local textColor = Color.White
local shadowLength = 0
if ThemePrefs.Get("RainbowMode") then
	textColor = Color.Black
end

af[#af+1] = LoadFont("Common Normal").. {
	Name="P1SubmitText",
	Text="",
	InitCommand=function(self)
		self:xy(_screen.w * 0.25, _screen.h - 15)
		self:diffuse(textColor)
		self:shadowlength(shadowLength)
		self:zoom(0.8)
		self:visible(GAMESTATE:IsSideJoined(PLAYER_1))
	end,
	SubmitCommand=function(self)
		self:settext("Submitted!")
	end,
	SubmitFailedCommand=function(self)
		self:settext("Submit Failed 😞")
		DiffuseEmojis(self)
	end,
	TimedOutCommand=function(self)
		self:settext("Timed Out")
	end
}

af[#af+1] = LoadFont("Common Normal").. {
	Name="P2SubmitText",
	Text="",
	InitCommand=function(self)
		self:xy(_screen.w * 0.75, _screen.h - 15)
		self:diffuse(textColor)
		self:shadowlength(shadowLength)
		self:zoom(0.8)
		self:visible(GAMESTATE:IsSideJoined(PLAYER_2))
	end,
	SubmitCommand=function(self)
		self:settext("Submitted!")
	end,
	SubmitFailedCommand=function(self)
		self:settext("Submit Failed 😞")
		DiffuseEmojis(self)
	end,
	TimedOutCommand=function(self)
		self:settext("Timed Out")
	end
}

af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathG("","GrooveStats.png"),
	Name="P1GrooveStats_Logo",
	InitCommand=function(self)
		self:zoom(0.2)
		self:visible(false)
	end,
}

af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathG("","BoogieStats.png"),
	Name="P1BoogieStats_Logo",
	InitCommand=function(self)
		self:zoom(0.2)
		self:visible(false)
	end,
}

af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathG("","BoogieStatsEX.png"),
	Name="P1BoogieStatsEX_Logo",
	InitCommand=function(self)
		self:zoom(0.2)
		self:visible(false)
	end,
}

af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
	Name="P1RecordText",
	InitCommand=function(self)
		local x = _screen.cx - 225
		self:zoom(0.225)
		self:xy(x,40)
		self:visible(false)
	end,
}

af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathG("","GrooveStats.png"),
	Name="P2GrooveStats_Logo",
	InitCommand=function(self)
		self:zoom(0.2)
		self:visible(false)
	end,
}

af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathG("","BoogieStats.png"),
	Name="P2BoogieStats_Logo",
	InitCommand=function(self)
		self:zoom(0.2)
		self:visible(false)
	end,
}

af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathG("","BoogieStatsEX.png"),
	Name="P2BoogieStatsEX_Logo",
	InitCommand=function(self)
		self:zoom(0.2)
		self:visible(false)
	end,
}

af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
	Name="P2RecordText",
	InitCommand=function(self)
		local x = _screen.cx + 225
		self:zoom(0.225)
		self:xy(x,40)
		self:visible(false)
	end,
}

af[#af+1] = LoadActor("./EventOverlay.lua")

return af
