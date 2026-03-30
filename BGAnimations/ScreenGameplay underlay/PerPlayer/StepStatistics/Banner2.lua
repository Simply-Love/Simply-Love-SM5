local player = ...
local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)
local IsUltraWide = (GetScreenAspectRatio() > 21/9)
local hasUniqueBanner = true
local finalOffset = -160
local finalSize = 0.25

local pn = ToEnumShortString(player)
if not SL[pn].ActiveModifiers.PackBanner then return end

return Def.Banner{
	CurrentSongChangedMessageCommand=function(self)
		if GAMESTATE:IsCourseMode() then
			self:LoadFromCourse( GAMESTATE:GetCurrentCourse() )
		else
			self:LoadFromSongGroup( GAMESTATE:GetCurrentSong():GetGroupName() )
		end
		
		self:setsize(418,164):zoom(0.4):diffusealpha(1)
		self:xy(70 * (player==PLAYER_1 and 1 or -1), -200)
		
		-- offset a bit more when NoteFieldIsCentered
		if NoteFieldIsCentered and IsUsingWideScreen() then
			self:x( 72 * (player==PLAYER_1 and 1 or -1) )
		end

		-- ultrawide and both players joined
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			self:x(self:GetX() * -1)
		end
		
		if NoteFieldIsCentered then
			finalOffset = -115
			finalSize = 0.2
		end
		
		self:sleep(5)
		if hasUniqueBanner then
			self:decelerate(1):diffusealpha(0.25):glow(1,1,1,0.5):xy(finalOffset * (player==PLAYER_1 and 1 or -1), 20):zoom(finalSize):rotationz(-720 * (player==PLAYER_1 and 1 or -1))
			self:linear(1):diffusealpha(1):glow(0,0,0,0)
			self:linear(0):rotationz(0)
		end
	end
}