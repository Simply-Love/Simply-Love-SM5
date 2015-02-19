return Def.ActorFrame{
	Name="Header",

	Def.Quad{
		InitCommand=cmd(x, _screen.cx; zoomto,_screen.w,40; ),
		OnCommand=cmd(diffuse,color("0.65,0.65,0.65,1"))
	},

	LoadFont("_wendy small")..{
		Name="HeaderText",
		InitCommand=cmd(diffusealpha,0; zoom,0.6; horizalign, left; addx, 10; settext,ScreenString("HeaderText")),
		OnCommand=cmd(decelerate,0.5; diffusealpha,1),
		OffCommand=cmd(accelerate,0.5; diffusealpha,0)
	}
}