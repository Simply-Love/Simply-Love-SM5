local player = ...
local rv
local zoom_factor = WideScale(0.8, 0.9)

local labelX_col1 = WideScale(-70, -90)
local dataX_col1 = WideScale(-75, -96)

local labelX_col2 = WideScale(10, 20)
local dataX_col2 = WideScale(5, 15)

local highscoreX = WideScale(56, 80)
local highscorenameX = WideScale(61, 97)

local PaneItems = {}

PaneItems[THEME:GetString("RadarCategory", "Taps")] = {
	-- "rc" is RadarCategory
	rc = "RadarCategory_TapsAndHolds",
	label = {
		x = labelX_col1,
		y = 150
	},
	data = {
		x = dataX_col1,
		y = 150
	}
}

PaneItems[THEME:GetString("RadarCategory", "Mines")] = {
	rc = "RadarCategory_Mines",
	label = {
		x = labelX_col2,
		y = 150
	},
	data = {
		x = dataX_col2,
		y = 150
	}
}

PaneItems[THEME:GetString("RadarCategory", "Jumps")] = {
	rc = "RadarCategory_Jumps",
	label = {
		x = labelX_col1,
		y = 168
	},
	data = {
		x = dataX_col1,
		y = 168
	}
}

PaneItems[THEME:GetString("RadarCategory", "Hands")] = {
	rc = "RadarCategory_Hands",
	label = {
		x = labelX_col2,
		y = 168
	},
	data = {
		x = dataX_col2,
		y = 168
	}
}

PaneItems[THEME:GetString("RadarCategory", "Holds")] = {
	rc = "RadarCategory_Holds",
	label = {
		x = labelX_col1,
		y = 186
	},
	data = {
		x = dataX_col1,
		y = 186
	}
}

PaneItems[THEME:GetString("RadarCategory", "Rolls")] = {
	rc = "RadarCategory_Rolls",
	label = {
		x = labelX_col2,
		y = 186
	},
	data = {
		x = dataX_col2,
		y = 186
	}
}
local FormatDate = function(scoredate)
	if scoredate == "" then
		return ""
	else
		local months = {}
		for i = 1, 12 do
			table.insert(months, THEME:GetString("Months", "Month" .. i))
		end
		local numbers = {}
		for number in string.gmatch(scoredate, "%d+") do
			numbers[#numbers + 1] = number
		end
		return numbers[2] .. "-" .. numbers[3] .. "-" .. numbers[1]
	end
end

local GetNameAndScoreAndDate = function(profile)
	local song = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
	local steps = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	local score = ""
	local name = ""
	local scoredate = ""
	if profile and song and steps then
		local scorelist = profile:GetHighScoreList(song, steps)
		local scores = scorelist:GetHighScores()
		local topscore = scores[1]

		if topscore then
			score = string.format("%.2f%%", topscore:GetPercentDP() * 100.0)
			name = topscore:GetName()
			scoredate = topscore:GetDate()
		else
			score = string.format("%.2f%%", 0)
			name = "????"
			scoredate = ""
		end
	end

	return score, name, scoredate
end

local af =
	Def.ActorFrame {
	InitCommand = function(self)
		self:visible(GAMESTATE:IsHumanPlayer(player))
		--TODO for now if there's only one player their pane display is on the left. We only put things on the right if two people are joined
	end,
	PlayerJoinedMessageCommand = function(self)
		self:visible(true)
	end,
	-- These playcommand("Set") need to apply to the ENTIRE panedisplay
	-- (all its children) so declare each here
	OnCommand = function(self)
		self:queuecommand("Set")
	end,
	CurrentCourseChangedMessageCommand = function(self)
		self:queuecommand("Set")
	end,
	StepsHaveChangedMessageCommand = function(self)
		self:queuecommand("Set")
	end,
	SetCommand = function(self)
		local machine_score, machine_name, machine_date = GetNameAndScoreAndDate(PROFILEMAN:GetMachineProfile())
		self:GetChild("MachineHighScore"):settext(machine_score)
		self:GetChild("MachineHighScoreName"):settext(machine_name):diffuse({0, 0, 0, 1})
		self:GetChild("MachineHighScoreDate"):settext(FormatDate(machine_date))
		DiffuseEmojis(self, machine_name)
		local player_score, player_name
		if PROFILEMAN:IsPersistentProfile(player) and GAMESTATE:GetCurrentSong() then --if there's no song there won't be a hash
			local hash = GetCurrentHash(player)
			if hash and GetScores(player, hash) then
				player_name = PROFILEMAN:GetProfile(player):GetDisplayName():upper()
				player_score = FormatPercentScore(GetScores(player, hash)[1].score)
			else --if we can't generate hashes (malformed SM/DWI/etc) we can't save scores so fallback on profile here
				player_score, player_name = GetNameAndScoreAndDate(PROFILEMAN:GetProfile(player))
			end
			self:GetChild("PlayerHighScore"):settext(player_score)
			self:GetChild("PlayerHighScoreName"):settext(player_name):diffuse({0, 0, 0, 1})

			DiffuseEmojis(self, player_name)
		end
	end
}

-- colored background for chart statistics
af[#af + 1] =
	Def.Quad {
	Name = "BackgroundQuad",
	InitCommand = function(self)
		self:zoomto(_screen.w / 2 - 10, _screen.h / 8):y(_screen.h / 2 - 67)
	end,
	SetCommand = function(self)
		if GAMESTATE:IsHumanPlayer(player) then
			local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)

			if StepsOrTrail then
				local difficulty = StepsOrTrail:GetDifficulty()
				self:diffuse(DifficultyColor(difficulty))
			else
				self:diffuse(PlayerColor(player))
			end
		end
	end
}

for key, item in pairs(PaneItems) do
	af[#af + 1] =
		Def.ActorFrame {
		Name = key,
		OnCommand = function(self)
			self:xy(-_screen.w / 20, 6)
		end,
		-- label
		LoadFont("Common Normal") ..
			{
				Text = key,
				InitCommand = function(self)
					self:zoom(zoom_factor):xy(item.label.x, item.label.y):diffuse(Color.Black):halign(0)
				end
			},
		--  numerical value
		LoadFont("Common Normal") ..
			{
				InitCommand = function(self)
					self:zoom(zoom_factor):xy(item.data.x, item.data.y):diffuse(Color.Black):halign(1)
				end,
				OnCommand = function(self)
					self:playcommand("Set")
				end,
				SetCommand = function(self)
					local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
					if not SongOrCourse then
						self:settext("?")
						return
					end

					local steps = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
					if steps then
						rv = steps:GetRadarValues(player)
						local val = rv:GetValue(item.rc)

						-- the engine will return -1 as the value for autogenerated content; show a question mark instead if so
						self:settext(val >= 0 and val or "?")
					else
						self:settext("")
					end
				end
			}
	}
end

-- chart difficulty meter
af[#af + 1] =
	LoadFont("_wendy small") ..
	{
		Name = "DifficultyMeter",
		InitCommand = function(self)
			self:horizalign(right):diffuse(Color.Black)
				:xy(_screen.w / 4 - 10, _screen.h / 2 - 65):queuecommand("Set")
		end,
		SetCommand = function(self)
			local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
			if not SongOrCourse then
				self:settext("")
				return
			end

			local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)
			local meter = StepsOrTrail and StepsOrTrail:GetMeter() or "?"
			self:settext(meter)
		end
	}

--PLAYER PROFILE high score
af[#af + 1] =
	LoadFont("Common Normal") ..
	{
		Name = "PlayerHighScore",
		InitCommand = function(self)
			self:xy(highscoreX, 156):zoom(zoom_factor):diffuse(Color.Black):halign(1)
		end
	}
--PLAYER PROFILE highscore name
af[#af + 1] =
	LoadFont("Common Normal") ..
	{
		Name = "PlayerHighScoreName",
		InitCommand = function(self)
			self:xy(highscorenameX, 156):zoom(zoom_factor):diffuse(Color.Black):halign(0):maxwidth(80)
		end
	}
--MACHINE high score
af[#af + 1] =
	LoadFont("Common Normal") ..
	{
		Name = "MachineHighScore",
		InitCommand = function(self)
			self:xy(highscoreX, 176):zoom(zoom_factor):diffuse(Color.Black):halign(1)
		end
	}

--MACHINE highscore name
af[#af + 1] =
	LoadFont("Common Normal") ..
	{
		Name = "MachineHighScoreName",
		InitCommand = function(self)
			self:xy(highscorenameX, 176):zoom(zoom_factor):diffuse(Color.Black):halign(0):maxwidth(80)
		end
	}

--MACHINE highscore date
af[#af + 1] =
	LoadFont("Common Normal") ..
	{
		Name = "MachineHighScoreDate",
		InitCommand = function(self)
			self:xy(highscoreX, 193):zoom(zoom_factor):diffuse(Color.Black):halign(0.5)
		end
	}
return af
