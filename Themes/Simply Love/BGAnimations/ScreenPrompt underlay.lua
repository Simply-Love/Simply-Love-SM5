return Def.ActorFrame{
	Def.Quad{
		InitCommand=cmd(FullScreen;diffuse,color("0,0,0,0"));
		OnCommand=cmd(accelerate,0.5;diffusealpha,0.5);
		OffCommand=cmd(accelerate,0.5;diffusealpha,0);
	};
	
	-- the BG for the prompt itself
	Def.Quad {
		InitCommand=cmd(xy,_screen.cx, _screen.cy-56; zoomto, _screen.w*0.75, _screen.cy*0.5; diffuse,GetCurrentColor(););
	};
	-- white border
	Border(_screen.w*0.75, _screen.cy*0.5, 2) .. {
		InitCommand=cmd(xy,_screen.cx, _screen.cy-56);
	};
	
	

	-- the BG for the choices presented to the player
	Def.Quad {
		InitCommand=cmd(xy,_screen.cx, _screen.cy+120; zoomto, _screen.w*0.75, _screen.cy*0.25;);
		OnCommand=cmd(diffuse,color("#000000FF"));
	};
	-- white border
	Border(_screen.w*0.75, _screen.cy*0.25, 2) .. {
		InitCommand=cmd(xy,_screen.cx, _screen.cy+120);
	};

}
