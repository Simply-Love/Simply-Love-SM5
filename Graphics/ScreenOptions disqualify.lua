return LoadFont("Common Bold")..{
	Text=ScreenString("Disqualified"),
	InitCommand=function(self) self:shadowlength(0.5) end
}