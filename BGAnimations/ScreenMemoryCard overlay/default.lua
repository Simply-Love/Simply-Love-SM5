return Def.ActorFrame{
	InitCommand=function(self) self:Center() end,

	LoadActor("usbicon.png")..{
		InitCommand=function(self) self:shadowlength(1) end,
		OnCommand=cmd(zoom,0.6; glow,1,1,1,1; glowshift; diffusealpha,0; sleep,1.0; decelerate,2; diffusealpha,1;sleep,6;linear,0.75;diffusealpha,0),
		OffCommand=cmd(stoptweening;accelerate,0.5;addx,-_screen.w*1.5)
	},

	LoadFont("_miso")..{
		Text=ScreenString("Top"),
		InitCommand=function(self) self:shadowlength(1):y(-60):diffusealpha(0) end,
		OnCommand=cmd(sleep,2.0; decelerate,1; diffusealpha,1; sleep,6; linear,0.75; diffusealpha,0),
		OffCommand=cmd(stoptweening;accelerate,0.5;addx,-_screen.w*1.5)
	},

	LoadFont("_miso")..{
		Text=ScreenString("Bottom"),
		InitCommand=function(self) self:shadowlength(1):y(60):diffusealpha(0) end,
		OnCommand=cmd(sleep,3.0; decelerate,1; diffusealpha,1; sleep,5; linear,0.75; diffusealpha,0),
		OffCommand=cmd(stoptweening;accelerate,0.5;addx,-_screen.w*1.5)
	}
}