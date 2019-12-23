local af = Def.ActorFrame{
	InitCommand=function(self) self:diffusealpha(0) end,
	SwitchFocusToSongsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
	SwitchFocusToGroupsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
	SwitchFocusToSingleSongMessageCommand=function(self)
		--TODO if there are two people playing then we just hide the panes. I'd like to move them somewhere else instead so both players can see their own
		if GAMESTATE:GetNumSidesJoined() < 2 then self:sleep(0.3):linear(0.1):diffusealpha(1)
		elseif self:GetDiffuseAlpha() == 1 then self:sleep(.3):linear(0.1):diffusealpha(0) end
	end,
}

for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
	--panes to look at when player is on options wheel.
	for i=1, 3 do
			af[#af+1] = LoadActor("./Pane"..i, player)..{
				InitCommand=function(self) self:xy( _screen.cx + 150 * (player==PLAYER_1 and 1 or -1), _screen.cy + 80 ) end
			}
	end
end

return af