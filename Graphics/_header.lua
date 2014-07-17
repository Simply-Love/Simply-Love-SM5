return Def.ActorFrame{

	Def.Quad{
		InitCommand=cmd(x, _screen.cx; zoomto,_screen.w,40; );
		OnCommand=cmd(diffuse,color("0.65,0.65,0.65,0.8"))
	};
	
	
	LoadFont("_wendy small") .. {
		Name="HeaderText";
		InitCommand=cmd(diffusealpha,0;
			 			zoom,0.6;
						-- feeding horizalign a value of "left"
						-- will line up the text with the left side of the screen
						horizalign, left;
						addx, 10; -- padding-left, effectively
						settext,ScreenString("HeaderText");
					);
		OnCommand=cmd(decelerate,0.5; diffusealpha,1);
		OffCommand=cmd(accelerate,0.5;diffusealpha,0);
	};
};