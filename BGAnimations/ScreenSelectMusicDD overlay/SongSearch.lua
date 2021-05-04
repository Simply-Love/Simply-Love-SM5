local t = Def.ActorFrame{
	OnCommand=function(self)
		screen = SCREENMAN:GetTopScreen()
		if SongSearchSSMDD == true then
			SongSearchSSMDD = false
			SongSearchAnswer = nil
		end	
	end,

	SongSearchSSMDDMessageCommand = function(self)
		SCREENMAN:AddNewScreenToTop("ScreenTextEntry");
		local songSearch = {
			Question = "\nSEARCH FOR:\nSongs\nSong Artists\nStep Artists",
			MaxInputLength = 52,
			OnOK = function(answer)
				SongSearchSSMDD = true
				SongSearchAnswer = answer
				--- has to sleep in order to be able to reload because #StepmaniaMoment
				self:sleep(0.1):queuecommand("ReloadScreen")
			end,
			};
			SCREENMAN:GetTopScreen():Load(songSearch)
	end,
	
	ReloadScreenCommand=function(self)
		screen:SetNextScreenName("ScreenReloadSSMDD")
		screen:StartTransitioningScreen("SM_GoToNextScreen")
	end,
}

return t