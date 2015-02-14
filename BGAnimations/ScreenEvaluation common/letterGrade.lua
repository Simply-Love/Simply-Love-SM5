local pn = ...;

local playerStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn);
local grade = playerStats:GetGrade()

return LoadActor(THEME:GetPathG("", "_grades/"..grade..".lua"), playerStats);
