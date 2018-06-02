return Def.Quad {
	InitCommand=cmd(FullScreen; diffuse, Color.Black; diffusealpha,0),
	StartTransitioningCommand=cmd(linear,0.2; diffusealpha,1)
}