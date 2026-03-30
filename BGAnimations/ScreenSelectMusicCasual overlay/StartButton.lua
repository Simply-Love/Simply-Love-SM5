local w, h = 75, 33

return Def.ActorFrame{
	Name="StartButton",
	InitCommand=function(self) self:diffusealpha(0):xy(_screen.cx, _screen.h-76) end,
	SwitchFocusToSongsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
	SwitchFocusToGroupsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(1) end,

	LoadActor("./img/start_glow.png")..{
		Name="Glow",
		InitCommand=function(self)
			-- start_glow.png is 600px wide, but the space carved out of the middle is only 500px wide
			self:zoom( (w/self:GetWidth()) * 1.2 )
		end,
		OnCommand=function(self) self:diffuseshift():effectcolor1(color("#55CC5500")):effectcolor2(color("#55CC55FF")) end,
	},

	Def.Quad{
		Name="Quad",
		InitCommand=function(self) self:diffuseshift():effectcolor1(color("#33aa33")):effectcolor2(color("#55cc55")):zoomto(w, h) end,
	},

	LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
		Name="Text",
		Text=THEME:GetString("ScreenSelectMusicCasual", "Press"),
		InitCommand=function(self) self:diffuse(Color.Black):zoom(0.9) end,
		SwitchFocusToSingleSongMessageCommand=function(self) self:settext(THEME:GetString("ScreenSelectMusicCasual", "Press")) end,
		BothPlayersAreReadyMessageCommand=function(self) self:settext(THEME:GetString("ScreenSelectMusicCasual", "Start")) end
	}
}