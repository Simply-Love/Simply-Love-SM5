return Def.Quad {
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0) end,
	StartTransitioningCommand=function(self) self:linear(0.2):diffusealpha(1) end
}