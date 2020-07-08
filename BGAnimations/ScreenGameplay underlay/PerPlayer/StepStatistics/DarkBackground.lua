local player, header_height, width = unpack(...)

return Def.Quad{
	InitCommand=function(self)
		self:diffuse(0, 0, 0, 0.95):setsize(width, _screen.h):y(-header_height)
	end
}