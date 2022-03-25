-- get the machine_profile now at file init; no need to keep fetching with each SetCommand
local machine_profile = PROFILEMAN:GetMachineProfile()
local nsj = GAMESTATE:GetNumSidesJoined()
-- the height of the footer is defined in ./Graphics/_footer.lua, but we'll
-- use it here when calculating where to position the PaneDisplay
local footer_height = 32

-- height of the PaneDisplay in pixels
local pane_height = 48

local text_zoom = IsUsingWideScreen() and WideScale(0.8, 0.9) or 0.9

local CirclePositionX
local CirclePositionY

-- Set the position of the loading circle's X position
if nsj == 2 then
	if IsUsingWideScreen() then
		CirclePositionX = SCREEN_CENTER_X
	else
		CirclePositionX = SCREEN_LEFT + 150
	end
elseif GAMESTATE:IsPlayerEnabled(0) then 
	if IsUsingWideScreen() then
		CirclePositionX = WideScale(SCREEN_LEFT + 155, SCREEN_LEFT + 245)
	else
		CirclePositionX = SCREEN_LEFT + 260
	end
else
	if IsUsingWideScreen() then
		CirclePositionX = WideScale(SCREEN_RIGHT - 6,SCREEN_RIGHT - 20)
	else
		CirclePositionX = SCREEN_LEFT + 260
	end
end

-- Set the position of the loading circle's Y position
if nsj == 2 then
	if IsUsingWideScreen() then
		CirclePositionY = SCREEN_CENTER_Y - 85
	else
		CirclePositionY = SCREEN_CENTER_Y - 83
	end
else
	if IsUsingWideScreen() then
		CirclePositionY = SCREEN_BOTTOM - 134
	else
		CirclePositionY = SCREEN_BOTTOM - 134
	end
end


-- -----------------------------------------------------------------------
-- Convenience function to return the SongOrCourse and StepsOrTrail for a
-- for a player.
local GetSongAndSteps = function(player)
	local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
	local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	return SongOrCourse, StepsOrTrail
end

-- -----------------------------------------------------------------------
-- requires a profile (machine or player) as an argument
-- returns formatted strings for player tag (from ScreenNameEntry) and PercentScore

local GetNameAndScore = function(profile, SongOrCourse, StepsOrTrail)
	-- if we don't have everything we need, return empty strings
	if not (profile and SongOrCourse and StepsOrTrail) then return "","" end

	local score, name
	local topscore = profile:GetHighScoreList(SongOrCourse, StepsOrTrail):GetHighScores()[1]

	if topscore then
		score = FormatPercentScore( topscore:GetPercentDP() )
		name = topscore:GetName()
	else
		score = "??.??%"
		name = "----"
	end

	return score, name
end

-- -----------------------------------------------------------------------
local SetNameAndScore = function(name, score, nameActor, scoreActor)
	if not scoreActor or not nameActor then return end
	scoreActor:settext(score)
	nameActor:settext(name)
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

local GetScoresRequestProcessor = function(res, master)
	if master == nil then return end
	-- If we're not hovering over a song when we get the request, then we don't
	-- have to update anything. We don't have to worry about courses here since
	-- we don't run the RequestResponseActor in CourseMode.
	if GAMESTATE:GetCurrentSong() == nil then return end
	
	if res == nil then
		for i=1,2 do
			local paneDisplay = master:GetChild("PaneDisplayP"..i)
			local loadingText = paneDisplay:GetChild("Loading")
			loadingText:settext("Timed Out")
		end

		return
	end

	for i=1,2 do
		local paneDisplay = master:GetChild("PaneDisplayP"..i)

		local machineScore = paneDisplay:GetChild("MachineHighScore")
		local machineName = paneDisplay:GetChild("MachineHighScoreName")

		local playerScore = paneDisplay:GetChild("PlayerHighScore")
		local playerName = paneDisplay:GetChild("PlayerHighScoreName")

		local loadingText = paneDisplay:GetChild("Loading")
		local WRorLBText = paneDisplay:GetChild("MachineTextLabel")

		local playerStr = "player"..i
		local rivalNum = 1
		local worldRecordSet = false
		local personalRecordSet = false
		local data = res["status"] == "success" and res["data"] or nil

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
							machineScore
						)
						worldRecordSet = true
					end

					if gsEntry["isSelf"] then
						SetNameAndScore(
							GetMachineTag(gsEntry),
							string.format("%.2f%%", gsEntry["score"]/100),
							playerName,
							playerScore
						)
						personalRecordSet = true
					end

					if gsEntry["isRival"] then
						local rivalScore = paneDisplay:GetChild("Rival"..rivalNum.."Score")
						local rivalName = paneDisplay:GetChild("Rival"..rivalNum.."Name")
						SetNameAndScore(
							GetMachineTag(gsEntry),
							string.format("%.2f%%", gsEntry["score"]/100),
							rivalName,
							rivalScore
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

		if res["status"] == "success" then
			if data and data[playerStr] then
				if data[playerStr]["isRanked"] then
					loadingText:settext("Loaded")
					WRorLBText:settext("WR:")
				else
					loadingText:settext("Not Ranked")
					WRorLBText:settext("Local Best:")
				end
			else
				-- Just hide the text
				loadingText:queuecommand("Set")
				WRorLBText:settext("Local Best:")
			end
		elseif res["status"] == "fail" then
			loadingText:settext("Failed")
		elseif res["status"] == "disabled" then
			loadingText:settext("Disabled")
		end
	end
end

-- -----------------------------------------------------------------------
-- define the x positions of four columns, and the y positions of three rows of PaneItems
local pos = {
	col = { 
	IsUsingWideScreen() and WideScale(-120,-155) or -90, 
	IsUsingWideScreen() and WideScale(-36,-16) or 50, 
	WideScale(54,76), 
	WideScale(150, 190) },
	
	row = { 
	IsUsingWideScreen() and -55 or -55, 
	IsUsingWideScreen() and -37 or -37, 
	IsUsingWideScreen() and -19 or -19,
	IsUsingWideScreen() and -1 or -1, 
	IsUsingWideScreen() and 17 or 17, 
	IsUsingWideScreen() and 35 or 35, }
}

local num_rows = 6
local num_cols = 2

-- HighScores handled as special cases for now until further refactoring
local PaneItems = {
	-- all in one row now
	{ name=THEME:GetString("RadarCategory","Taps"),  rc='RadarCategory_TapsAndHolds'},
	{ name=THEME:GetString("RadarCategory","Holds"), rc='RadarCategory_Holds'},
	{ name=THEME:GetString("RadarCategory","Rolls"), rc='RadarCategory_Rolls'},
	{ name=THEME:GetString("RadarCategory","Jumps"), rc='RadarCategory_Jumps'},
	{ name=THEME:GetString("RadarCategory","Hands"), rc='RadarCategory_Hands'},
	{ name=THEME:GetString("RadarCategory","Mines"), rc='RadarCategory_Mines'},
	
	
	-- { name=THEME:GetString("RadarCategory","Fakes"), rc='RadarCategory_Fakes'},
	-- { name=THEME:GetString("RadarCategory","Lifts"), rc='RadarCategory_Lifts'},
}

-- -----------------------------------------------------------------------
local af = Def.ActorFrame{ Name="PaneDisplayMaster" }

for player in ivalues(PlayerNumber) do
	local pn = ToEnumShortString(player)

	af[#af+1] = Def.ActorFrame{ Name="PaneDisplay"..ToEnumShortString(player) }

	local af2 = af[#af]

	af2.InitCommand=function(self)
		self:visible(GAMESTATE:IsHumanPlayer(player))
		if player == PLAYER_1 then
			self:x(IsUsingWideScreen() and _screen.w * 0.25 - 5 or 160)
			self:y(IsUsingWideScreen() and 0 or 199)
			self:align(0,IsUsingWideScreen() and 0 or 0)
			if IsUsingWideScreen() then
				if nsj == 1 then
					self:align(0,0)
				end
			end
			
		elseif player == PLAYER_2 then
			self:x(IsUsingWideScreen() and _screen.w * 0.75 + 156 or SCREEN_RIGHT - 160)
			self:align(0, IsUsingWideScreen() and 0 or 0)
			if not IsUsingWideScreen()then
				if nsj == 1 then
					self:x(160)
					self:align(0,0)
				elseif nsj == 2 then
					self:x(SCREEN_RIGHT - 160)
					self:align(0,0)
				end
			end
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
	-- player unjoining is not currently possible in SL, but maybe someday
	af2.PlayerUnjoinedMessageCommand=function(self, params)
		if player==params.Player then
			self:accelerate(0.3):croptop(1):sleep(0.01):zoom(0):queuecommand("Hide")
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
			self:zoomtowidth(IsUsingWideScreen() and _screen.w/2-160 or 310)
			self:zoomtoheight(_screen.h/8+56)
			self:y(-10)
			self:x(IsUsingWideScreen() and -76.5 or -6)
			if player == PLAYER_2 and not IsUsingWideScreen() and nsj == 2 then
				self:zoomtowidth(320)
				self:addx(5)
			end
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

		local col = 1
		local row = math.floor((i-1)/1) + 1

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

	-- Machine/World Record Text Label
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="MachineTextLabel",
		Text="Local Best:",
		InitCommand=function(self)
			self:zoom(text_zoom-0.15):diffuse(Color.Black):horizalign(right)
			self:x(IsUsingWideScreen() and WideScale(pos.col[2]-15,pos.col[2]-25) or pos.col[2]-25)
			self:y(IsUsingWideScreen() and pos.row[2] or pos.row[2])
		end,
	}

	-- Machine/World Record Machine Tag
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="MachineHighScoreName",
		InitCommand=function(self)
			self:zoom(IsUsingWideScreen() and WideScale(text_zoom-0.2,text_zoom) or text_zoom):diffuse(Color.Black):horizalign(center):maxwidth(80)
			self:x(IsUsingWideScreen() and WideScale(pos.col[2]+40,pos.col[2]+48) or pos.col[3]+50)
			self:y(IsUsingWideScreen() and pos.row[2] or pos.row[2])
		end,
		SetCommand=function(self)
			-- We overload this actor to work both for GrooveStats and also offline.
			-- If we're connected, we let the ResponseProcessor set the text
			if IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:settext("----")
			else
				self:queuecommand("SetDefault")
			end
		end,
		SetDefaultCommand=function(self)
			local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
			local machine_score, machine_name = GetNameAndScore(machine_profile, SongOrCourse, StepsOrTrail)
			self:settext(machine_name or ""):diffuse(Color.Black)
			DiffuseEmojis(self)
		end
	}

	-- Machine/World Record HighScore
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="MachineHighScore",
		InitCommand=function(self)
			self:zoom(IsUsingWideScreen() and WideScale(text_zoom-0.25,text_zoom) or text_zoom):diffuse(Color.Black):horizalign(right)
			self:x(IsUsingWideScreen() and WideScale(pos.col[2]+20,pos.col[2]+28) or pos.col[2]+28)
			self:y(IsUsingWideScreen() and pos.row[2] or pos.row[2])
		end,
		SetCommand=function(self)
			-- We overload this actor to work both for GrooveStats and also offline.
			-- If we're connected, we let the ResponseProcessor set the text
			if IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:settext("??.??%")
			else
				self:queuecommand("SetDefault")
			end
		end,
		SetDefaultCommand=function(self)
			local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
			local machine_score, machine_name = GetNameAndScore(machine_profile, SongOrCourse, StepsOrTrail)
			self:settext(machine_score or "")
		end
	}

	-- Personal Best Text Label
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="PersonalTextLabel",
		Text="PB:",
		InitCommand=function(self)
			self:zoom(text_zoom-0.15):diffuse(Color.Black):horizalign(right)
			self:x(IsUsingWideScreen() and WideScale(pos.col[2]-15,pos.col[2]-25) or pos.col[2]-25)
			self:y(IsUsingWideScreen() and pos.row[3] or pos.row[3])
		end,
	}

	-- Player Profile/GrooveStats Machine Tag 
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="PlayerHighScoreName",
		InitCommand=function(self)
			self:zoom(IsUsingWideScreen() and WideScale(text_zoom-0.2,text_zoom) or text_zoom):diffuse(Color.Black):horizalign(center)
			self:x(IsUsingWideScreen() and WideScale(pos.col[2]+40,pos.col[2]+48) or pos.col[3]+50)
			self:y(IsUsingWideScreen() and pos.row[3] or pos.row[3])
		end,
		SetCommand=function(self)
			-- We overload this actor to work both for GrooveStats and also offline.
			-- If we're connected, we let the ResponseProcessor set the text
			if IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:settext("----")
			else
				self:queuecommand("SetDefault")
			end
		end,
		SetDefaultCommand=function(self)
			local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
			local player_score, player_name
			if PROFILEMAN:IsPersistentProfile(player) then
				player_score, player_name = GetNameAndScore(PROFILEMAN:GetProfile(player), SongOrCourse, StepsOrTrail)
			end
			self:settext(player_name or ""):diffuse(Color.Black)
			DiffuseEmojis(self)
		end
	}

	-- Player Profile/GrooveStats HighScore
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="PlayerHighScore",
		InitCommand=function(self)
			self:zoom(IsUsingWideScreen() and WideScale(text_zoom-0.25,text_zoom) or text_zoom):diffuse(Color.Black):horizalign(right)
			self:x(IsUsingWideScreen() and WideScale(pos.col[2]+20,pos.col[2]+28) or pos.col[2]+28)
			self:y(IsUsingWideScreen() and pos.row[3] or pos.row[3])
		end,
		SetCommand=function(self)
			-- We overload this actor to work both for GrooveStats and also offline.
			-- If we're connected, we let the ResponseProcessor set the text
			if IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:settext("??.??%")
			else
				self:queuecommand("SetDefault")
			end
		end,
		SetDefaultCommand=function(self)
			local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
			local player_score, player_name
			if PROFILEMAN:IsPersistentProfile(player) then
				player_score, player_name = GetNameAndScore(PROFILEMAN:GetProfile(player), SongOrCourse, StepsOrTrail)
			end

			self:settext(player_score or "")
		end
	}
	
	---loading text/status
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="Loading",
		Text="Loading ... ",
		InitCommand=function(self)
			self:zoom(text_zoom):diffuse(Color.Black)
			self:x(pos.col[2]+6)
			self:y(pos.row[1])
			self:visible(false)
			self:horizalign(center)
		end,
		SetCommand=function(self)
			self:settext("Loading ...")
			self:visible(false)
			if not IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:settext("SCORES")
				self:visible(true)
			end
		end
	}

	-- Add actors for Rival score data. Hidden by default
	-- We position relative to column 3 for spacing reasons.
	for i=1,3 do
		-- Rival Machine Tag
		af2[#af2+1] = LoadFont("Common Normal")..{
			Name="Rival"..i.."Name",
			InitCommand=function(self)
				self:zoom(IsUsingWideScreen() and WideScale(text_zoom-0.2,text_zoom) or text_zoom):diffuse(Color.Black):maxwidth(30):horizalign(center)
				self:x(IsUsingWideScreen() and WideScale(pos.col[2]+40,pos.col[2]+48) or pos.col[3]+50)
				self:y(pos.row[i]+55)
			end,
			OnCommand=function(self)
				self:visible(IsServiceAllowed(SL.GrooveStats.GetScores))
			end,
			SetCommand=function(self)
				self:settext("----")
			end
		}

		-- Rival HighScore
		af2[#af2+1] = LoadFont("Common Normal")..{
			Name="Rival"..i.."Score",
			InitCommand=function(self)
				self:zoom(IsUsingWideScreen() and WideScale(text_zoom-0.2,text_zoom) or text_zoom):diffuse(Color.Black):horizalign(right)
				self:x(IsUsingWideScreen() and WideScale(pos.col[2]+20,pos.col[2]+28) or pos.col[2]+28)
				self:y(pos.row[i]+55)
			end,
			OnCommand=function(self)
				self:visible(IsServiceAllowed(SL.GrooveStats.GetScores))
			end,
			SetCommand=function(self)
				self:settext("??.??%")
			end
		}
		
		-- Rival label
		af2[#af2+1] = LoadFont("Common Normal")..{
			Name="Rival"..i.."Label",
			Text="Rival"..i..":",
			InitCommand=function(self)
				self:zoom(IsUsingWideScreen() and WideScale(text_zoom-0.25,text_zoom-0.15) or text_zoom-0.15):diffuse(Color.Black):horizalign(right)
				self:horizalign(right)
				self:x(IsUsingWideScreen() and WideScale(pos.col[2]-15,pos.col[2]-25) or pos.col[2]-25)
				self:y(pos.row[i]+55)
			end,
			OnCommand=function(self)
				self:visible(IsServiceAllowed(SL.GrooveStats.GetScores))
			end,
		}
		
	end
end

af[#af+1] = RequestResponseActor("GetScores", 10, CirclePositionX, CirclePositionY, nsj == 2 and 1 or 0.75)..{
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
		if not IsServiceAllowed(SL.GrooveStats.GetScores) then return end

		-- Make sure we're still not parsing either chart.
		if self.IsParsing[1] or self.IsParsing[2] then return end

		-- This makes sure that the Hash in the ChartInfo cache exists.
		local sendRequest = false
		local data = {
			action="groovestats/player-scores",
		}

		for i=1,2 do
			local pn = "P"..i
			if SL[pn].ApiKey ~= "" and SL[pn].Streams.Hash ~= "" then
				data["player"..i] = {
					chartHash=SL[pn].Streams.Hash,
					apiKey=SL[pn].ApiKey
				}
				local loadingText = master:GetChild("PaneDisplayP"..i):GetChild("Loading")
				loadingText:visible(true)
				loadingText:settext("Loading ...")
				sendRequest = true
			end
		end

		-- Only send the request if it's applicable.
		if sendRequest then
			MESSAGEMAN:Broadcast("GetScores", {
				data=data,
				args=SCREENMAN:GetTopScreen():GetChild("Overlay"):GetChild("PaneDisplayMaster"),
				callback=GetScoresRequestProcessor
			})
		end
	end
}

return af