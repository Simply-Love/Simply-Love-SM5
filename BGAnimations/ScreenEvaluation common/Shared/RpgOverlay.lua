local NumEntries = 13
local RowHeight = 24
local RpgYellow = color("0.902,0.765,0.529,1")

local paneWidth1Player = 330
local paneWidth2Player = 230
local paneWidth = (GAMESTATE:GetNumSidesJoined() == 1) and paneWidth1Player or paneWidth2Player
local paneHeight = 360
local borderWidth = 2


local SetEntryText = function(rank, name, score, date, actor)
	if actor == nil then return end

	actor:GetChild("Rank"):settext(rank)
	actor:GetChild("Name"):settext(name)
	actor:GetChild("Score"):settext(score)
	actor:GetChild("Date"):settext(date)
end

local SetLeaderboardData = function(rpgAf, rpgData)
	local entryNum = 1
	local rivalNum = 1
	local leaderboard = rpgAf:GetChild("Leaderboard")

	-- Hide the rival and self highlights.
	-- They will be unhidden and repositioned as needed below.
	for i=1,3 do
		leaderboard:GetChild("Rival"..i):visible(false)
	end
	leaderboard:GetChild("Self"):visible(false)

	for gsEntry in ivalues(rpgData["rpgLeaderboard"]) do
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
			entry:diffuse(Color.White)
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

local GetPaneFunctions = function(rpgAf, rpgData, player)
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
		"%.2f%% (%s%.2f%%) at\n"..
		"%.2fx (%s%.2fx) rate\n\n"..
		"%s"..
		"%s",
		score, scoreDelta < 0 and "-" or "+", scoreDelta,
		rate, rateDelta < 0 and "-" or "+", rateDelta,
		#statImprovements == 0 and "" or table.concat(statImprovements, "\n").."\n\n",
		#skillImprovements == 0 and "" or table.concat(skillImprovements, "\n").."\n\n"
	))

	for quest in ivalues(quests) do
		table.insert(paneTexts, quest)
	end

	for text in ivalues(paneTexts) do
		table.insert(paneFunctions, function(rpgAf)
			rpgAf:GetChild("Leaderboard"):visible(false)
			local bodyText = rpgAf:GetChild("BodyText")

			-- We don't want text to run out through the bottom.
			-- Incrementally adjust the zoom while adjust wrapwdithpixels until it fits.
			-- Not the prettiest solution but it works.
			for zoomVal=1.0, 0.1, -0.05 do
				bodyText:zoom(zoomVal)
				bodyText:wrapwidthpixels(paneWidth/(zoomVal))
				bodyText:settext(text):visible(true)
				Trace(bodyText:GetHeight() * zoomVal)
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

				-- Numbers should be a blueish hue by default.
				local clr = color("0,1,1,1")

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

	table.insert(paneFunctions, function(rpgAf)
		rpgAf:GetChild("Leaderboard"):visible(true)
		rpgAf:GetChild("BodyText"):visible(false)
	end)

	return paneFunctions
end

local af = Def.ActorFrame{
	Name="RpgOverlay",
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
		Name=ToEnumShortString(player).."RpgAf",
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
			self:GetChild("Header"):settext(params.data["name"])
			SetLeaderboardData(self, params.data)
			self.PaneFunctions = GetPaneFunctions(self, params.data, player)
			self.PaneIndex = 1
			if #self.PaneFunctions > 0 then
				self.PaneFunctions[self.PaneIndex](self)
				self:visible(true)
			end
		end,
		RpgInputEventMessageCommand=function(self, event)
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
					end

					if event.GameButton == "MenuLeft" or event.GameButton == "MenuRight" then
						self.PaneFunctions[self.PaneIndex](self)
					end
				end
			end
		end,
		-- White border
		Def.Quad {
			InitCommand=function(self)
				self:diffuse(RpgYellow):zoomto(paneWidth + borderWidth, paneHeight + borderWidth + 1)
			end
		},

		-- Main Black cement background
		Def.Sprite {
			Texture=THEME:GetPathG("", "_VisualStyles/SRPG5/Overlay-BG.png"),
			InitCommand=function(self)
				self:CropTo(paneWidth, paneHeight)
			end
		},

		-- A quad that goes over the black cement background to try and lighten/darken it however we want.
		Def.Quad {
			InitCommand=function(self)
				self:diffuse(color("0,0,0,0.3")):zoomto(paneWidth, paneHeight)
			end
		},

		-- Header border
		Def.Quad {
			InitCommand=function(self)
				self:diffuse(RpgYellow):zoomto(paneWidth + borderWidth, RowHeight + borderWidth + 1):y(-paneHeight/2 + RowHeight/2)
			end
		},

		-- Green Header
		Def.Quad {
			InitCommand=function(self)
				self:diffusetopedge(color("0.275,0.510,0.298,1")):diffusebottomedge(color("0.235,0.345,0.184,1"))
					:zoomto(paneWidth, RowHeight):y(-paneHeight/2 + RowHeight/2)
			end
		},

		-- Header Text
		LoadFont("Wendy/_wendy small").. {
			Name="Header",
			Text="Stamina RPG",
			InitCommand=function(self)
				self:zoom(0.5)
				self:diffuse(RpgYellow)
				self:y(-paneHeight/2 + 12)
			end
		},

		-- Main Body Text
		LoadFont("Common Normal").. {
			Name="BodyText",
			Text="",
			InitCommand=function(self)
				self:valign(0)
				self:diffuse(Color.White)
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
					self:diffuse(RpgYellow)
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
	}

	local af3 = af2[#af2]
	for i=1, NumEntries do
		--- Each entry has a Rank, Name, and Score subactor.
		af3[#af3+1] = Def.ActorFrame{
			Name="LeaderboardEntry"..i,
			InitCommand=function(self)
				self:diffuse(Color.White)
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
					self:diffuse(Color.White)
					self:horizalign(right)
					self:maxwidth(30)
					self:x(-paneWidth2Player/2 + 30 + borderWidth)
				end,
			},

			LoadFont("Common Normal").. {
				Name="Name",
				Text="",
				InitCommand=function(self)
					self:diffuse(Color.White)
					self:horizalign(center)
					self:maxwidth(130)
					self:x(-paneWidth2Player/2 + 100)
				end,
			},

			LoadFont("Common Normal").. {
				Name="Score",
				Text="",
				InitCommand=function(self)
					self:diffuse(Color.White)
					self:horizalign(right)
					self:x(paneWidth2Player/2-borderWidth)
				end,
			},

			LoadFont("Common Normal").. {
				Name="Date",
				Text="",
				InitCommand=function(self)
					self:diffuse(Color.White)
					self:horizalign(right)
					self:x(paneWidth2Player/2 + 100 - borderWidth)
					self:visible(GAMESTATE:GetNumSidesJoined() == 1)
				end,
			},
		}
	end
end

return af
