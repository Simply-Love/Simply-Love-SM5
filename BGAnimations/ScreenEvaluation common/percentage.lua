local pn = ...;

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn);
local percent = stats:GetPercentDancePoints();

return LoadFont("_wendy white")..{
	Name="Score"..pn;
	Text=FormatPercentScore(percent);
	InitCommand=cmd(NoStroke;shadowlength,1);
	BeginCommand=function(self)
		
		local text = self:GetText();
		local diff;

		if GAMESTATE:IsCourseMode() then
			diff = GAMESTATE:GetCurrentTrail(pn):GetDifficulty();
		else
			diff = GAMESTATE:GetCurrentSteps(pn):GetDifficulty();
		end;
	end;
};
