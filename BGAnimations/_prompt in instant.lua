return LoadActor(THEME:GetPathS("", "_prompt"))..{
	StartTransitioningCommand=function(self) self:play() end
}