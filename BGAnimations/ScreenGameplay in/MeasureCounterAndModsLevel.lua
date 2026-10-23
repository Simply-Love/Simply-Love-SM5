return function()
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do

		-- get the PlayerOptions string for any human players and store it now
		-- we'll retrieve it the next time ScreenSelectMusic loads and re-apply those same mods
		-- in this way, we can override the effects of songs that forced modifiers during gameplay
		-- the old-school (ie. ITG) way of GAMESTATE:ApplyGameCommand()
		local pn = ToEnumShortString(player)
		SL[pn].PlayerOptionsStringKey = GetPlayerOptionsStringKey(player)
		SL[pn][SL[pn].PlayerOptionsStringKey] = GAMESTATE:GetPlayerState(player):GetPlayerOptionsString("ModsLevel_Preferred")
	end
end
