return LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
	Text=ScreenString("Disqualified"),
	InitCommand=function(self) self:shadowlength(0.5) end
}