return Def.Quad {
	InitCommand=function(self) self:FullScreen():diffusealpha(1) end,
	StartTransitioningCommand=function(self) self:linear(0.2):diffusealpha(0) end
}