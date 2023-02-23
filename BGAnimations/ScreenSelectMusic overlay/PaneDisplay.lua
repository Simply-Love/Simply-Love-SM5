-- get the machine_profile now at file init; no need to keep fetching with each SetCommand
local machine_profile = PROFILEMAN:GetMachineProfile()

-- the height of the footer is defined in ./Graphics/_footer.lua, but we'll
-- use it here when calculating where to position the PaneDisplay
local footer_height = 32

-- height of the PaneDisplay in pixels
local pane_height = 60

local text_zoom = WideScale(0.8, 0.9)

-- -----------------------------------------------------------------------
-- Convenience function to return the SongOrCourse and StepsOrTrail for a
-- for a player.
local GetSongAndSteps = function(player)
	local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
	local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	return SongOrCourse, StepsOrTrail
end

-- -----------------------------------------------------------------------
local GetScoreFromProfile = function(profile, SongOrCourse, StepsOrTrail)
	-- if we don't have everything we need, return nil
	if not (profile and SongOrCourse and StepsOrTrail) then return nil end

	return profile:GetHighScoreList(SongOrCourse, StepsOrTrail):GetHighScores()[1]
end

local GetScoreForPlayer = function(player)
	local highScore
	if PROFILEMAN:IsPersistentProfile(player) then
		local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
		highScore = GetScoreFromProfile(PROFILEMAN:GetProfile(player), SongOrCourse, StepsOrTrail)
	end
	return highScore
end

-- -----------------------------------------------------------------------
local SetNameAndScore = function(name, score, nameActor, scoreActor, textColor)
	if not scoreActor or not nameActor then return end
	scoreActor:settext(score):diffuse(color(textColor))
	nameActor:settext(name):diffuse(color(textColor))
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

local GetScoresRequestProcessor = function(res, params)
	local master = params.master
	if master == nil then return end
	-- If we're not hovering over a song when we get the request, then we don't
	-- have to update anything. We don't have to worry about courses here since
	-- we don't run the RequestResponseActor in CourseMode.
	if GAMESTATE:GetCurrentSong() == nil then return end
	
	local data = res.statusCode == 200 and JsonDecode(res.body) or nil
	local requestCacheKey = params.requestCacheKey
	-- If we have data, and the requestCacheKey is not in the cache, cache it.
	if data ~= nil and SL.GrooveStats.RequestCache[requestCacheKey] == nil then
		SL.GrooveStats.RequestCache[requestCacheKey] = {
			Response=res,
			Timestamp=GetTimeSinceStart()
		}
	end

	for i=1,2 do
		local paneDisplay = master:GetChild("PaneDisplayP"..i)
		local machineScore = paneDisplay:GetChild("MachineHighScore")
		local machineName = paneDisplay:GetChild("MachineHighScoreName")

		local playerScore = paneDisplay:GetChild("PlayerHighScore")
		local playerName = paneDisplay:GetChild("PlayerHighScoreName")

		local loadingText = paneDisplay:GetChild("Loading")

		local playerStr = "player"..i
		local rivalNum = 1
		local worldRecordSet = false
		local personalRecordSet = false
		
		local itlScore = nil
		local isItlSong = false
		
		if data and data[playerStr] and data[playerStr]["itl"] and data[playerStr]["itl"]["itlLeaderboard"] then
		-- And then also ensure that the chart hash matches the currently parsed one.
			-- It's better to just not display anything than display the wrong scores.
			if SL["P"..i].Streams.Hash == data[playerStr]["chartHash"] then
				isItlSong = true
				for gsEntry in ivalues(data[playerStr]["itl"]["itlLeaderboard"]) do
					if gsEntry["isSelf"] then
						-- GS's score entry is a value like 9823, so we need to divide it by 100 to get 98.23
						itlScore = string.format("%.2f%%", gsEntry["score"]/100)
						itlRaw = gsEntry["score"]/100
					end
				end
			end
		end

		-- First check to see if the leaderboard even exists.
		if data and data[playerStr] and data[playerStr]["gsLeaderboard"] then
			-- And then also ensure that the chart hash matches the currently parsed one.
			-- It's better to just not display anything than display the wrong scores.
			if SL["P"..i].Streams.Hash == data[playerStr]["chartHash"] then
				for gsEntry in ivalues(data[playerStr]["gsLeaderboard"]) do
					if gsEntry["rank"] == 1 then
						SetNameAndScore(
							GetMachineTag(gsEntry),
							string.format("%.2f%%", gsEntry["score"]/100),
							machineName,
							machineScore,
							"#000000"
						)
						worldRecordSet = true
					end

					if gsEntry["isSelf"] then
						-- Let's check if the GS high score is higher than the local high score
						local player = PlayerNumber[i]
						local localScore = GetScoreForPlayer(player)
						-- GS's score entry is a value like 9823, so we need to divide it by 100 to get 98.23
						local gsScore = gsEntry["score"] / 100

						-- GetPercentDP() returns a value like 0.9823, so we need to multiply it by 100 to get 98.23
						if not localScore or gsScore >= localScore:GetPercentDP() * 100 then
							-- It is! Let's use it instead of the local one.
							SetNameAndScore(
								GetMachineTag(gsEntry),
								string.format("%.2f%%", gsScore),
								playerName,
								playerScore,
								"#000000"
							)
							personalRecordSet = true
						end
					end

					if gsEntry["isRival"] then
						local rivalScore = paneDisplay:GetChild("Rival"..rivalNum.."Score")
						local rivalName = paneDisplay:GetChild("Rival"..rivalNum.."Name")
						SetNameAndScore(
							GetMachineTag(gsEntry),
							string.format("%.2f%%", gsEntry["score"]/100),
							rivalName,
							rivalScore,
							"#000000"
						)
						rivalNum = rivalNum + 1
					end
				end
			end
		elseif data and data[playerStr] and data[playerStr]["itl"] and data[playerStr]["itl"]["itlLeaderboard"] then
			-- And then also ensure that the chart hash matches the currently parsed one.
			-- It's better to just not display anything than display the wrong scores.
			if SL["P"..i].Streams.Hash == data[playerStr]["chartHash"] then
				for gsEntry in ivalues(data[playerStr]["itl"]["itlLeaderboard"]) do
					if gsEntry["rank"] == 1 then
						SetNameAndScore(
							GetMachineTag(gsEntry),
							string.format("%.2f%%", gsEntry["score"]/100),
							machineName,
							machineScore,
							"#21CCE8"
						)
						worldRecordSet = true
					end

					if gsEntry["isRival"] then
						local rivalScore = paneDisplay:GetChild("Rival"..rivalNum.."Score")
						local rivalName = paneDisplay:GetChild("Rival"..rivalNum.."Name")
						SetNameAndScore(
							GetMachineTag(gsEntry),
							string.format("%.2f%%", gsEntry["score"]/100),
							rivalName,
							rivalScore,
							"#21CCE8"
						)
						rivalNum = rivalNum + 1
					end
				end
			end
		end

		-- Fall back to to using the machine profile's record if we never set the world record.
		-- This chart may not have been ranked, or there is no WR, or the request failed.
		if not worldRecordSet then
			machineName:queuecommand("SetDefault")
			machineScore:queuecommand("SetDefault")
		end

		-- Fall back to to using the personal profile's record if we never set the record.
		-- This chart may not have been ranked, or we don't have a score for it, or the request failed.
		if not personalRecordSet then
			playerName:queuecommand("SetDefault")
			playerScore:queuecommand("SetDefault")
		end

		-- Iterate over any remaining rivals and hide them.
		-- This also handles the failure case as rivalNum will never have been incremented.
		for j=rivalNum,3 do
			local rivalScore = paneDisplay:GetChild("Rival"..j.."Score")
			local rivalName = paneDisplay:GetChild("Rival"..j.."Name")
			rivalScore:settext("??.??%")
			rivalName:settext("----")
		end

		if res.error or res.statusCode ~= 200 then
			local error = res.error and ToEnumShortString(res.error) or nil
			if error == "Timeout" then
				loadingText:settext("Timed Out")
			elseif error or (res.statusCode ~= nil and res.statusCode ~= 200) then
				loadingText:settext("Failed")
			end
		else
			if data and data[playerStr] then
				if itlScore ~= nil then
					loadingText:settext("ITL   "..itlScore):diffuse(color("#21CCE8"))
					SL["P"..i].itlScore = itlRaw
					local stepartist = SCREENMAN:GetTopScreen():GetChild("Overlay"):GetChild("PerPlayer"):GetChild("StepArtistAF_P"..i)

					if stepartist ~= nil then
					  stepartist:queuecommand("ITL")
					end
					-- SCREENMAN:GetTopScreen():GetChild("StepArtistAF_"..i):queuecommand("Reset")
				elseif isItlSong and itlScore == nil then
					loadingText:settext("No ITL Score"):diffuse(color("#21CCE8"))
					SL["P"..i].itlScore = 0
				elseif data[playerStr]["isRanked"] then
					loadingText:settext("Loaded"):diffuse(Color.Black)
				else
					loadingText:settext("Not Ranked"):diffuse(Color.Black)
				end
			else
				-- Just hide the text
				loadingText:queuecommand("Set")
			end
		end
	end
end

-- -----------------------------------------------------------------------
-- define the x positions of four columns, and the y positions of three rows of PaneItems
local pos = {
	col = { WideScale(-104,-133), WideScale(-36,-38), WideScale(54,76), WideScale(150, 190) },
	row = { 13, 31, 49 }
}

local num_rows = 3
local num_cols = 2

-- HighScores handled as special cases for now until further refactoring
local PaneItems = {
	-- first row
	{ name=THEME:GetString("RadarCategory","Taps"),  rc='RadarCategory_TapsAndHolds'},
	{ name=THEME:GetString("RadarCategory","Mines"), rc='RadarCategory_Mines'},
	-- { name=THEME:GetString("ScreenSelectMusic","NPS") },

	-- second row
	{ name=THEME:GetString("RadarCategory","Jumps"), rc='RadarCategory_Jumps'},
	{ name=THEME:GetString("RadarCategory","Hands"), rc='RadarCategory_Hands'},
	-- { name=THEME:GetString("RadarCategory","Lifts"), rc='RadarCategory_Lifts'},

	-- third row
	{ name=THEME:GetString("RadarCategory","Holds"), rc='RadarCategory_Holds'},
	{ name=THEME:GetString("RadarCategory","Rolls"), rc='RadarCategory_Rolls'},
	-- { name=THEME:GetString("RadarCategory","Fakes"), rc='RadarCategory_Fakes'},
}

-- -----------------------------------------------------------------------
local af = Def.ActorFrame{ Name="PaneDisplayMaster" }

af[#af+1] = RequestResponseActor(17, 50)..{
	Name="GetScoresRequester",
	OnCommand=function(self)
		-- Create variables for both players, even if they're not currently active.
		self.IsParsing = {false, false}
	end,
	-- Broadcasted from ./PerPlayer/DensityGraph.lua
	P1ChartParsingMessageCommand=function(self)	self.IsParsing[1] = true end,
	P2ChartParsingMessageCommand=function(self)	self.IsParsing[2] = true end,
	P1ChartParsedMessageCommand=function(self)
		self.IsParsing[1] = false
		self:queuecommand("ChartParsed")
	end,
	P2ChartParsedMessageCommand=function(self)
		self.IsParsing[2] = false
		self:queuecommand("ChartParsed")
	end,
	ChartParsedCommand=function(self)
		local master = self:GetParent()

		if not IsServiceAllowed(SL.GrooveStats.GetScores) then
			if SL.GrooveStats.IsConnected then
				-- loadingText is made visible when requests complete.
				-- If we disable the service from a previous request, surface it to the user here.
				for i=1,2 do
					local loadingText = master:GetChild("PaneDisplayP"..i):GetChild("Loading")
					loadingText:settext("Disabled")
					loadingText:visible(true)
				end
			end
			return
		end

		-- Make sure we're still not parsing either chart.
		if self.IsParsing[1] or self.IsParsing[2] then return end

		-- This makes sure that the Hash in the ChartInfo cache exists.
		local sendRequest = false
		local headers = {}
		local query = {}
		local requestCacheKey = ""

		-- Only send the request if it's applicable.
		if sendRequest then
			requestCacheKey = CRYPTMAN:SHA256String(requestCacheKey.."-player-scores")
			local params = {requestCacheKey=requestCacheKey, master=master}
			RemoveStaleCachedRequests()
			-- If the data is still in the cache, run the request processor directly
			-- without making a request with the cached response.
			if SL.GrooveStats.RequestCache[requestCacheKey] ~= nil then
				local res = SL.GrooveStats.RequestCache[requestCacheKey].Response
				GetScoresRequestProcessor(res, params)
			else
				self:playcommand("MakeGrooveStatsRequest", {
					endpoint="player-scores.php?"..NETWORK:EncodeQueryParameters(query),
					method="GET",
					headers=headers,
					timeout=10,
					callback=GetScoresRequestProcessor,
					args=params,
				})
			end
		end
	end
}

for player in ivalues(PlayerNumber) do
	local pn = ToEnumShortString(player)

	af[#af+1] = Def.ActorFrame{ Name="PaneDisplay"..ToEnumShortString(player) }

	local af2 = af[#af]

	af2.InitCommand=function(self)
		self:visible(GAMESTATE:IsHumanPlayer(player))

		if player == PLAYER_1 then
			self:x(_screen.w * 0.25 - 5)
		elseif player == PLAYER_2 then
			self:x(_screen.w * 0.75 + 5)
		end

		self:y(_screen.h - footer_height - pane_height)
	end

	af2.PlayerJoinedMessageCommand=function(self, params)
		if player==params.Player then
			-- ensure BackgroundQuad is colored before it is made visible
			self:GetChild("BackgroundQuad"):playcommand("Set")
			self:visible(true)
				:zoom(0):croptop(0):bounceend(0.3):zoom(1)
				:playcommand("Update")
		end
	end

	af2.PlayerUnjoinedMessageCommand=function(self, params)
		if player==params.Player then
			self:accelerate(0.3):croptop(1):sleep(0.01):zoom(0):queuecommand("Hide")
		end
	end

	af2.PlayerProfileSetMessageCommand=function(self, params)
		if player == params.Player then
			self:playcommand("Set")
		end
	end

	af2.HideCommand=function(self) self:visible(false) end

	af2.OnCommand=function(self)                                    self:playcommand("Set") end
	af2.SLGameModeChangedMessageCommand=function(self)              self:playcommand("Set") end
	af2.CurrentCourseChangedMessageCommand=function(self)			self:playcommand("Set") end
	af2.CurrentSongChangedMessageCommand=function(self)				self:playcommand("Set") end
	af2["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self) self:playcommand("Set") end
	af2["CurrentTrail"..pn.."ChangedMessageCommand"]=function(self) self:playcommand("Set") end

	-- -----------------------------------------------------------------------
	-- colored background Quad

	af2[#af2+1] = Def.Quad{
		Name="BackgroundQuad",
		InitCommand=function(self)
			self:zoomtowidth(_screen.w/2-10)
			self:zoomtoheight(pane_height)
			self:vertalign(top)
		end,
		SetCommand=function(self)
			local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
			if GAMESTATE:IsHumanPlayer(player) then
				if StepsOrTrail then
					local difficulty = StepsOrTrail:GetDifficulty()
					self:diffuse( DifficultyColor(difficulty) )
				else
					self:diffuse( PlayerColor(player) )
				end
			end
		end
	}

	-- -----------------------------------------------------------------------
	-- loop through the six sub-tables in the PaneItems table
	-- add one BitmapText as the label and one BitmapText as the value for each PaneItem

	for i, item in ipairs(PaneItems) do

		local col = ((i-1)%num_cols) + 1
		local row = math.floor((i-1)/num_cols) + 1

		af2[#af2+1] = Def.ActorFrame{

			Name=item.name,

			-- numerical value
			LoadFont("Common Normal")..{
				InitCommand=function(self)
					self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
					self:x(pos.col[col])
					self:y(pos.row[row])
				end,

				SetCommand=function(self)
					local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
					if not SongOrCourse then self:settext("?"); return end
					if not StepsOrTrail then self:settext("");  return end

					if item.rc then
						local val = StepsOrTrail:GetRadarValues(player):GetValue( item.rc )
						-- the engine will return -1 as the value for autogenerated content; show a question mark instead if so
						self:settext( val >= 0 and val or "?" )
					end
				end
			},

			-- label
			LoadFont("Common Normal")..{
				Text=item.name,
				InitCommand=function(self)
					self:zoom(text_zoom):diffuse(Color.Black):horizalign(left)
					self:x(pos.col[col]+3)
					self:y(pos.row[row])
				end
			},
		}
	end

	-- Machine/World Record Machine Tag
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="MachineHighScoreName",
		InitCommand=function(self)
			self:zoom(text_zoom):diffuse(Color.Black):maxwidth(30)
			self:x(pos.col[3]-50*text_zoom)
			self:y(pos.row[1])
		end,
		SetCommand=function(self)
			self:queuecommand("SetDefault")
		end,
		SetDefaultCommand=function(self)
			local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
			local machineScore = GetScoreFromProfile(machine_profile, SongOrCourse, StepsOrTrail)
			self:settext(machineScore and machineScore:GetName() or "----"):diffuse(Color.Black)
			DiffuseEmojis(self:ClearAttributes())
		end
	}

	-- Machine/World Record HighScore
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="MachineHighScore",
		InitCommand=function(self)
			self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
			self:x(pos.col[3]+25*text_zoom)
			self:y(pos.row[1])
		end,
		SetCommand=function(self)
			self:queuecommand("SetDefault")
		end,
		SetDefaultCommand=function(self)
			local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
			local machineScore = GetScoreFromProfile(machine_profile, SongOrCourse, StepsOrTrail)
			if machineScore ~= nil then
				self:settext(FormatPercentScore(machineScore:GetPercentDP())):diffuse(Color.Black)
			else
				self:settext("??.??%"):diffuse(Color.Black)
			end
		end
	}

	-- Player Profile/GrooveStats Machine Tag
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="PlayerHighScoreName",
		InitCommand=function(self)
			self:zoom(text_zoom):diffuse(Color.Black):maxwidth(30)
			self:x(pos.col[3]-50*text_zoom)
			self:y(pos.row[2])
		end,
		SetCommand=function(self)
			self:queuecommand("SetDefault")
		end,
		SetDefaultCommand=function(self)
			local playerScore = GetScoreForPlayer(player)
			self:settext(playerScore and playerScore:GetName() or "----"):diffuse(Color.Black)
			DiffuseEmojis(self:ClearAttributes())
		end
	}

	-- Player Profile/GrooveStats HighScore
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="PlayerHighScore",
		InitCommand=function(self)
			self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
			self:x(pos.col[3]+25*text_zoom)
			self:y(pos.row[2])
		end,
		SetCommand=function(self)
			self:queuecommand("SetDefault")
		end,
		SetDefaultCommand=function(self)
			local playerScore = GetScoreForPlayer(player)
			if playerScore ~= nil then
				self:settext(FormatPercentScore(playerScore:GetPercentDP())):diffuse(Color.Black)
			else
				self:settext("??.??%"):diffuse(Color.Black)
			end
		end
	}
	
	-- Player Profile Combo Check
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="PlayerCombo",
		InitCommand=function(self)
			self:zoom(text_zoom+0.2):horizalign(right):rotationz(-30)
			self:x(pos.col[3]+30*text_zoom)
			self:y(pos.row[2]-3)
		end,
		SetCommand=function(self)
			self:queuecommand("SetDefault")
		end,
		SetDefaultCommand=function(self)
			local playerScore = GetScoreForPlayer(player)
			
			local playerNum = ToEnumShortString(player)
			SL[playerNum].comboBonus = 0
			
			if playerScore ~= nil then
				if playerScore:GetTapNoteScore('TapNoteScore_W4') + playerScore:GetTapNoteScore('TapNoteScore_W5') + playerScore:GetTapNoteScore('TapNoteScore_Miss') == 0 then
					if playerScore:GetTapNoteScore('TapNoteScore_W3') + playerScore:GetTapNoteScore('TapNoteScore_W2') == 0 then
						self:settext("****"):diffuse(color("#21CCE8")):visible(true)
						SL[playerNum].comboBonus = 400
					elseif playerScore:GetTapNoteScore('TapNoteScore_W3') == 0 then
						self:settext("FEC"):diffuse(Color.Yellow):visible(true)
						if playerScore:GetTapNoteScore('TapNoteScore_W2') <= 10 then
							self:settext(playerScore:GetTapNoteScore('TapNoteScore_W2').."E")
						end
						SL[playerNum].comboBonus = 200
					else
						self:settext("FC"):diffuse(color("#00FF00")):visible(true)
						if playerScore:GetTapNoteScore('TapNoteScore_W3') <= 10 then
							self:settext(playerScore:GetTapNoteScore('TapNoteScore_W3').."G")
						end
						SL[playerNum].comboBonus = 100
					end
				else
					SL[playerNum].comboBonus = 0
					if playerScore:GetTapNoteScore('TapNoteScore_Miss') == 1 then
						self:settext("1M"):diffuse(color("#FF0000")):visible(true)
					else
						self:visible(false)
					end
				end
			else
				self:visible(false)
				SL[playerNum].comboBonus = 0
			end
		end
	}

	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="Loading",
		Text="Loading ... ",
		InitCommand=function(self)
			self:zoom(text_zoom):diffuse(Color.Black)
			self:x(pos.col[3]-15)
			self:y(pos.row[3])
			self:visible(false)
		end,
		SetCommand=function(self)
			self:settext("Loading ...")
			self:visible(false)
		end
	}

	-- Chart Difficulty Meter
	af2[#af2+1] = LoadFont("Wendy/_wendy small")..{
		Name="DifficultyMeter",
		InitCommand=function(self)
			self:horizalign(right):diffuse(Color.Black)
			self:xy(pos.col[4], pos.row[2])
			if not IsUsingWideScreen() then self:maxwidth(66) end
			self:queuecommand("Set")
		end,
		SetCommand=function(self)
			-- Hide the difficulty number if we're connected.
			if IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:visible(false)
			end

			local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
			if not SongOrCourse then self:settext("") return end
			local meter = StepsOrTrail and StepsOrTrail:GetMeter() or "?"

			self:settext( meter )
		end
	}
end

return af
