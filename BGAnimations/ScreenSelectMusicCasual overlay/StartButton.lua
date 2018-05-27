local w, h = 75, 33

return Def.ActorFrame{
	Name="StartButton",
	InitCommand=cmd(diffusealpha, 0; xy,_screen.cx, _screen.h-76),
	SwitchFocusToSongsMessageCommand=cmd(linear,0.1; diffusealpha,0),
	SwitchFocusToGroupsMessageCommand=cmd(linear,0.1; diffusealpha,0),
	SwitchFocusToSingleSongMessageCommand=cmd(sleep,0.3; linear,0.1; diffusealpha,1),

	LoadActor("./img/start_glow.png")..{
		Name="Glow",
		InitCommand=function(self)
			-- start_glow.png is 600px wide, but the space carved out of the middle is only 500px wide
			self:zoom( (w/self:GetWidth()) * 1.2 )
		end,
		OnCommand=cmd( diffuseshift; effectcolor1,color("#55CC5500"); effectcolor2,color("#55CC55FF")),
	},

	Def.Quad{
		Name="Quad",
		InitCommand=cmd( diffuseshift; effectcolor1,color("#33aa33"); effectcolor2,color("#55cc55"); zoomto, w, h),
	},

	LoadFont("_miso")..{
		Name="Text",
		Text=THEME:GetString("ScreenSelectMusicCasual", "Press"),
		InitCommand=cmd(diffuse, Color.Black; zoom, 0.9),
		SwitchFocusToSingleSongMessageCommand=cmd(settext, THEME:GetString("ScreenSelectMusicCasual", "Press")),
		BothPlayersAreReadyMessageCommand=cmd(settext, THEME:GetString("ScreenSelectMusicCasual", "Start"))
	}
}