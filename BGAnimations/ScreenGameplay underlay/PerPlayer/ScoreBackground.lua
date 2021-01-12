local alpha = unpack(...)

return Def.Quad{
	InitCommand=function(self)
		-- Interesting set of numbers...
		self:diffuse(0.10546875, 0.11328125, 0.12109375, alpha):setsize(_screen.w*.30, _screen.h*.0875):x((_screen.w*.30/2)):y(_screen.h - 47)
	end
}