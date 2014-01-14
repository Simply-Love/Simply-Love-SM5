return Def.Quad {
	InitCommand=cmd(FullScreen);
	StartTransitioningCommand=cmd(diffusealpha,0;sleep,0.1;linear,0.2;diffusealpha,1);
};