return Def.Banner{
	CurrentSongChangedMessageCommand=function(self)
		self:LoadFromSong( GAMESTATE:GetCurrentSong() )
			:setsize(418,164):zoom(0.4)
			:xy(-70, -200)
	end
}