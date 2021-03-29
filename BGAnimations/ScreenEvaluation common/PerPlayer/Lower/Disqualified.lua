local player = ...

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local disqualified = stats:IsDisqualified()

-- If the player was disqualified, return a BitmapText actor with localized text
-- like "Disqualified for Ranking".
if disqualified then
	return LoadFont("Common Bold")..{
		Name="Disqualified"..ToEnumShortString(player),
		Text=THEME:GetString("ScreenEvaluation","Disqualified"),
		InitCommand=function(self) self:diffusealpha(0.7):zoom(0.23):y(_screen.cy+138) end,
	}
end