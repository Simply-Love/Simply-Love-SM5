return Def.Quad{
	Name="ExplanationBackground",
	InitCommand=function(self)
		self:diffuse(0,0,0,0):horizalign(left)
		:setsize(WideScale(598,781), 38)
		:xy(WideScale(20,35), _screen.h-57)
	end,
	OnCommand=function(self) self:linear(0.2):diffusealpha(0.8) end,
}