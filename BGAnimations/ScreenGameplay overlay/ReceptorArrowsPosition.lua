-- ReceptorArrow positions are hardcoded using Metrics.ini
-- in both Casual and Competitive modes.  If we're in one
-- of those modes, bail now.
if SL.Global.GameMode == "Casual" or SL.Global.GameMode == "Competitive" then
	return false
end

local player = ...

-- these numbers are relative to the ReceptorArrowsYStandard and ReceptorArrowsYReverse
-- positions already specified in Metrics
local ReceptorPositions = {
	Standard = {
		ITG = 45,
		StomperZ = 0
	},
	Reverse = {
		ITG = -30,
		StomperZ = 0
	}
}



return Def.Actor{
	InitCommand=function(self) self:queuecommand("Position") end,
	PositionCommand=function(self)

		local topscreen = SCREENMAN:GetTopScreen()
		local playeroptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")
		local p = ToEnumShortString(player)

		local scroll = playeroptions:UsingReverse() and "Reverse" or "Standard"
		local position = SL[p].ActiveModifiers.ReceptorArrowsPosition
		
		topscreen:GetChild('Player'..p):GetChild("NoteField"):addy( ReceptorPositions[scroll][position] )
	end
}