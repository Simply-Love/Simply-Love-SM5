local player = ...
local pn = PlayerNumber:Reverse()[player]

return Def.ActorFrame{

	-- difficulty text ("beginner" or "expert" or etc.)
	LoadFont("Common Normal")..{
		InitCommand=function(self)
			self:y(_screen.cy-64)
			self:x(115 * (player==PLAYER_1 and -1 or 1))
			self:halign(pn):zoom(0.7)
			-- darken the text for RainbowMode to make it more legible
			if ThemePrefs.Get("RainbowMode") then self:diffuse(Color.Black) end

			local currentSteps = GAMESTATE:GetCurrentSteps(player)

			if currentSteps then
				local difficulty = currentSteps:GetDifficulty()
				-- GetDifficulty() returns a value from the Difficulty Enum
				-- "Difficulty_Hard" for example.
				-- Strip the characters up to and including the underscore.
				difficulty = ToEnumShortString(difficulty)
				self:settext( THEME:GetString("Difficulty", difficulty) )
			end
		end
	},

	-- colored square as the background for the difficulty meter
	Def.Quad{
		InitCommand=function(self)
			self:zoomto(30,30)
			self:y( _screen.cy-71 )
			self:x(134.5 * (player==PLAYER_1 and -1 or 1))

			local currentSteps = GAMESTATE:GetCurrentSteps(player)
			if currentSteps then
				local currentDifficulty = currentSteps:GetDifficulty()
				self:diffuse( DifficultyColor(currentDifficulty) )
			end
		end
	},

	-- numerical difficulty meter
	LoadFont("_wendy small")..{
		InitCommand=function(self)
			self:diffuse(Color.Black):zoom( 0.4 )
			self:y( _screen.cy-71 )
			self:x(134.5 * (player==PLAYER_1 and -1 or 1))

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
	}
}