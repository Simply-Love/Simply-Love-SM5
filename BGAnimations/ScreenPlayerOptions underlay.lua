return Def.Quad{
	Name="ExplanationBackground",
	InitCommand=function(self)
		self:diffuse(0,0,0,0)
		:horizalign(left):vertalign(top)
		:setsize(WideScale(598,792), 40)
		:xy(WideScale(20,30), _screen.h-76)
	end,
	OnCommand=function(self) self:linear(0.2):diffusealpha(0.8) end,
}