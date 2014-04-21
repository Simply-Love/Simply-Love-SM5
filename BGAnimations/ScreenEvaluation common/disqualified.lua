local pn = ...;

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn);
local disqualified = stats:IsDisqualified();

local s = "";

return LoadFont("_misoreg hires")..{
	Name="Disqualified"..ToEnumShortString(pn);
	Text="";
	InitCommand=cmd(shadowlength,1;diffuse,color("0.9,0,0,1");zoom,0.8;);
	OnCommand=function(self)		
		if disqualified then
			self:settext("Disqualified");
		end;
	end;
};


