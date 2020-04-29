return Def.Quad {
	InitCommand=function(self)
		self:zoomto(_screen.w * SL_WideScale(0.475, 0.54), _screen.h*0.0625)
		self:x( SL_WideScale(12, 30) ):halign(0)
	end
}
