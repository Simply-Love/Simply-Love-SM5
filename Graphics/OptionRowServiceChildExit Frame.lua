local row_height = _screen.h * 0.0625 -- ???

return Def.Quad {
	InitCommand=function(self)
		self:zoomto(WideScale(304, 460), row_height)
		self:x( WideScale(12, 30) ):halign(0)
	end
}
