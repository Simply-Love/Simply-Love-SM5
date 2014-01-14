local t = Def.ActorFrame{
	LoadFont("_wendy white")..{
		Text="Game";
		InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_CENTER_Y-40;croptop,1;fadetop,1; zoom,1.2);
		OnCommand=cmd(decelerate,0.5;croptop,0;fadetop,0;glow,color("1,1,1,1");decelerate,1;glow,color("1,1,1,0"););
		OffCommand=cmd(accelerate,0.5;fadeleft,1;cropleft,1);
	};
	LoadFont("_wendy white")..{
		Text="Over";
		InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_CENTER_Y+40;;croptop,1;fadetop,1; zoom,1.2);
		OnCommand=cmd(decelerate,0.5;croptop,0;fadetop,0;glow,color("1,1,1,1");decelerate,1;glow,color("1,1,1,0"););
		OffCommand=cmd(accelerate,0.5;fadeleft,1;cropleft,1);
	};
};

return t;