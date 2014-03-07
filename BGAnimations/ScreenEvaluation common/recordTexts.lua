local pn = ...;

local r = Def.ActorFrame{};
local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn);

-- note: only shows top score
local highScoreIndex = {
	Machine = stats:GetMachineHighScoreIndex(),
	Personal = stats:GetPersonalHighScoreIndex(),
}

local bMachineRecord  = (  highScoreIndex.Machine ~= -1 ) and stats:GetPercentDancePoints() >= 0.01;
local bPersonalRecord = ( highScoreIndex.Personal ~= -1 ) and stats:GetPercentDancePoints() >= 0.01;

r[#r+1] = LoadFont("_wendy small")..{
	Text=string.format("Machine Record %i", highScoreIndex.Machine+1);
	InitCommand=cmd(halign,0; xy,-110,-4; zoom,0.5;shadowlength,1;diffuse,PlayerColor(pn);NoStroke;glowshift;effectcolor1,color("1,1,1,0");effectcolor2,color("1,1,1,0.25"));
	BeginCommand=cmd(visible,bMachineRecord;);
};

r[#r+1] = LoadFont("_wendy small")..{
	Text=string.format("Personal Record %i", highScoreIndex.Personal+1);
	InitCommand=cmd(halign,0; xy,-110,18; zoom,0.5;shadowlength,1;diffuse,PlayerColor(pn);NoStroke;glowshift;effectcolor1,color("1,1,1,0");effectcolor2,color("1,1,1,0.25"));
	BeginCommand=cmd(visible,bPersonalRecord;);
};

return r;
