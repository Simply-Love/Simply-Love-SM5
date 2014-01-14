return Def.ActorFrame{
	Def.Quad{
		InitCommand=cmd(FullScreen;diffuse,color("0,0,0,0"));
		OnCommand=cmd(accelerate,0.5;diffusealpha,0.5);
		OffCommand=cmd(accelerate,0.5;diffusealpha,0);
	};
	
	-- the BG for the prompt itself
	Def.Quad {
		InitCommand=cmd(xy,SCREEN_CENTER_X, SCREEN_CENTER_Y-56; zoomto, SCREEN_WIDTH*0.75, SCREEN_CENTER_Y*0.5; diffuse,GetCurrentColor(););
	};
	-- white border
	Border(SCREEN_WIDTH*0.75, SCREEN_CENTER_Y*0.5, 2) .. {
		InitCommand=cmd(xy,SCREEN_CENTER_X, SCREEN_CENTER_Y-56);
	};
	
	

	-- the BG for the choices presented to the player
	Def.Quad {
		InitCommand=cmd(xy,SCREEN_CENTER_X, SCREEN_CENTER_Y+120; zoomto, SCREEN_WIDTH*0.75, SCREEN_CENTER_Y*0.25;);
		OnCommand=cmd(diffuse,color("#000000FF"));
	};
	-- white border
	Border(SCREEN_WIDTH*0.75, SCREEN_CENTER_Y*0.25, 2) .. {
		InitCommand=cmd(xy,SCREEN_CENTER_X, SCREEN_CENTER_Y+120);
	};

}
