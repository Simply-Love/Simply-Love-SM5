return Def.ActorFrame{
	InitCommand=cmd(diffusealpha, 0),
	OnCommand=cmd( y, -20; sleep, 2; accelerate,0.2; diffusealpha,1; y, 10; decelerate,0.2; y,-5; accelerate,0.2; y,10 ),


	Def.BitmapText{
		Font="_miso",
		Text=THEME:GetString("GraphDisplay", "Barely"),
		InitCommand=cmd(zoom, 0.75),
	},

	Def.Sprite{
		Texture=THEME:GetPathB("ScreenSelectMusic", "overlay/PerPlayer/arrow.png"),
		InitCommand=cmd(rotationz,90; zoom,0.5; y,10; ),
		OnCommand=cmd(sleep,0.5; diffuseshift; effectcolor1,1,1,1,1; effectcolor2,1,1,1,0.2 )
	}
}