local t = Def.ActorFrame{
	InitCommand=function(self)
		ResetPlayerCustomPrefs(PLAYER_1);
		ResetPlayerCustomPrefs(PLAYER_2);
	end;	
};
	
t[#t+1] = LoadActor(THEME:GetPathG("", "_logos/" .. GAMESTATE:GetCurrentGame():GetName()))..{
	InitCommand=cmd(x, SCREEN_CENTER_X; y, SCREEN_CENTER_Y; diffusealpha, 1;);
	OffCommand=cmd(linear,0.5; diffusealpha, 0;);
};

t[#t+1] = LoadActor("SimplyLove.png") .. {
	InitCommand=cmd(x, SCREEN_CENTER_X; y, SCREEN_CENTER_Y; diffusealpha, 1; zoom, 0.333);
	OffCommand=cmd(linear,0.5; diffusealpha, 0;);
};

return t;