local underlay = Def.ActorFrame{
	
	-- semi-transparent quad at the top of ScreenGameplay
	Def.Quad{
		InitCommand=cmd(diffuse,color("0,0,0,0.85");zoomto,SCREEN_WIDTH,SCREEN_HEIGHT/5;);
		OnCommand=cmd(xy, SCREEN_WIDTH/2, SCREEN_HEIGHT/12 - 10 );
	};
	
};


-- Screen Filter
for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
	underlay[#underlay+1] = LoadActor("Filter", pn);
end;

return underlay;