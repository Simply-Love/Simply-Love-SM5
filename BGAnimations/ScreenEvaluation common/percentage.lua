local pn = ...;

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn);
local percent = stats:GetPercentDancePoints();

return LoadFont("_wendy white")..{
	Name="Score"..pn;
	Text=FormatPercentScore(percent);
	InitCommand=cmd(NoStroke;shadowlength,1);
};
