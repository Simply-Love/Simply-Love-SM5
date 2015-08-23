local player = ...
local pn = PlayerNumber:Reverse()[player]

return Def.ActorFrame{

	-- difficulty text ("beginner" or "expert" or etc.)
	LoadFont("_miso")..{
		OnCommand=function(self)

			self:y(_screen.cy-64)
			self:x( (player == PLAYER_1 and -115) or 115 )
			self:halign(pn)
			self:zoom(0.7)

			local currentSteps = GAMESTATE:GetCurrentSteps(player)

			if currentSteps then
				local difficulty = currentSteps:GetDifficulty();
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
		InitCommand=cmd(zoomto,30,30),
		OnCommand=function(self)
			self:y( _screen.cy-71 )
			self:x( (player == PLAYER_1 and -134.5) or 134.5 )

			local currentSteps = GAMESTATE:GetCurrentSteps(player)
			if currentSteps then
				local currentDifficulty = currentSteps:GetDifficulty()
				self:diffuse( DifficultyColor(currentDifficulty) )
			end
		end
	},

	-- numerical difficulty meter
	LoadFont("_wendy small")..{
		InitCommand=cmd(diffuse, Color.Black ),
		OnCommand=function(self)
			self:zoom( 0.4 )
			self:y( _screen.cy-71 )
			self:x( (player == PLAYER_1 and -134.5) or 134.5 )

			local meter
			if GAMESTATE:IsCourseMode() then
				local trail = GAMESTATE:GetCurrentTrail(player)
				if trail then
					meter = trail:GetMeter()
				end
			else
				local steps = GAMESTATE:GetCurrentSteps(player)
				if steps then
					meter = steps:GetMeter()
				end
			end

			if meter then
				self:settext(meter)
			end
		end
	}
}