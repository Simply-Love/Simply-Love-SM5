return Def.ActorFrame{
	Def.Quad{
		InitCommand=cmd(FullScreen;diffuse,color("#ffffff00")),
		OnCommand=cmd(decelerate,1; diffusealpha, 1)
	}
}