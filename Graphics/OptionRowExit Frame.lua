return Def.Quad {
	InitCommand=function(self)
		self:setsize(WideScale(543,710), 30)
		:x(_screen.cx - WideScale(30,40))
	end
}