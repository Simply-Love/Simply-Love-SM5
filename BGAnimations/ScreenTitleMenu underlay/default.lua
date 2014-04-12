local t = Def.ActorFrame{
	InitCommand=function(self)
		ResetPlayerCustomPrefs(PLAYER_1);
		ResetPlayerCustomPrefs(PLAYER_2);
	end;	
};
	
t[#t+1] = LoadActor(THEME:GetPathG("", "_logos/" .. GAMESTATE:GetCurrentGame():GetName()))..{
	InitCommand=cmd(x, SCREEN_CENTER_X; y, SCREEN_CENTER_Y );
	OffCommand=cmd(linear,0.5; diffusealpha, 0;);
};

t[#t+1] = LoadActor("SimplyLove.png") .. {
	InitCommand=cmd(x, SCREEN_CENTER_X; y, SCREEN_CENTER_Y; zoom, 0.333);
	OffCommand=cmd(linear,0.5; diffusealpha, 0;);
};


t[#t+1] = Def.Quad{
	InitCommand=cmd(zoomto,SCREEN_WIDTH,SCREEN_HEIGHT/2 - SCREEN_HEIGHT/4; xy, SCREEN_CENTER_X, SCREEN_BOTTOM-SCREEN_HEIGHT/8; MaskSource );
	OnCommand=cmd(sleep, 0.1; linear, 0.3; addy, SCREEN_HEIGHT/2 - SCREEN_HEIGHT/4;);
}

return t;