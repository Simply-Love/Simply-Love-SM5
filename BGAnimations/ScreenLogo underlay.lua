local t = Def.ActorFrame{};
local game = GAMESTATE:GetCurrentGame():GetName();
if game == "popn" or game == "beat" or game == "kb7" or game == "para" then
	game = "techno"
end

t[#t+1] = LoadActor(THEME:GetPathG("", "_logos/" .. game))..{
	InitCommand=cmd(x, _screen.cx; y, _screen.cy; diffusealpha, 0;);
	OnCommand=cmd(linear,0.5; diffusealpha, 1);
};

t[#t+1] = LoadActor(THEME:GetPathB("ScreenTitleMenu","underlay/SimplyLove.png"))..{
	InitCommand=cmd(x, _screen.cx; y, _screen.cy; diffusealpha, 0; zoom, 0.333);
	OnCommand=cmd(linear,0.5; diffusealpha, 1);
};

return t;