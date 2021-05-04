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
				--- has to sleep in order to be able to reload because #StepmaniaMoment
				--- If the player doesn't enter any text and just presses enter  just reload the screen to the normal wheel
				if answer ~= "" then
					SongSearchSSMDD = true
					SongSearchAnswer = answer
					self:sleep(0.1):queuecommand("ReloadScreen")
				else
					SongSearchSSMDD = false
					SongSearchAnswer = nil
					self:sleep(0.1):queuecommand("ReloadScreen")
				end
				
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