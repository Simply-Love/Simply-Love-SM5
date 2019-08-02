return Def.Quad {
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,1) end,
	StartTransitioningCommand=function(self) self:linear(0.4):diffusealpha(0) end
}