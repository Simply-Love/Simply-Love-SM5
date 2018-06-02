return Def.Quad {
	InitCommand=cmd(FullScreen),
	StartTransitioningCommand=cmd(diffusealpha,1; linear,0.4;diffusealpha,0)
}
