--- Here we will do all the heavy lifting for the sorts/filters I think?
--- At the very least this reloads the songwheel once everything has been set.

local t = Def.ActorFrame {
	InitCommand=function(self)
		self:draworder(105)
	end,
	
	ReloadSSMDDMessageCommand = function(self)
		if SortMenuNeedsUpdating == false then
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenReloadSSMDD")
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end,
}


return t