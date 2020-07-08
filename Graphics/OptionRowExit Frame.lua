local padding    = WideScale(12, 28)
local row_height = 30
local row_width  = WideScale(582, 776) - (padding * 2)

return Def.Quad {
	InitCommand=function(self)
		self:horizalign(left):x(padding)
		self:setsize(row_width , row_height)
	end
}