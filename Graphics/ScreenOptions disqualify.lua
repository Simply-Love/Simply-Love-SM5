return LoadFont("_wendy small")..{
	Text=ScreenString("Disqualified"),
	InitCommand=function(self) self:shadowlength(0.5) end
}