local t = Def.ActorFrame{};

-- a row
t[#t+1] = Def.Quad {
	OnCommand=cmd(zoomto,SCREEN_WIDTH*0.85,SCREEN_HEIGHT*0.0625;);
};

return t;