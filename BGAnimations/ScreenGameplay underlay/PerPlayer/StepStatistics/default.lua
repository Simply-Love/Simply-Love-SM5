local player = ...
local pn = ToEnumShortString(player)

-- if the conditions aren't right, don't bother
if SL[pn].ActiveModifiers.TargetStatus ~= "Step Statistics"
or SL.Global.Gamestate.Style ~= "single"
or SL.Global.GameMode == "Casual"
or GAMESTATE:GetCurrentStyle():GetStepsType() == "StepsType_Dance_Solo"
or (PREFSMAN:GetPreference("Center1Player") and not IsUsingWideScreen())
then
	return
end

return Def.ActorFrame{
	InitCommand=function(self)

		if (PREFSMAN:GetPreference("Center1Player") and IsUsingWideScreen()) then

			-- 16:9 aspect ratio (approximately 1.7778)
			if GetScreenAspectRatio() > 1.7 then
				self:x( _screen.w/4 * (player==PLAYER_1 and 3 or 1) + (70 * (player==PLAYER_1 and 1 or -1) ))
				self:zoom(0.925)

			-- if 16:10 aspect ratio
			else
				self:x( _screen.w/4 * (player==PLAYER_1 and 3 or 1) + (64 * (player==PLAYER_1 and 1 or -1) ))
				self:zoom(0.825)
			end
		else
			self:x( _screen.w/4 * (player==PLAYER_1 and 3 or 1) )
		end

		self:y(_screen.cy + 80)
	end,

	LoadActor("./BackgroundAndBanner.lua", player),
	LoadActor("./JudgmentLabels.lua", player),
	LoadActor("./JudgmentNumbers.lua", player),
	LoadActor("./DensityGraphs/default.lua", player),
}