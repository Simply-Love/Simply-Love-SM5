local player = ...
local pn = ToEnumShortString(player)

-- if the conditions aren't right, don't bother
if SL[pn].ActiveModifiers.TargetStatus ~= "Step Statistics" or SL.Global.Gamestate.Style ~= "single" or PREFSMAN:GetPreference("Center1Player") then
	return Def.Actor{ InitCommand=function(self) self:visible(false) end }
end

return Def.ActorFrame{
	InitCommand=function(self)
		self:x( _screen.w/4 * (player==PLAYER_1 and 3 or 1) )

		if SL.Global.GameMode == "StomperZ" then
			self:y(_screen.cy + 40)
		else
			self:y(_screen.cy + 80)
		end
	end,

	LoadActor("./BackgroundAndBanner.lua", player),
	LoadActor("./JudgmentLabels.lua", player),
	LoadActor("./JudgmentNumbers.lua", player),
}