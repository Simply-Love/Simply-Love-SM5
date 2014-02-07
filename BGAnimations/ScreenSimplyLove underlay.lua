local t = Def.ActorFrame{};
	
t[#t+1] = LoadActor(THEME:GetPathG("", "_logos/" .. GAMESTATE:GetCurrentGame():GetName()))..{
	InitCommand=cmd(x, SCREEN_CENTER_X; y, SCREEN_CENTER_Y; diffusealpha, 0;);
	OnCommand=cmd(linear,0.5; diffusealpha, 1);
};

t[#t+1] = LoadActor(THEME:GetPathB("ScreenTitleMenu","underlay/SimplyLove.png"))..{
	InitCommand=cmd(x, SCREEN_CENTER_X; y, SCREEN_CENTER_Y; diffusealpha, 0; zoom, 0.333);
	OnCommand=cmd(linear,0.5; diffusealpha, 1);
};

return t;