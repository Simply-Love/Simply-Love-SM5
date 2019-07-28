return Def.ActorFrame{
	Def.Quad {
		InitCommand=cmd(diffuse, Color.Black; FullScreen),
		StartTransitioningCommand=cmd(diffusealpha,1;linear,0.4;diffusealpha,0)
	}
}