local player = ...
local pn = ToEnumShortString(player)

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
	col = { WideScale(-104,-133), WideScale(-36,-48), WideScale(36,45), WideScale(116, 146) },
	row = { 13, 31, 49 }
}

-- HighScores handled as special cases for now until further refactoring
local PaneItems = {
	-- first row
	{ name=THEME:GetString("RadarCategory","Taps"),  rc='RadarCategory_TapsAndHolds'},
	{ name=THEME:GetString("RadarCategory","Mines"), rc='RadarCategory_Mines'},
	{ name=THEME:GetString("ScreenSelectMusic","NPS") },
	-- second row
	{ name=THEME:GetString("RadarCategory","Jumps"), rc='RadarCategory_Jumps'},
	{ name=THEME:GetString("RadarCategory","Hands"), rc='RadarCategory_Hands'},
	{ name=THEME:GetString("RadarCategory","Lifts"), rc='RadarCategory_Lifts'},
	-- third row
	{ name=THEME:GetString("RadarCategory","Holds"), rc='RadarCategory_Holds'},
	{ name=THEME:GetString("RadarCategory","Rolls"), rc='RadarCategory_Rolls'},
	{ name=THEME:GetString("RadarCategory","Fakes"), rc='RadarCategory_Fakes'},
}

-- -----------------------------------------------------------------------

local af = Def.ActorFrame{ Name="PaneDisplay"..ToEnumShortString(player) }

af.InitCommand=function(self)
	self:visible(GAMESTATE:IsHumanPlayer(player))

	if player == PLAYER_1 then
		self:x(_screen.w * 0.25 - 5)
	elseif player == PLAYER_2 then
		self:x(_screen.w * 0.75 + 5)
	end

	self:y(_screen.h - footer_height - pane_height)
end

af.PlayerJoinedMessageCommand=function(self, params)
	if player==params.Player then
		self:visible(true)
		    :zoom(0):croptop(0):bounceend(0.3):zoom(1)
		    :playcommand("Update")
	end
end
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
		self:zoomtowidth(_screen.w/2-10)
		self:zoomtoheight(pane_height)
		self:vertalign(top)
	end,
	SetCommand=function(self, params)
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

for i, item in ipairs(PaneItems) do

	local col = ((i-1)%3) + 1
	local row = math.floor((i-1)/3) + 1

	af[#af+1] = Def.ActorFrame{

		Name=item.name,

		-- numerical value
		LoadFont("Common Normal")..{
			InitCommand=function(self)
				self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
				self:x(pos.col[col]-3)
				self:y(pos.row[row])
			end,

			SetCommand=function(self)
				if not SongOrCourse then self:settext("?"); return end
				if not StepsOrTrail then self:settext("");  return end

				if item.rc then
					local val = StepsOrTrail:GetRadarValues(player):GetValue( item.rc )
					-- the engine will return -1 as the value for autogenerated content; show a question mark instead if so
					self:settext( val >= 0 and val or "?" )


				-- only NPS ends up in this else block for now
				else
					if not SongOrCourse then self:settext(""); return end

					local seconds
					if GAMESTATE:IsCourseMode() then
						seconds = SongOrCourse:GetTotalSeconds(StepsOrTrail:GetStepsType())
					else
						-- song:MusicLengthSeconds() will return the duration of the music file as read from its metadata
						-- this may not accurately correspond with first note and late note in the stepchart
						-- if there is empty space at the start and/or end of the stepchart without notes
						-- So, let's prefer to use (LastSecond - FirstSecond)
						seconds = SongOrCourse:GetLastSecond() - SongOrCourse:GetFirstSecond()

						-- however, the engine initializes Song's member variable lastSecond to -1
						-- depending on how current engine-side parsing goes, it may never change from -1
						--
						-- for example:
						--   • use audacity to generate an ogg that is 5.000 seconds
						--   • use SM5's editor to set Song timing in the ssc file to 0.000 bpm at beat 0
						--   • do not specify any DisplayBPM; do not use steps timing
						--   • add a single quarter note at beat 0
						--
						-- GetFirstSecond() will return 0 and GetLastSecond() will return -1
						-- I'm not suggesting such stepcharts are reasonable, but they are possible.

						-- fall back on using MusicLengthSeconds in such cases
						-- having two different ways to determine seconds is inconsistent and confusing
						-- but I'm not sure what else to do here
						if seconds <= 0 then seconds = SongOrCourse:MusicLengthSeconds() end
					end

					-- FIXME: DOWNS4/ymbg currently shows 107.23 NPS here and 106.67 Peak NPS in gameplay's StepStats pane


					-- handle some circumstances by just bailing early and displaying a question mark
					-- ------------------------------------------------------------------
					-- the engine will return nil for GetTotalSeconds() on courses like "Most Played 01-04"
					if seconds == nil then self:settext("?"); return end
					-- don't allow division by zero
					if (seconds/SL.Global.ActiveModifiers.MusicRate) <= 0 then self:settext("?"); return end
					-- ------------------------------------------------------------------


					local totalnotes = StepsOrTrail:GetRadarValues(player):GetValue("RadarCategory_TapsAndHolds")
					local nps = totalnotes / (seconds/SL.Global.ActiveModifiers.MusicRate)

					-- NPS shouldn't be greater than the stepchart's total note count
					if nps > totalnotes then
						-- so far, I've only seen this occur when seconds is <1 and >0
						-- see: Crapyard Scent/Windows XP Critical Stop
						if seconds < 1 and seconds > 0 then
							seconds = SongOrCourse:MusicLengthSeconds()
							-- try again
							nps = totalnotes / (seconds/SL.Global.ActiveModifiers.MusicRate)
						end

						-- I sure hope we never get here, but I'll deal with it when we do.
						if nps > totalnotes then nps = totalnotes end
					end

					self:settext( ("%.2f"):format(nps) )
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


-- Machine HighScore value
af[#af+1] = LoadFont("Common Normal")..{
	Name="MachineHighScore",
	InitCommand=function(self)
		self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
		self:x(pos.col[4]-5)
		self:y(pos.row[1])
	end,
	SetCommand=function(self) self:settext(machine_score or "") end
}

-- Machine HighScore name
af[#af+1] = LoadFont("Common Normal")..{
	Name="MachineHighScoreName",
	InitCommand=function(self)
		self:zoom(text_zoom):diffuse(Color.Black):horizalign(left):maxwidth(80)
		self:x(pos.col[4]+5)
		self:y(pos.row[1])
	end,
	SetCommand=function(self)
		self:settext(machine_name or ""):diffuse(Color.Black)
		DiffuseEmojis(self)
	end
}


-- Player Profile HighScore value
af[#af+1] = LoadFont("Common Normal")..{
	Name="PlayerHighScore",
	InitCommand=function(self)
		self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
		self:x(pos.col[4]-5)
		self:y(pos.row[2])
	end,
	SetCommand=function(self) self:settext(player_score or "") end
}

-- Player Profile HighScore name
af[#af+1] = LoadFont("Common Normal")..{
	Name="PlayerHighScoreName",
	InitCommand=function(self)
		self:zoom(text_zoom):diffuse(Color.Black):horizalign(left):maxwidth(80)
		self:x(pos.col[4]+5)
		self:y(pos.row[2])
	end,
	SetCommand=function(self)
		self:settext(player_name or ""):diffuse(Color.Black)
		DiffuseEmojis(self)
	end
}

return af