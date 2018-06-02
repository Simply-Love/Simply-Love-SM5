return Def.ActorFrame{
	Def.Quad{
		InitCommand=cmd(FullScreen;diffuse,color("0,0,0,0"));
		OnCommand=cmd(accelerate,0.5;diffusealpha,0.5);
		OffCommand=cmd(accelerate,0.5;diffusealpha,0);
	};
	
	
	-- Intructions BG
	Def.Quad {
		InitCommand = cmd(xy,_screen.cx, _screen.cy-40; zoomto, _screen.w*0.75, _screen.cy*0.5; diffuse,GetCurrentColor(););
	};
	-- white border
	Border(_screen.w*0.75, _screen.cy*0.5, 2) .. {
		InitCommand = cmd(xy,_screen.cx, _screen.cy-40);
	};
	
	
	
	-- Text Entry BG
	Def.Quad {
		InitCommand = cmd(xy,_screen.cx, _screen.cy+16; zoomto, _screen.w*0.75, 40; diffuse, color("#000000"); );
	};
	-- white border
	Border(_screen.w*0.75, 40, 2) .. {
		InitCommand = cmd(xy,_screen.cx, _screen.cy+16);
	};

}
