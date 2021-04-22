-- tables of rgba values
local light = {0.65,0.65,0.65,1}

return Def.Quad{
	Name="Footer",
	InitCommand=function(self)
		self:draworder(90):zoomto(_screen.w, 32):vertalign(bottom):y(32)
		self:diffuse(light)
	end,
	ScreenChangedMessageCommand=function(self)
	end
}