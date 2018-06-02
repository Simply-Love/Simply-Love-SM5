return Def.ActorFrame{
	
	OffCommand=cmd(linear,0.4; diffusealpha,0);
		
	-- the vertical colored bands
	Def.Quad{
		OnCommand=cmd(stretchto,415,78,515,402;diffuse,PlayerColor(PLAYER_1));
	};
	
	Def.Quad{
		OnCommand=cmd(stretchto,515,78,615,402;diffuse,PlayerColor(PLAYER_2));
	};


	--masking quads
	--top mask
	Def.Quad{
		OnCommand=cmd(stretchto,SCREEN_LEFT,_screen.cy-162,SCREEN_RIGHT,SCREEN_TOP; MaskSource, false;);
	};
	
	--bottom mask
	Def.Quad{
		OnCommand=cmd(stretchto,SCREEN_LEFT,_screen.cy+162,SCREEN_RIGHT,SCREEN_BOTTOM; MaskSource, false;);
	};
	
	
	--the gray bars
	Def.Quad{
		InitCommand=cmd(diffuse,color("0.6,0.6,0.6,1"); zoomto, _screen.w, 2 );
		OnCommand=cmd(x,_screen.cx;y,_screen.cy-163;);
	};
	Def.Quad{
		InitCommand=cmd(diffuse,color("0.6,0.6,0.6,1");  zoomto, _screen.w, 2);
		OnCommand=cmd(x,_screen.cx;y,_screen.cy+163;);
	};
	
};