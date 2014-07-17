local t = Def.ActorFrame{};

-- a row
t[#t+1] = Def.Quad {
	OnCommand=cmd(zoomto,_screen.w*0.85,_screen.h*0.0625;);
};

-- black quad behind the title
t[#t+1] = Def.Quad {
	OnCommand=cmd(halign, 0; x, -_screen.cx/1.1775; zoomto,_screen.w*WideScale(0.18,0.15),_screen.h*0.0625; diffuse, Color.Black; diffusealpha,0.25);
};

return t;