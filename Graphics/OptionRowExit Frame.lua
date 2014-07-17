local t = Def.ActorFrame{};

-- a row
t[#t+1] = Def.Quad {
	OnCommand=cmd(zoomto,_screen.w*0.85,_screen.h*0.0625;);
};

return t;