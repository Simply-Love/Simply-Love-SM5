return Def.ActorFrame{
	Def.Quad{
		InitCommand=cmd(x, SCREEN_CENTER_X; zoomto,SCREEN_WIDTH,40; );
		OnCommand=cmd(diffuse,color("0.65,0.65,0.65,0.8"); linear,0.15; diffusealpha,0;);
	};
};
