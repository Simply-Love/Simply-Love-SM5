local CurrentPlayer
local nsj = GAMESTATE:GetNumSidesJoined()

return Def.Banner{
	CurrentSongChangedMessageCommand=function(self)
		if nsj == 1 then
			CurrentPlayer = GAMESTATE:IsPlayerEnabled(0) and "P1" or "P2"
		end
		self:LoadFromSong( GAMESTATE:GetCurrentSong() )
			:setsize(418,164):zoom(0.4)
			:xy(CurrentPlayer == "P1" and -70 or 70, -200)
	end
}