-- get the machine_profile now at file init; no need to keep fetching with each SetCommand
local machine_profile = PROFILEMAN:GetMachineProfile()
local nsj = GAMESTATE:GetNumSidesJoined()
-- the height of the footer is defined in ./Graphics/_footer.lua, but we'll
-- use it here when calculating where to position the PaneDisplay
local footer_height = 32

-- height of the PaneDisplay in pixels
local pane_height = -3

local text_zoom = IsUsingWideScreen() and WideScale(0.8, 0.9) or 0.9

-- -----------------------------------------------------------------------
-- Convenience function to return the Course and Trail for a
-- for a player.
local GetSongAndSteps = function(player)
	local Course = GAMESTATE:GetCurrentCourse()
	local Trail = GAMESTATE:GetCurrentTrail(player)
	return Course, Trail
end

-- -----------------------------------------------------------------------
-- requires a profile (machine or player) as an argument
-- returns formatted strings for player tag (from ScreenNameEntry) and PercentScore

local GetNameAndScore = function(profile, Course, Trail)
	-- if we don't have everything we need, return empty strings
	if not (profile and Course and Trail) then return "","" end

	local score, name
	local topscore = profile:GetHighScoreList(Course, Trail):GetHighScores()[1]

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

local GetScoresRequestProcessor = function(res, master)
	if master == nil then return end
	-- If we're not hovering over a song when we get the request, then we don't
	-- have to update anything. We don't have to worry about courses here since
	-- we don't run the RequestResponseActor in CourseMode.
	if GAMESTATE:GetCurrentSong() == nil then return end

	for i=1,2 do
		local paneDisplay = master:GetChild("PaneDisplayP"..i)

		local machineScore = paneDisplay:GetChild("MachineHighScore")
		local machineName = paneDisplay:GetChild("MachineHighScoreName")

		local playerScore = paneDisplay:GetChild("PlayerHighScore")
		local playerName = paneDisplay:GetChild("PlayerHighScoreName")

		local loadingText = paneDisplay:GetChild("Loading")
		local WRorLBText = paneDisplay:GetChild("MachineTextLabel")

		-- Fall back to to using the machine profile's record if we never set the world record.
		-- This chart may not have been ranked, or there is no WR, or the request failed.
		machineName:queuecommand("SetDefault")
		machineScore:queuecommand("SetDefault")
		playerName:queuecommand("SetDefault")
		playerScore:queuecommand("SetDefault")
	end
end

-- -----------------------------------------------------------------------
-- define the x positions of four columns, and the y positions of three rows of PaneItems
local pos = {
	col = { 
	IsUsingWideScreen() and WideScale(-120,-155) or -90, 
	IsUsingWideScreen() and WideScale(-106,-78) or 50, 
	WideScale(24,46), 
	WideScale(100, 140) },
	
	row = { 
	IsUsingWideScreen() and -55 or -55, 
	IsUsingWideScreen() and -37 or -37, 
	IsUsingWideScreen() and -19 or -19,
	IsUsingWideScreen() and -1 or -1, 
	IsUsingWideScreen() and 17 or 17, 
	IsUsingWideScreen() and 35 or 35, }
}

local num_rows = 3
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
			self:x(IsUsingWideScreen() and 0 + _screen.w /4 - 4 or 160)
			
		elseif player == PLAYER_2 then
			self:x(IsUsingWideScreen() and SCREEN_RIGHT - (_screen.w /4.55) or 160)
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
	af2["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self) self:playcommand("Set") end
	af2["CurrentTrail"..pn.."ChangedMessageCommand"]=function(self) self:playcommand("Set") end

	-- -----------------------------------------------------------------------
	-- colored background Quad

	af2[#af2+1] = Def.Quad{
		Name="BackgroundQuad",
		InitCommand=function(self)
			local quadwidth = IsUsingWideScreen() and _screen.w/2-30 or 310
			self:zoomtowidth(quadwidth)
			self:zoomtoheight(_screen.h/8+6)
			self:y(-36)
			self:x(IsUsingWideScreen() and -11 or -6)
		end,
		SetCommand=function(self)
			local Course, Trail = GetSongAndSteps(player)
			if GAMESTATE:IsHumanPlayer(player) then
				if Trail then
					local difficulty = Trail:GetDifficulty()
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
					local Course, Trail = GetSongAndSteps(player)
					if not Course then self:settext("?"); return end
					if not Trail then self:settext("");  return end

					if item.rc then
						local val = Trail:GetRadarValues(player):GetValue( item.rc )
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

	-- Machine Record Text Label
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="MachineTextLabel",
		Text="Local Best:",
		InitCommand=function(self)
			self:zoom(text_zoom-0.15):diffuse(Color.Black):horizalign(right)
			self:x(IsUsingWideScreen() and WideScale(pos.col[3]-15,pos.col[3]-25) or pos.col[3]-25)
			self:y(IsUsingWideScreen() and pos.row[2] or pos.row[2])
		end,
	}

	-- Machine Record Tag
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="MachineHighScoreName",
		InitCommand=function(self)
			self:zoom(IsUsingWideScreen() and WideScale(text_zoom-0.2,text_zoom) or text_zoom):diffuse(Color.Black):horizalign(center):maxwidth(80)
			self:x(IsUsingWideScreen() and WideScale(pos.col[3]+40,pos.col[3]+48) or pos.col[3]+50)
			self:y(IsUsingWideScreen() and pos.row[2] or pos.row[2])
		end,
		SetCommand=function(self)
			local Course, Trail = GetSongAndSteps(player)
			local machine_score, machine_name = GetNameAndScore(machine_profile, Course, Trail)
			self:settext(machine_name or ""):diffuse(Color.Black)
			DiffuseEmojis(self)
		end
	}

	-- Machine HighScore
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="MachineHighScore",
		InitCommand=function(self)
			self:zoom(IsUsingWideScreen() and WideScale(text_zoom-0.25,text_zoom) or text_zoom):diffuse(Color.Black):horizalign(right)
			self:x(IsUsingWideScreen() and WideScale(pos.col[3]+20,pos.col[3]+28) or pos.col[3]+28)
			self:y(IsUsingWideScreen() and pos.row[2] or pos.row[2])
		end,
		SetCommand=function(self)
			local Course, Trail = GetSongAndSteps(player)
			local machine_score, machine_name = GetNameAndScore(machine_profile, Course, Trail)
			self:settext(machine_score or "")
		end
	}

	-- Personal Best Text Label
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="PersonalTextLabel",
		Text="PB:",
		InitCommand=function(self)
			self:zoom(text_zoom-0.15):diffuse(Color.Black):horizalign(right)
			self:x(IsUsingWideScreen() and WideScale(pos.col[3]-15,pos.col[3]-25) or pos.col[3]-25)
			self:y(IsUsingWideScreen() and pos.row[3] or pos.row[3])
		end,
	}

	-- Player Profile Tag 
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="PlayerHighScoreName",
		InitCommand=function(self)
			self:zoom(IsUsingWideScreen() and WideScale(text_zoom-0.2,text_zoom) or text_zoom):diffuse(Color.Black):horizalign(center)
			self:x(IsUsingWideScreen() and WideScale(pos.col[3]+40,pos.col[3]+48) or pos.col[3]+50)
			self:y(IsUsingWideScreen() and pos.row[3] or pos.row[3])
		end,
		SetCommand=function(self)
			local Course, Trail = GetSongAndSteps(player)
			local player_score, player_name
			if PROFILEMAN:IsPersistentProfile(player) then
				player_score, player_name = GetNameAndScore(PROFILEMAN:GetProfile(player), Course, Trail)
			end
			self:settext(player_name or ""):diffuse(Color.Black)
			DiffuseEmojis(self)
		end
	}

	-- Player Profile HighScore
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="PlayerHighScore",
		InitCommand=function(self)
			self:zoom(IsUsingWideScreen() and WideScale(text_zoom-0.25,text_zoom) or text_zoom):diffuse(Color.Black):horizalign(right)
			self:x(IsUsingWideScreen() and WideScale(pos.col[3]+20,pos.col[3]+28) or pos.col[3]+28)
			self:y(IsUsingWideScreen() and pos.row[3] or pos.row[3])
		end,
		SetCommand=function(self)
			local Course, Trail = GetSongAndSteps(player)
			local player_score, player_name
			if PROFILEMAN:IsPersistentProfile(player) then
				player_score, player_name = GetNameAndScore(PROFILEMAN:GetProfile(player), Course, Trail)
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
			self:x(pos.col[3]+6)
			self:y(pos.row[1])
			self:visible(false)
			self:horizalign(center)
		end,
		SetCommand=function(self)
			self:settext("SCORES")
			self:visible(true)
		end
	}
	
	-- Chart Difficulty Meter
	af2[#af2+1] = LoadFont("Wendy/_wendy small")..{
		Name="DifficultyMeter",
		InitCommand=function(self)
			self:horizalign(center):diffuse(Color.Black)
			self:xy(pos.col[4]+10, pos.row[2])
			if not IsUsingWideScreen() then self:maxwidth(66) end
			self:queuecommand("Set")
		end,
		SetCommand=function(self)
			local Course, Trail = GetSongAndSteps(player)
			if not Course then self:settext("") return end
			local meter = Trail and Trail:GetMeter() or "?"

			self:settext( meter )
		end
	}
end

return af