local pn = ...;

-- tap note types
-- (iterating through the enum isn't a good idea as everything's backwards)
local TNSNames = {
	THEME:GetString("TapNoteScore","W1"),
	THEME:GetString("TapNoteScore","W2"),
	THEME:GetString("TapNoteScore","W3"),
	THEME:GetString("TapNoteScore","W4"),
	THEME:GetString("TapNoteScore","W5"),
	THEME:GetString("TapNoteScore","Miss"),
};
local Labels2 = {
	THEME:GetString("ScreenEvaluation", 'Holds'),
	THEME:GetString("ScreenEvaluation", 'Mines'),
	THEME:GetString("ScreenEvaluation", 'Hands'),
	THEME:GetString("ScreenEvaluation", 'Rolls')
};


local l = Def.ActorFrame{};
local x1,x2;

if pn == PLAYER_1 then
	x1 = 24;
	x2 = -160;
elseif pn == PLAYER_2 then
	x1 = -26;
	x2 = 90;
end		


--  labels: W1 ---> Miss
for i=1,#TNSNames do
	l[#l+1] = LoadFont("_misoreg hires")..{
		InitCommand=cmd(NoStroke;zoom,0.833; horizalign,right; x,x1);
		BeginCommand=function(self)
			self:y((i-1)*28 -16);
			self:settext(TNSNames[i]);
		end;
	};
end;

-- labels: holds, mines, hands, rolls
for i=1,#Labels2 do
	l[#l+1] = LoadFont("_misoreg hires")..{
		Text=Labels2[i];
		InitCommand=cmd(NoStroke;zoom,0.833; horizalign,right; x,x2);
		BeginCommand=function(self)
			self:y((i-1)*28 + 41);
		end;
	};
end

return l;
