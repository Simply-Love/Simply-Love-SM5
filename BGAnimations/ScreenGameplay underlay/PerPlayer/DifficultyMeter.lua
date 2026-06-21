local player = ...
local pn = ToEnumShortString(player)

-- Portrait: top-right corner (see Positions). Landscape: beside the notefield.
local _x = Positions.ScreenGameplay.DifficultyMeterX(player)

return Def.ActorFrame{
	InitCommand=function(self)
		-- In portrait the meter is a fixed corner element, so don't shift it by
		-- the per-player NoteFieldOffsetX (that follows the centered notefield).
		local adjusted_offset_x = IsVerticalScreen() and 0
			or (SL[pn].ActiveModifiers.NoteFieldOffsetX * (player == PLAYER_1 and -1 or 1))
		self:xy(_x + adjusted_offset_x, Positions.ScreenGameplay.DifficultyMeterY())
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