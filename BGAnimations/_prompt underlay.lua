return Def.Quad{
	InitCommand=function(self) self:Center():FullScreen():diffuse(0,0,0,0) end,
	OnCommand=function(self) self:linear(0.3):diffusealpha(0.75) end
}