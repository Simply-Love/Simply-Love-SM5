return Def.ActorFrame{
	Name="Header",

	Def.Quad{
		InitCommand=cmd(zoomto, _screen.w, 32; vertalign, top; diffuse,0.65,0.65,0.65,1; x, _screen.cx),
	},

	Def.BitmapText{
		Name="HeaderText",
		Font="_wendy small",
		Text=ScreenString("HeaderText"),
		InitCommand=cmd(diffusealpha,0; zoom,0.6; horizalign, left; xy, 10, 14 ),
		OnCommand=cmd(sleep, 0.1; decelerate,0.33; diffusealpha,1),
		OffCommand=cmd(accelerate,0.33; diffusealpha,0)
	}
}