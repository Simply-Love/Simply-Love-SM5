if not IsServiceAllowed(SL.GrooveStats.AutoSubmit) then return end

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
	if gsEntry["machineTag"] then
		-- Make sure we only use up to 4 characters for space concerns.
		return gsEntry["machineTag"]:sub(1, 4):upper()
	end

	-- User doesn't have a machineTag set. We'll "make" one based off of
	-- their name.
	if gsEntry["name"] then
		-- 4 Characters is the "intended" length.
		return gsEntry["name"]:sub(1,4):upper()
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

local AttemptDownloads = function(res)
	-- Keep track of all downloads.
	--
	-- Each entry is keyed on the download URL.
	-- The title is the name of the completed quest.
	-- The players table contains the name of the players who completed the quest.
	--
	-- This structure looks like:
	-- allDownloads = {
	--   ["url"] = {
	--     ["title"] = "quest name",
	--     ["players"] = { "list", "of", "profile_names" }
	--   }
	-- }
	local allDownloads = {}
	local entries = 0
	local eventName = ""
	for i=1,2 do
		local playerStr = "player"..i
		if data and data[playerStr] and data[playerStr]["rpg"] then
			local rpgData = data[playerStr]["rpg"]
			-- We expect the eventName to be the same across both players so we just
			-- set this once.
			if #eventName == 0 and rpgData["name"] then
				eventName = rpgData["name"]
			end
		
			-- See if any quests were completed.
			if rpgData["progress"] and rpgData["progress"]["questsCompleted"] then
				local quests = rpgData["progress"]["questsCompleted"]
				-- Iterate through the quests...
				for quest in ivalues(quests) do
					-- ...and check for any unlocks.
					if quest["songDownloadUrl"] then
						local url = quest["songDownloadUrl"]
						local title = quest["title"] and quest["title"] or ""

						-- Set up the unlock data.
						if allDownloads[url] == nil then
							allDownloads[url] = {
								title=title,
								players={}
							}
							entries = entries + 1
						end

						-- Keep track of profileName since we'll need it to separate unlocks
						-- by player.
						local profileName = ""
						local player = "PlayerNumber_P"..i
						if (PROFILEMAN:IsPersistentProfile(player) and
								PROFILEMAN:GetProfile(player)) then
							profileName = PROFILEMAN:GetProfile(player):GetDisplayName()
						end

						local players = allDownloads[url].players
						players[#players+1] = profileName
					end
				end
			end
		end
	end

	-- We can't use the # operator since allDownloads doesn't have integer keys.
	if entries == 0 then return end
  -- Make sure we have an eventName set since the song pack name depends on it.
	if #eventName == 0 then return end

	-- DOWNLOAD ALL THE THINGS!
	for url, data in pairs(allDownloads) do
		-- TODO(teejusb): Separate unlocks by player once we've set up the option.
		DownloadSRPGUnlock(url, data.title, eventName)
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
		for i=1,2 do
			local playerStr = "player"..i
			local entryNum = 1
			local rivalNum = 1
			local data = JsonDecode(res.body)
			-- Pane 8 is the groovestats highscores pane.
			local highScorePane = panes:GetChild("Pane8_SideP"..i):GetChild("")
			local QRPane = panes:GetChild("Pane7_SideP"..i):GetChild("")

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
					if not data[playerStr]["isRanked"] then
						QRPane:GetChild("QRCode"):queuecommand("Hide")
						QRPane:GetChild("HelpText"):settext("This chart is not ranked on GrooveStats.")
						if i == 1 and P1SubmitText then
							P1SubmitText:queuecommand("ChartNotRanked")
						elseif i == 2 and P2SubmitText then
							P2SubmitText:queuecommand("ChartNotRanked")
						end
					elseif data[playerStr]["gsLeaderboard"] then
						for gsEntry in ivalues(data[playerStr]["gsLeaderboard"]) do
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

					-- Only display the overlay on the sides that are actually joined.
					if ToEnumShortString("PLAYER_P"..i) == "P"..side and (data[playerStr]["rpg"] or data[playerStr]["itl"]) then
						local eventAf = overlay:GetChild("AutoSubmitMaster"):GetChild("EventOverlay"):GetChild("P"..i.."EventAf")
						eventAf:playcommand("Show", {data=data[playerStr]})
						shouldDisplayOverlay = true
					end

					local upperPane = overlay:GetChild("P"..side.."_AF_Upper")
					if upperPane then
						if data[playerStr]["result"] == "score-added" or data[playerStr]["result"] == "improved" then
							local recordText = overlay:GetChild("AutoSubmitMaster"):GetChild("P"..side.."RecordText")
							local GSIcon = overlay:GetChild("AutoSubmitMaster"):GetChild("P"..side.."GrooveStats_Logo")

							recordText:visible(true)
							GSIcon:visible(true)
							recordText:diffuseshift():effectcolor1(Color.White):effectcolor2(Color.Yellow):effectperiod(3)
							if personalRank == 1 then
								recordText:settext("World Record!")
							else
								recordText:settext("Personal Best!")
							end
							local recordTextXStart = recordText:GetX() - recordText:GetWidth()*recordText:GetZoom()/2
							local GSIconWidth = GSIcon:GetWidth()*GSIcon:GetZoom()
							-- This will automatically adjust based on the length of the recordText length.
							GSIcon:xy(recordTextXStart - GSIconWidth/2, recordText:GetY())
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
						if data and data[playerStr] then
							if data[playerStr]["isRanked"] then
								SetEntryText("", "No Scores", "", "", entry)
							else
								SetEntryText("", "Chart Not Ranked", "", "", entry)
							end
						else
							SetEntryText("", "No Scores", "", "", entry)
						end
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

	-- This will only download if the expected data exists.
	AttemptDownloads(res)
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
	ChartNotRankedCommand=function(self)
		self:settext("Chart Not Ranked")
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
	ChartNotRankedCommand=function(self)
		self:settext("Chart Not Ranked")
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

af[#af+1] = LoadFont("Common Bold")..{
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

af[#af+1] = LoadFont("Common Bold")..{
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
