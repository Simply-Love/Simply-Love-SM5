local height = 40
local width  = WideScale(614, 792)
local x_offset = WideScale(13, 30.666) -- hhhhhhhhhhh

-- Quad at the bottom of the screen behind the explanation of the current OptionRow.
return Def.Quad{
	Name="ExplanationBackground",
	InitCommand=function(self)
		self:diffuse(0,0,0,0)
		self:vertalign(bottom):horizalign(left)
		self:setsize(width, height)
		self:xy(x_offset, _screen.h-36)
	end,
	OnCommand=function(self)
		self:linear(0.2):diffusealpha(0.8)
	end,
}