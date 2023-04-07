local player = ...

local _x = _screen.cx + (player==PLAYER_1 and -1 or 1) * SL_WideScale(292.5, 342.5)

return Def.ActorFrame{
	InitCommand=function(self)
		self:xy(_x, 56)
	end,


	-- colored background for player's chart's difficulty meter
	Def.Quad{
		InitCommand=function(self)
			self:zoomto(30, 30)
		end,
		CurrentSongChangedMessageCommand=function(self) self:queuecommand("Begin") end,
		BeginCommand=function(self)
			local currentSteps = GAMESTATE:GetCurrentSteps(player)
			if currentSteps then
				local currentDifficulty = currentSteps:GetDifficulty()
				self:diffuse(DifficultyColor(currentDifficulty))
			end
		end
	},

	-- player's chart's difficulty meter
	LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
		InitCommand=function(self)
			self:diffuse( Color.Black )
			self:zoom( 0.4 )
			self:y(-4)
		end,
		CurrentSongChangedMessageCommand=function(self) self:queuecommand("Begin") end,
		BeginCommand=function(self)
			local steps = GAMESTATE:GetCurrentSteps(player)
			local meter = steps:GetMeter()

			if meter then
				self:settext(meter)
			end
		end
	},

	LoadFont("Common Normal")..{
		InitCommand=function(self)
			self:diffuse( Color.Black )
			self:y(9.5)
			self:zoom( 0.5 )
			--self:y(_screen.cy-82)
			--self:x(149 * (player==PLAYER_1 and -1 or 1))
			--self:halign(pn)
			
			-- self:y(_screen.cy-83)
			-- self:x(129.5 * (player==PLAYER_1 and -1 or 1))
			-- --self:halign(0.5)
			-- :zoom(0.5)
			
			-- self:y(_screen.cy-61)
			-- self:x(129.5 * (player==PLAYER_1 and -1 or 1))
			-- self:halign(0.5):zoom(0.5)
		end,
		BeginCommand=function(self)
			local textColor = Color.Black
			local shadowLength = 0
			if ThemePrefs.Get("RainbowMode") and not HolidayCheer() then
				textColor = Color.Black
			end
			self:diffuse(textColor)
			self:shadowlength(shadowLength)

			local steps = GAMESTATE:GetCurrentSteps(player)
			-- GetDifficulty() returns a value from the Difficulty Enum such as "Difficulty_Hard"
			-- ToEnumShortString() removes the characters up to and including the
			-- underscore, transforming a string like "Difficulty_Hard" into "Hard"
			local difficulty = ToEnumShortString( steps:GetDifficulty() )
			difficulty = THEME:GetString("Difficulty", difficulty)
			--if difficulty == "Challenge" or difficulty == "Expert" then difficulty = "X"
			--else difficulty = difficulty:sub(1,1) end
			

			self:settext(difficulty)
		end
	}


}