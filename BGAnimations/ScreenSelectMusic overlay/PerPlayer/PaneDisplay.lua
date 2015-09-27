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
local highscorenameX = WideScale(84, 120)

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


local pd = Def.ActorFrame{
	Name="PaneDisplay"..ToEnumShortString(player),

	InitCommand=function(self)

		self:visible(false)
		if GAMESTATE:IsHumanPlayer(player) then
			self:visible(true)
		end

		if player == PLAYER_1 then
			self:x(_screen.w * 0.25 - 5)
		elseif player == PLAYER_2 then
			self:x( _screen.w * 0.75 + 5)
		end

		self:y(_screen.h/2 + 5)
		self:queuecommand("Set")
	end,

	PlayerJoinedMessageCommand=function(self, params)

		if player==params.Player then
			self:visible(true)
			self:zoom(0)
			self:bounceend(0.3)
			self:zoom(1)
			self:playcommand("Set")
		end
	end,

	-- These playcommand("Set") need to apply to the ENTIRE panedisplay
	-- (all its children) so declare each here
	OnCommand=cmd(queuecommand,"Set"),
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set"),
	CurrentCourseChangedMessageCommand=cmd(queuecommand,"Set"),
	StepsHaveChangedCommand=cmd(queuecommand,"Set"),
	SetCommand=function(self)
		local machine_score, machine_name = GetNameAndScore( PROFILEMAN:GetMachineProfile() )
		self:GetChild("MachineHighScore"):settext(machine_score)
		self:GetChild("MachineHighScoreName"):settext(machine_name)

		if PROFILEMAN:IsPersistentProfile(player) then
			local player_score, player_name = GetNameAndScore( PROFILEMAN:GetProfile(player) )
			self:GetChild("PlayerHighScore"):settext(player_score)
			self:GetChild("PlayerHighScoreName"):settext(player_name)
		end
	end
}

-- colored background for chart statistics
pd[#pd+1] = Def.Quad{
	Name="BackgroundQuad",
	InitCommand=cmd(zoomto, _screen.w/2-10, _screen.h/8; y, _screen.h/3 + 15.33 ),
	SetCommand=function(self, params)
		if GAMESTATE:IsHumanPlayer(player) then
			local steps = GAMESTATE:GetCurrentSteps(player)
			if steps then
				local difficulty = steps:GetDifficulty()
				self:diffuse( DifficultyColor(difficulty) )
			else
				self:diffuse( PlayerColor(player) )
			end
		end
	end
}



for key, item in pairs(PaneItems) do

	pd[#pd+1] = Def.ActorFrame{

		Name=key,
		OnCommand=cmd(x, -_screen.w/20; y,6 ),

		-- label
		LoadFont("_miso")..{
			Text=key,
			InitCommand=cmd(zoom, zoom_factor; xy, item.label.x, item.label.y; diffuse, Color.Black; shadowlength, 0.2; halign, 0)
		},
		--  numerical value
		LoadFont("_miso")..{
			InitCommand=cmd(zoom, zoom_factor; xy, item.data.x, item.data.y; diffuse, Color.Black; shadowlength, 0.2; halign, 1),
			OnCommand=cmd(playcommand, "Set"),
			SetCommand=function(self)

				local song = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
				if not song then
					self:settext("?")
					return
				end

				local steps = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
				if steps then
					rv = steps:GetRadarValues(player)
					local val = rv:GetValue( item.rc )

					-- negative ones show up for autogenerated content
					-- show a question mark instead
					if val == -1 then
						self:settext("?")
					else
						self:settext( val )
					end
				else
					self:settext( "" )
				end
			end
		}
	}
end

-- chart difficulty meter
pd[#pd+1] = Def.BitmapText{
	Font="_wendy small",
	Name="DifficultyMeter",
	InitCommand=cmd(horizalign, right; diffuse, Color.Black; xy, _screen.w/4 - 10, _screen.h/2 - 65; queuecommand, "Set"),
	SetCommand=function(self)
		local song = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
		if not song then
			self:settext("")
		else
			local steps = GAMESTATE:GetCurrentSteps(player)
			self:settext( steps and steps:GetMeter() or  "?" )
		end
	end
}

--MACHINE high score
pd[#pd+1] = Def.BitmapText{
	Font="_miso",
	Name="MachineHighScore",
	InitCommand=cmd(x, highscoreX; y, 156; zoom, zoom_factor; diffuse, Color.Black; halign, 1 )
}

--MACHINE highscore name
pd[#pd+1] = Def.BitmapText{
	Font="_miso",
	Name="MachineHighScoreName",
	InitCommand=cmd(x, highscorenameX; y, 156; zoom, zoom_factor; diffuse, Color.Black; halign, 1; maxwidth, 60)
}


--PLAYER PROFILE high score
pd[#pd+1] = Def.BitmapText{
	Font="_miso",
	Name="PlayerHighScore",
	InitCommand=cmd(x, highscoreX; y, 176; zoom, zoom_factor; diffuse, Color.Black; halign, 1 )
}

--PLAYER PROFILE highscore name
pd[#pd+1] = Def.BitmapText{
	Font="_miso",
	Name="PlayerHighScoreName",
	InitCommand=cmd(x, highscorenameX; y, 176; zoom, zoom_factor; diffuse, color("0,0,0,1"); halign, 1)
}

return pd