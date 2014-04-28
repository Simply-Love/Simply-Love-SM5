local t = Def.ActorFrame{};

-- a row
t[#t+1] = Def.Quad {
	OnCommand=cmd(zoomto,200,SCREEN_HEIGHT*0.05;);
};

return t;