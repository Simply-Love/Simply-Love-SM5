return Def.ActorFrame{
	Def.Quad{
		InitCommand=cmd(FullScreen;diffuse,color("0,0,0,0"));
		OnCommand=cmd(accelerate,0.5;diffusealpha,0.5);
		OffCommand=cmd(accelerate,0.5;diffusealpha,0);
	};
	
	
	-- Intructions BG
	Def.Quad {
		InitCommand = cmd(xy,SCREEN_CENTER_X, SCREEN_CENTER_Y-40; zoomto, SCREEN_WIDTH*0.75, SCREEN_CENTER_Y*0.5; diffuse,GetCurrentColor(););
	};
	-- white border
	Border(SCREEN_WIDTH*0.75, SCREEN_CENTER_Y*0.5, 2) .. {
		InitCommand = cmd(xy,SCREEN_CENTER_X, SCREEN_CENTER_Y-40);
	};
	
	
	
	-- Text Entry BG
	Def.Quad {
		InitCommand = cmd(xy,SCREEN_CENTER_X, SCREEN_CENTER_Y+16; zoomto, SCREEN_WIDTH*0.75, 40; diffuse, color("#000000"); );
	};
	-- white border
	Border(SCREEN_WIDTH*0.75, 40, 2) .. {
		InitCommand = cmd(xy,SCREEN_CENTER_X, SCREEN_CENTER_Y+16);
	};

}
