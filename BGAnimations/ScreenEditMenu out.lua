local t = Def.ActorFrame{
	OnCommand=cmd(sleep, 0.4);
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(diffuse,Color.Black; diffusealpha,0; zoomto,SCREEN_WIDTH,SCREEN_HEIGHT; Center);
	OnCommand=cmd(sleep,0.15; linear,0.3; diffusealpha,1);
}

return t;