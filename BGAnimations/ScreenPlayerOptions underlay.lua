local t = Def.ActorFrame{
	OnCommand=cmd(diffusealpha,0; linear,0.2;diffusealpha,1);
	OffCommand=cmd(linear,0.2;diffusealpha,0);	
	
	Def.Quad{
		Name="ExplanationBackground";
		InitCommand=cmd(diffuse, color("0,0,0,0.5"); xy, SCREEN_CENTER_X, SCREEN_HEIGHT-57; );
		OnCommand=cmd(zoomto,SCREEN_WIDTH*0.935,SCREEN_HEIGHT*0.08;);
	}
};

return t;