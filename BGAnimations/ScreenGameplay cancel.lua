local t = Def.ActorFrame {
	Def.Quad{
		InitCommand=cmd(FullScreen;diffuse,color("0,0,0,0"););
		OnCommand=cmd(linear,0.4;diffusealpha,1);
	};
};

return t;
