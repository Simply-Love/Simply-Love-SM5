return Def.ActorFrame{
	InitCommand=function(self) self:draworder(200) end,

	Def.Quad{
		InitCommand=cmd(diffuse,Color.Black; FullScreen; diffusealpha,0 ),
		OffCommand=cmd(cropbottom,1; fadebottom,.5; linear,0.3; cropbottom,-0.5; diffusealpha,1)
	},

	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenSelectMusic","Press Start for Options"),
		InitCommand=cmd(Center; zoom,0.75 ),
		OnCommand=cmd(visible, false),
		ShowPressStartForOptionsCommand=cmd(visible,true;),
		ShowEnteringOptionsCommand=cmd(linear,0.125; diffusealpha,0; queuecommand, "NewText"),
		NewTextCommand=cmd(hibernate,0.1; settext,THEME:GetString("ScreenSelectMusic", "Entering Options..."); linear,0.125; diffusealpha,1; hurrytweening,0.1; sleep,1)
	},
}
