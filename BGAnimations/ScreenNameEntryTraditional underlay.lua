local Players = GAMESTATE:GetHumanPlayers()

return Def.ActorFrame{
	InitCommand=cmd(queuecommand, "Detect"),
	DetectCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		if topscreen then
		
			for pn in ivalues(Players) do
				if topscreen:GetEnteringName(pn) then
					SL[ToEnumShortString(pn)].HighScores.EnteringName = true
				end
			end
			
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		else
			self:queuecommand("Detect")
		end
	end
}