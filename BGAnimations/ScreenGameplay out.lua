local t = Def.ActorFrame {
	Def.Quad{
		InitCommand=cmd(FullScreen;diffuse,color("0,0,0,0"););
		OnCommand=cmd(sleep,0.5;linear,1;diffusealpha,1);
	};
};

return t;
