return Def.ActorFrame{
	InitCommand=function(self) self:Center() end,

	LoadActor("usbicon.png")..{
		InitCommand=function(self) self:shadowlength(1) end,
		OnCommand=function(self) self:zoom(0.6):glow(1,1,1,1):glowshift():diffusealpha(0):sleep(1):decelerate(2):diffusealpha(1):sleep(6):linear(0.75):diffusealpha(0) end,
	},

	LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
		Text=ScreenString("Top"),
		InitCommand=function(self) self:shadowlength(1):y(-60):diffusealpha(0) end,
		OnCommand=function(self) self:sleep(2.0):decelerate(1):diffusealpha(1):sleep(6):linear(0.75):diffusealpha(0) end,
	},

	LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
		Text=ScreenString("Bottom"),
		InitCommand=function(self) self:shadowlength(1):y(60):diffusealpha(0) end,
		OnCommand=function(self) self:sleep(3.0):decelerate(1):diffusealpha(1):sleep(5):linear(0.75):diffusealpha(0) end,
	}
}