return Def.ActorFrame{
	Name="StartButton",
	OnCommand=cmd(diffusealpha, 0; xy,_screen.cx, _screen.h-76),
	SwitchFocusToSongsMessageCommand=cmd(linear,0.1; diffusealpha,0),
	SwitchFocusToGroupsMessageCommand=cmd(linear,0.1; diffusealpha,0),
	SwitchFocusToSingleSongMessageCommand=cmd(sleep,0.3; linear,0.1; diffusealpha,1),

	LoadActor("./img/start_glow.png")..{
		Name="Glow",
		InitCommand=cmd(diffusealpha,1; zoom, 0.15 ),
		OnCommand=cmd( diffuseshift; effectcolor1,color("#55CC5500"); effectcolor2,color("#55CC55FF")),
	},

	Def.Quad{
		Name="Quad",
		InitCommand=cmd( diffuseshift; effectcolor1,color("#33aa33"); effectcolor2,color("#55cc55"); zoomto, 75, 33),
	},

	LoadFont("_miso")..{
		Name="Text",
		Text=THEME:GetString("ScreenSelectMusicCasual", "Press"),
		InitCommand=cmd(diffuse, Color.Black; zoom, 0.95),
		SwitchFocusToSingleSongMessageCommand=cmd(settext, THEME:GetString("ScreenSelectMusicCasual", "Press")),
		BothPlayersAreReadyMessageCommand=cmd(settext, THEME:GetString("ScreenSelectMusicCasual", "Start"))
	}
}