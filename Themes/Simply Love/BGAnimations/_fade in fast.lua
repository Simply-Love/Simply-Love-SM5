return Def.Quad {
	InitCommand=cmd(FullScreen);
	StartTransitioningCommand=cmd(diffusealpha,1;linear,0.2;diffusealpha,0);
};
