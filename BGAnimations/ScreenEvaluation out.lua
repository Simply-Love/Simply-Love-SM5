return Def.Quad{
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0) end,
	StartTransitioningCommand=function(self)
		MESSAGEMAN:Broadcast("StopWRSound")
		self:sleep(0.1):linear(0.4):diffusealpha(1) 
	end
}