--- Reload the music wheel whenever the song wheel has been updated.
local t = Def.ActorFrame {
	InitCommand=function(self)
		self:draworder(105)
	end,
	
	ReloadSSCDDMessageCommand = function(self)
		if SortMenuNeedsUpdating == false then
			SongSearchSSMDD = false
			SongSearchAnswer = nil
			SongSearchWheelNeedsResetting = false
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenReloadSSCDD")
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end,
}


return t