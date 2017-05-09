return Def.Quad {
	InitCommand=cmd(FullScreen),
	StartTransitioningCommand=cmd(stretchto,SCREEN_LEFT,SCREEN_TOP,SCREEN_RIGHT,SCREEN_BOTTOM;diffuse,0,0,0,1;linear,.5;diffusealpha,0)
}
