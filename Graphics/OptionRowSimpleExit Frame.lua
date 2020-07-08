local row_height = 30
local row_width  = WideScale(300, 456)

return Def.Quad {
	InitCommand=function(self)
		self:zoomto(row_width, row_height)
		self:x( WideScale(12, 30) ):horizalign(left)
	end
}
