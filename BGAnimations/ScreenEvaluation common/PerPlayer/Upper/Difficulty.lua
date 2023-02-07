local player = ...
local pn = PlayerNumber:Reverse()[player]

return Def.ActorFrame{

	-- colored square as the background for the difficulty meter
	Def.Quad{
		InitCommand=function(self)
			self:zoomto(40,40)
			self:y( _screen.cy-76 )
			self:x(129.5 * (player==PLAYER_1 and -1 or 1))

			local currentSteps = GAMESTATE:GetCurrentSteps(player)
			if currentSteps then
				local currentDifficulty = currentSteps:GetDifficulty()
				self:diffuse( DifficultyColor(currentDifficulty), true )
			end
		end
	},

	-- numerical difficulty meter
	LoadFont("Common Bold")..{
		InitCommand=function(self)
			self:diffuse(Color.Black):zoom( 0.55 )
			self:y( _screen.cy-71 )
			self:x(129.5 * (player==PLAYER_1 and -1 or 1))
			
			self:y( _screen.cy-68 )
			self:x(129.5 * (player==PLAYER_1 and -1 or 1))
			
			self:y( _screen.cy-76 )
			self:x(129.5 * (player==PLAYER_1 and -1 or 1))

			local meter
			if GAMESTATE:IsCourseMode() then
				local trail = GAMESTATE:GetCurrentTrail(player)
				if trail then meter = trail:GetMeter() end
			else
				local steps = GAMESTATE:GetCurrentSteps(player)
				if steps then meter = steps:GetMeter() end
			end

			if meter then self:settext(meter) end
		end
	},
	
	-- difficulty text ("beginner" or "expert" or etc.)
	LoadFont("Common Normal")..{
		InitCommand=function(self)
			self:y(_screen.cy-82)
			self:x(149 * (player==PLAYER_1 and -1 or 1))
			self:halign(pn):zoom(0.4)
			
			self:y(_screen.cy-89)
			self:x(137.5 * (player==PLAYER_1 and -1 or 1))
			self:halign(pn):zoom(0.3)
			
			self:y(_screen.cy-92)
			self:x(129.5 * (player==PLAYER_1 and -1 or 1))
			self:halign(0.5):zoom(0.5)

			local textColor = Color.Black
			local shadowLength = 0
			if ThemePrefs.Get("RainbowMode") and not HolidayCheer() then
				textColor = Color.Black
			end
			self:diffuse(textColor)
			self:shadowlength(shadowLength)

			local style = GAMESTATE:GetCurrentStyle():GetName()
			if style == "versus" then style = "single" end
			style =  THEME:GetString("ScreenSelectMusic", style:gsub("^%l", string.upper))

			self:settext( style )
		end
	},
	
	LoadFont("Common Normal")..{
		InitCommand=function(self)
			self:y(_screen.cy-82)
			self:x(149 * (player==PLAYER_1 and -1 or 1))
			self:halign(pn):zoom(0.4)
			
			self:y(_screen.cy-83)
			self:x(129.5 * (player==PLAYER_1 and -1 or 1))
			self:halign(0.5):zoom(0.5)
			
			self:y(_screen.cy-61)
			self:x(129.5 * (player==PLAYER_1 and -1 or 1))
			self:halign(0.5):zoom(0.5)

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
