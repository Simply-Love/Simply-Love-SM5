return Def.Quad{
	Name="Footer",
	InitCommand=function(self)
		self:draworder(90)
		self:zoomto(_screen.w, 32):vertalign(bottom):y(32)
		self:diffuse(0.65,0.65,0.65,1)
	end
}