-- I don't want disqualification to apply to Casual mode; it's too discouraging
-- for novice players and this game is already offputting enough as-is.
-- If we're in Casual mode, return early; don't evaluate the rest of this file.
if SL.Global.GameMode == "Casual" then return end
-- -----------------------------------------------------------------------

local player = ...

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local disqualified = stats:IsDisqualified()

-- If the player was disqualified, return a BitmapText actor with localized text
-- like "Disqualified for Ranking".
if disqualified then
	return LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
		Name="Disqualified"..ToEnumShortString(player),
		Text=THEME:GetString("ScreenEvaluation","Disqualified"),
		InitCommand=function(self) self:diffusealpha(0.7):zoom(0.23):y(_screen.cy+138) end,
	}
end