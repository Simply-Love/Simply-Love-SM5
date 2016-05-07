return Def.Actor{
	InitCommand=function(self) self:queuecommand("Transition") end,
	TransitionCommand=function(self)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
}