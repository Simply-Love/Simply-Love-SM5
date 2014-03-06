return Def.ActorFrame{
	
	OffCommand=cmd(linear,.5;diffusealpha,0);
		
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
		OnCommand=cmd(stretchto,SCREEN_LEFT,SCREEN_CENTER_Y-162,SCREEN_RIGHT,SCREEN_TOP; MaskSource, false;);
	};
	
	--bottom mask
	Def.Quad{
		OnCommand=cmd(stretchto,SCREEN_LEFT,SCREEN_CENTER_Y+162,SCREEN_RIGHT,SCREEN_BOTTOM; MaskSource, false;);
	};
	
	
	--the gray bars
	Def.Quad{
		InitCommand=cmd(diffuse,color("0.6,0.6,0.6,1"); zoomto, SCREEN_WIDTH, 2 );
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-163;);
	};
	Def.Quad{
		InitCommand=cmd(diffuse,color("0.6,0.6,0.6,1");  zoomto, SCREEN_WIDTH, 2);
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+163;);
	};
	
};