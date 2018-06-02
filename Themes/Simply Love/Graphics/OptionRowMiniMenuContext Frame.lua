local t = Def.ActorFrame{};

-- a row
t[#t+1] = Def.Quad {
	OnCommand=cmd(zoomto,200,_screen.h*0.05;);
};

return t;