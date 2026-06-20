return LoadActor(THEME:GetPathS("", "_prompt"))..{
	IsAction=true,
	OnCommand=function(self) self:sleep(0.3) end,
	StartTransitioningCommand=function(self) self:play() end
}