local pn = ...;

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn);
local disqualified = stats:IsDisqualified();

local s = "";

return LoadFont("_wendy small")..{
	Name="Disqualified"..ToEnumShortString(pn);
	InitCommand=cmd(diffuse,color("1,1,1,0.7");zoom,0.23;);
	OnCommand=function(self)		
		if disqualified then
			self:settext(THEME:GetString("ScreenEvaluation","Disqualified"));
		end;
	end;
};


