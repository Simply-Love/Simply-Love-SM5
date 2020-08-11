local player = ...
local pn = ToEnumShortString(player)
local nsj = GAMESTATE:GetNumSidesJoined()

-- get the machine_profile now at file init; no need to keep fetching with each SetCommand
local machine_profile = PROFILEMAN:GetMachineProfile()

-- the height of the footer is defined in ./Graphics/_footer.lua, but we'll
-- use it here when calculating where to position the PaneDisplay
local footer_height = 32

-- height of the PaneDisplay in pixels
local pane_height = 60

local text_zoom = WideScale(0.8, 0.9)

-- -----------------------------------------------------------------------
-- variables with file scope for convenience

local SongOrCourse, StepsOrTrail
local machine_score, machine_name
local player_score, player_name

-- -----------------------------------------------------------------------
-- requires a profile (machine or player) as an argument
-- returns formatted strings for player tag (from ScreenNameEntry) and PercentScore



local GetNameAndScore = function(profile)
	-- if we don't have everything we need, return empty strings
	if not (profile and SongOrCourse and StepsOrTrail) then return "","" end

	local score, name
	local topscore = profile:GetHighScoreList(SongOrCourse, StepsOrTrail):GetHighScores()[1]

	if topscore then
		score = FormatPercentScore( topscore:GetPercentDP() )
		name = topscore:GetName()
	else
		score = string.format("%.2f%%", 0)
		name = "????"
	end

	return score, name
end

-- -----------------------------------------------------------------------
-- define the x positions of four columns, and the y positions of three rows of PaneItems
local pos = {
	col = { WideScale(-104,-140), WideScale(-36,-16), WideScale(54,76), WideScale(150, 190) },
	row = { IsUsingWideScreen() and -25 or -75, IsUsingWideScreen() and -7 or -57, IsUsingWideScreen() and 12 or -39 }
}

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

local af = Def.ActorFrame{ Name="PaneDisplay"..ToEnumShortString(player) }

af.InitCommand=function(self)
	self:visible(GAMESTATE:IsHumanPlayer(player))

	if player == PLAYER_1 then
		self:x(IsUsingWideScreen() and _screen.w * 0.25 - 5 or 160)
		self:y(IsUsingWideScreen() and 0 or 199)
		self:align(0,IsUsingWideScreen() and 0 or -82)
		if IsUsingWideScreen() then
			elseif nsj == 1 then
				self:align(0,GAMESTATE:IsCourseMode() and 239 or 0)
		end
		
	elseif player == PLAYER_2 then
		self:x(IsUsingWideScreen() and _screen.w * 0.75 + 156 or _screen.w * 0.75 + 10)
		self:align(0, IsUsingWideScreen() and 0 or -82)
		if IsUsingWideScreen() then
			elseif nsj == 1 then
				self:x(160)
				self:align(0,GAMESTATE:IsCourseMode() and 239 or 0)
			end
	end

	self:y(_screen.h - footer_height - pane_height)
end

af.PlayerJoinedMessageCommand=function(self, params)
	nsj = GAMESTATE:GetNumSidesJoined()
	if player==params.Player then
		-- ensure BackgroundQuad is colored before it is made visible
		self:GetChild("BackgroundQuad"):playcommand("Set")
		self:visible(true)
		SCREENMAN:SetNewScreen('ScreenSelectMusicDD')
            self:playcommand("Init")
	end
end
-- player unjoining is not currently possible in SL, but maybe someday
af.PlayerUnjoinedMessageCommand=function(self, params)
	if player==params.Player then
		self:accelerate(0.3):croptop(1):sleep(0.01):zoom(0):queuecommand("Hide")
	end
end
af.HideCommand=function(self) self:visible(false) end

af.OnCommand=function(self)                                    self:playcommand("Update") end
af.CurrentSongChangedMessageCommand=function(self)             self:playcommand("Update") end
af.CurrentCourseChangedMessageCommand=function(self)           self:playcommand("Update") end
af.SLGameModeChangedMessageCommand=function(self)              self:playcommand("Update") end
af["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self) self:playcommand("Update") end
af["CurrentTrail"..pn.."ChangedMessageCommand"]=function(self) self:playcommand("Update") end


af.UpdateCommand=function(self)
	SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
	StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)

	machine_score, machine_name = GetNameAndScore( machine_profile )

	if PROFILEMAN:IsPersistentProfile(player) then
		 player_score, player_name = GetNameAndScore( PROFILEMAN:GetProfile(player) )
	end

	self:queuecommand("Set")
end

-- -----------------------------------------------------------------------
-- colored background Quad

af[#af+1] = Def.Quad{
	Name="BackgroundQuad",
	InitCommand=function(self)
		self:zoomtowidth(_screen.w/2-161)
		self:zoomtoheight(_screen.h/8+42)
		self:y(10)
		self:x(-75.5)
	end,
	SetCommand=function(self, params)
		if IsUsingWideScreen() then
			else
			self:zoomto(310,70)
			self:x(-5)
			self:y(-58)
		end
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
-- loop through the nine sub-tables in the PaneItems table
-- add one BitmapText as the label and one BitmapText as the value for each PaneItem

local num_rows = 3
local num_cols = 2

for i, item in ipairs(PaneItems) do

	local col = ((i-1)%num_cols) + 1
	local row = math.floor((i-1)/num_cols) + 1

	af[#af+1] = Def.ActorFrame{

		Name=item.name,

		-- numerical value
		LoadFont("Common Normal")..{
			InitCommand=function(self)
				self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
				self:x(pos.col[col])
				self:y(pos.row[row])
			end,

			SetCommand=function(self)
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

-- Machine Best Text Label
af[#af+1] = LoadFont("Common Normal")..{
	Name="MachineTextLabel",
	Text="Machine Best:",
	InitCommand=function(self)
		self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
		self:x(IsUsingWideScreen() and WideScale(pos.col[1]+15,pos.col[1]+65) or pos.col[3]+65)
		self:y(IsUsingWideScreen() and pos.row[1]+55 or pos.row[1])
	end,
}

-- Machine HighScore value
af[#af+1] = LoadFont("Common Normal")..{
	Name="MachineHighScore",
	InitCommand=function(self)
		self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
		self:x(IsUsingWideScreen() and pos.col[2]-5 or pos.col[3]+30)
		self:y(IsUsingWideScreen() and pos.row[1]+55 or pos.row[2])
	end,
	SetCommand=function(self) self:settext(machine_score or "") end
}

-- Machine HighScore name
af[#af+1] = LoadFont("Common Normal")..{
	Name="MachineHighScoreName",
	InitCommand=function(self)
		self:zoom(text_zoom):diffuse(Color.Black):horizalign(left):maxwidth(80)
		self:x(IsUsingWideScreen() and pos.col[2]+5 or pos.col[3]+50)
		self:y(IsUsingWideScreen() and pos.row[1]+55 or pos.row[2])
	end,
	SetCommand=function(self)
		self:settext(machine_name or ""):diffuse(Color.Black)
		DiffuseEmojis(self)
	end
}

-- Personal Best Text Label
af[#af+1] = LoadFont("Common Normal")..{
	Name="PersonalTextLabel",
	Text="Personal Best:",
	InitCommand=function(self)
		self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
		self:x(IsUsingWideScreen() and WideScale(pos.col[1]+15,pos.col[1]+65) or pos.col[3]+40)
		self:y(IsUsingWideScreen() and pos.row[2]+55 or pos.row[3])
	end,
}

-- Player Profile HighScore value
af[#af+1] = LoadFont("Common Normal")..{
	Name="PlayerHighScore",
	InitCommand=function(self)
		self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
		self:x(IsUsingWideScreen() and pos.col[2]-5 or pos.col[3]+90)
		self:y(IsUsingWideScreen() and pos.row[2]+55 or pos.row[3])
	end,
	SetCommand=function(self) self:settext(player_score or "") end
}





return af