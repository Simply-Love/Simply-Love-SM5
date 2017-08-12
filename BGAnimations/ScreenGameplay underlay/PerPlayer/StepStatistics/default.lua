local player = ...
local pn = ToEnumShortString(player)

-- if the conditions aren't right, don't bother
if SL[pn].ActiveModifiers.TargetStatus ~= "Step Statistics"
or SL.Global.Gamestate.Style ~= "single"
or SL.Global.GameMode == "Casual"
or PREFSMAN:GetPreference("Center1Player")
then
	return Def.Actor{ InitCommand=function(self) self:visible(false) end }
end

return Def.ActorFrame{
	InitCommand=function(self)
		self:x( _screen.w/4 * (player==PLAYER_1 and 3 or 1) )
			:y(_screen.cy + 80)
	end,

	LoadActor("./BackgroundAndBanner.lua", player),
	LoadActor("./JudgmentLabels.lua", player),
	LoadActor("./JudgmentNumbers.lua", player),
	LoadActor("./DensityGraphs/default.lua", player),
}