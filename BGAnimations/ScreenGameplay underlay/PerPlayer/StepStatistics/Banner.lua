local player = ...
local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)
local IsUltraWide = (GetScreenAspectRatio() > 21/9)
local IsOnSameSideAsPlayer = IsUltraWide and (#GAMESTATE:GetHumanPlayers() > 1 or GAMESTATE:GetCurrentStyle():GetName() == "double")

return Def.Banner{
	CurrentSongChangedMessageCommand=function(self)
		self:LoadFromSong( GAMESTATE:GetCurrentSong() )
		self:setsize(418,164):zoom(0.4)
		self:xy(70 * (player==PLAYER_1 and 1 or -1), -200)

		-- offset a bit more when NoteFieldIsCentered
		if NoteFieldIsCentered and IsUsingWideScreen() then
			self:x( 72 * (player==PLAYER_1 and 1 or -1) )
		end

		-- stats on same side as player
		if IsOnSameSideAsPlayer then
			self:x(self:GetX() * -1)
		end
	end
}