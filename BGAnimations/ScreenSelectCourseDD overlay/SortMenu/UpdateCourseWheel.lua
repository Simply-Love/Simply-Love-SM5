--- Reload the course wheel whenever the course wheel has been updated.
local t = Def.ActorFrame {
	InitCommand=function(self)
		self:draworder(105)
	end,
	
	ReloadSSCDDMessageCommand = function(self)
		if SortMenuNeedsUpdating == false then
			-- these first 2 probably don't need to be set, but just to be safe.
			SongSearchSSMDD = false
			SongSearchAnswer = nil
			SongSearchWheelNeedsResetting = false
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenReloadSSCDD")
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end,
}


return t