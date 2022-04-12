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
	LoadFont("Common Bold")..{
		InitCommand=function(self)
			self:diffuse( Color.Black )
			self:zoom( 0.4 )
		end,
		CurrentSongChangedMessageCommand=function(self) self:queuecommand("Begin") end,
		BeginCommand=function(self)
			local steps = GAMESTATE:GetCurrentSteps(player)
			local meter = steps:GetMeter()

			if meter then
				self:settext(meter)
			end
		end
	}
}