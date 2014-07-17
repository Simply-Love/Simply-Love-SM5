local Players = GAMESTATE:GetHumanPlayers();
local t = Def.ActorFrame{};

-- Danger
for pn in ivalues(Players) do
	t[#t+1] = LoadActor("Danger", pn);
end

-- semi-transparent quad at the top of ScreenGameplay
t[#t+1] = Def.Quad{
	InitCommand=cmd(diffuse,color("0,0,0,0.85");zoomto,_screen.w,_screen.h/5;);
	OnCommand=cmd(xy, _screen.w/2, _screen.h/12 - 10 );
};

-- Screen Filter
for pn in ivalues(Players) do
	t[#t+1] = LoadActor("Filter", pn);
end

return t;