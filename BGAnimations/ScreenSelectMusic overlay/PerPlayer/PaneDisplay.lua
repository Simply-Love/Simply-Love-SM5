local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

local rv
local zoom_factor = WideScale(0.8,0.9)

local labelX_col1 = WideScale(-70,-90)
local dataX_col1  = WideScale(-75,-96)

local labelX_col2 = WideScale(10,20)
local dataX_col2  = WideScale(5,15)

local highscoreX = WideScale(56, 80)
local highscorenameX = WideScale(61, 97)

local PaneItems = {}

PaneItems[THEME:GetString("RadarCategory","Taps")] = {
	-- "rc" is RadarCategory
	rc = 'RadarCategory_TapsAndHolds',
	label = {
		x = labelX_col1,
		y = 150,
	},
	data = {
		x = dataX_col1,
		y = 150
	}
}

PaneItems[THEME:GetString("RadarCategory","Mines")] = {
	rc = 'RadarCategory_Mines',
	label = {
		x = labelX_col2,
		y = 150,
	},
	data = {
		x = dataX_col2,
		y = 150
	}
}

PaneItems[THEME:GetString("RadarCategory","Jumps")] = {
	rc = 'RadarCategory_Jumps',
	label = {
		x = labelX_col1,
		y = 168,
	},
	data = {
		x = dataX_col1,
		y = 168
	}
}

PaneItems[THEME:GetString("RadarCategory","Hands")] = {
	rc = 'RadarCategory_Hands',
	label = {
		x = labelX_col2,
		y = 168,
	},
	data = {
		x = dataX_col2,
		y = 168
	}
}

PaneItems[THEME:GetString("RadarCategory","Holds")] = {
	rc = 'RadarCategory_Holds',
	label = {
		x = labelX_col1,
		y = 186,
	},
	data = {
		x = dataX_col1,
		y = 186
	}
}

PaneItems[THEME:GetString("RadarCategory","Rolls")] = {
	rc = 'RadarCategory_Rolls',
	label = {
		x = labelX_col2,
		y = 186,
	},
	data = {
		x = dataX_col2,
		y = 186
	}
}


local GetNameAndScore = function(profile)
	local song = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
	local steps = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	local score = ""
	local name = ""

	if profile and song and steps then
		local scorelist = profile:GetHighScoreList(song,steps)
		local scores = scorelist:GetHighScores()
		local topscore = scores[1]

		if topscore then
			score = string.format("%.2f%%", topscore:GetPercentDP()*100.0)
			name = topscore:GetName()
		else
			score = string.format("%.2f%%", 0)
			name = "????"
		end
	end

	return score, name
end


local af = Def.ActorFrame{
	Name="PaneDisplay"..ToEnumShortString(player),

	InitCommand=function(self)
		self:visible(GAMESTATE:IsHumanPlayer(player))

		if player == PLAYER_1 then
			self:x(_screen.w * 0.25 - 5)
		elseif player == PLAYER_2 then
			self:x( _screen.w * 0.75 + 5)
		end

		self:y(_screen.cy + 5)
	end,

	PlayerJoinedMessageCommand=function(self, params)
		if player==params.Player then
			self:visible(true)
				:zoom(0):croptop(0):bounceend(0.3):zoom(1)
				:playcommand("Set")
		end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if player==params.Player then
			self:accelerate(0.3):croptop(1):sleep(0.01):zoom(0)
		end
	end,

	-- These playcommand("Set") need to apply to the ENTIRE panedisplay
	-- (all its children) so declare each here
	OnCommand=function(self) self:queuecommand("Set") end,
	CurrentSongChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentCourseChangedMessageCommand=function(self) self:queuecommand("Set") end,
	StepsHaveChangedCommand=function(self) self:queuecommand("Set") end,

	SetCommand=function(self)
		local machine_score, machine_name = GetNameAndScore( PROFILEMAN:GetMachineProfile() )

		self:GetChild("MachineHighScore"):settext(machine_score)
		self:GetChild("MachineHighScoreName"):settext(machine_name):diffuse({0,0,0,1})

		DiffuseEmojis(self, machine_name)

		if PROFILEMAN:IsPersistentProfile(player) then
			local player_score, player_name = GetNameAndScore( PROFILEMAN:GetProfile(player) )

			self:GetChild("PlayerHighScore"):settext(player_score)
			self:GetChild("PlayerHighScoreName"):settext(player_name):diffuse({0,0,0,1})

			DiffuseEmojis(self, player_name)
		end
	end
}

-- colored background for chart statistics
af[#af+1] = Def.Quad{
	Name="BackgroundQuad",
	InitCommand=function(self) self:zoomto(_screen.w/2-10, _screen.h/8):y(_screen.h/2 - 67) end,
	SetCommand=function(self, params)
		if GAMESTATE:IsHumanPlayer(player) then
			local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)

			if StepsOrTrail then
				local difficulty = StepsOrTrail:GetDifficulty()
				self:diffuse( DifficultyColor(difficulty) )
			else
				self:diffuse( PlayerColor(player) )
			end
		end
	end
}



for key, item in pairs(PaneItems) do

	af[#af+1] = Def.ActorFrame{

		Name=key,
		OnCommand=function(self) self:xy(-_screen.w/20, 6) end,

		-- label
		LoadFont("Common Normal")..{
			Text=key,
			InitCommand=function(self) self:zoom(zoom_factor):xy(item.label.x, item.label.y):diffuse(Color.Black):horizalign(left) end
		},
		--  numerical value
		LoadFont("Common Normal")..{
			InitCommand=function(self) self:zoom(zoom_factor):xy(item.data.x, item.data.y):diffuse(Color.Black):horizalign(right) end,
			OnCommand=function(self) self:playcommand("Set") end,
			SetCommand=function(self)
				local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
				if not SongOrCourse then self:settext("?"); return end

				local steps = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
				if steps then
					rv = steps:GetRadarValues(player)
					local val = rv:GetValue( item.rc )

					-- the engine will return -1 as the value for autogenerated content; show a question mark instead if so
					self:settext( val >= 0 and val or "?" )
				else
					self:settext( "" )
				end
			end
		}
	}
end

-- chart difficulty meter
af[#af+1] = LoadFont("_wendy small")..{
	Name="DifficultyMeter",
	InitCommand=function(self) self:horizalign(right):diffuse(Color.Black):xy(_screen.w/4 - 10, _screen.h/2 - 65):queuecommand("Set") end,
	SetCommand=function(self)
		local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
		if not SongOrCourse then self:settext(""); return end

		local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)
		local meter = StepsOrTrail and StepsOrTrail:GetMeter() or "?"
		self:settext( meter )
	end
}

--MACHINE high score
af[#af+1] = LoadFont("Common Normal")..{
	Name="MachineHighScore",
	InitCommand=function(self) self:x(highscoreX):y(156):zoom(zoom_factor):diffuse(Color.Black):horizalign(right) end
}

--MACHINE highscore name
af[#af+1] = LoadFont("Common Normal")..{
	Name="MachineHighScoreName",
	InitCommand=function(self) self:x(highscorenameX):y(156):zoom(zoom_factor):diffuse(Color.Black):horizalign(left):maxwidth(80) end
}


--PLAYER PROFILE high score
af[#af+1] = LoadFont("Common Normal")..{
	Name="PlayerHighScore",
	InitCommand=function(self) self:x(highscoreX):y(176):zoom(zoom_factor):diffuse(Color.Black):horizalign(right) end
}

--PLAYER PROFILE highscore name
af[#af+1] = LoadFont("Common Normal")..{
	Name="PlayerHighScoreName",
	InitCommand=function(self) self:x(highscorenameX):y(176):zoom(zoom_factor):diffuse(Color.Black):horizalign(left):maxwidth(80) end
}

return af