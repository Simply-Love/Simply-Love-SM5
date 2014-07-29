local pn = ...

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
local percent = stats:GetPercentDancePoints()

return LoadFont("_wendy white")..{
	Text=FormatPercentScore(percent),
	InitCommand=cmd(shadowlength,1)
}
