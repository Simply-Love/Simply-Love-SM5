return Def.Quad{
	Name="Header",
	InitCommand=function(self)
		self:diffuse(0,0,0,0.85):valign(0):xy( _screen.cx, 0 )
		self:zoomtowidth(_screen.w):zoomtoheight(80)
	end
}