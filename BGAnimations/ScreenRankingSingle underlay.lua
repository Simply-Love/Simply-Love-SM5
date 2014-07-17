return Def.ActorFrame{
	
	-- the vertical colored bands
	Def.Quad{
		InitCommand=cmd(stretchto,415,78,515,402;diffuse,PlayerColor(PLAYER_1));
		OnCommand=cmd(diffusealpha,0;linear,.5;diffusealpha,1);
	};
	
	Def.Quad{
		InitCommand=cmd(stretchto,515,78,615,402;diffuse,PlayerColor(PLAYER_2));
		OnCommand=cmd(diffusealpha,0;linear,.5;diffusealpha,1);
	};

	
	--masking quads
	Def.Quad{
		InitCommand=cmd(stretchto,SCREEN_LEFT,_screen.cy-162,SCREEN_RIGHT,SCREEN_TOP; MaskSource, false; );
	};
	
	Def.Quad{
		InitCommand=cmd(stretchto,SCREEN_LEFT,_screen.cy+162,SCREEN_RIGHT,SCREEN_BOTTOM; MaskSource, false; );
	};
	

	--the gray bars
	Def.Quad{
		InitCommand=cmd(diffuse,color("0.6,0.6,0.6,1"); zoomto, _screen.w, 2 );
		OnCommand=cmd(x,_screen.cx;y,_screen.cy-163; diffusealpha,0; linear,0.5; diffusealpha,1);
	};
	Def.Quad{
		InitCommand=cmd(diffuse,color("0.6,0.6,0.6,1");  zoomto, _screen.w, 2);
		OnCommand=cmd(x,_screen.cx;y,_screen.cy+163; diffusealpha,0; linear,0.5; diffusealpha,1);
	}
	
};