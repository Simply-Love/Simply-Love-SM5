return LoadActor(THEME:GetPathS("", "_prompt"))..{
	IsAction=true,
	StartTransitioningCommand=function(self) self:play() end
}