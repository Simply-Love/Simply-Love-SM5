return Def.ActorFrame{

	-- Fade out here; this and the message for the options should appear
	-- over every single object in this screen. The fade is stolen from
	-- Screen cancel because I like how it worked.
	Def.Quad{
		InitCommand=cmd(diffuse,Color.Black;FullScreen;diffusealpha,0);
		OffCommand=cmd(cropbottom,1;fadebottom,.5;linear,0.3;cropbottom,-0.5;diffusealpha,1);
	};

	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenSelectMusic","Press Start for Options");
		InitCommand=cmd(x,_screen.cx;y,_screen.cy;NoStroke;zoom,0.75;);
		OnCommand=cmd(visible,false);
		ShowPressStartForOptionsCommand=cmd(visible,true;);
		ShowEnteringOptionsCommand=cmd(linear,0.1; diffusealpha,0; queuecommand, "NewText");
		NewTextCommand=cmd(hibernate,0.1; settext,THEME:GetString("ScreenSelectMusic","Entering Options..."); linear,0.1; diffusealpha,1; hurrytweening,0.1; sleep,1;);
	};
	
	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenSelectMusic","Start Button");
		InitCommand=cmd(x,_screen.cx - 48;y,_screen.cy - 45;NoStroke;);
		OnCommand=cmd(visible,false);
		ShowPressStartForOptionsCommand=cmd(visible,true;);
		ShowEnteringOptionsCommand=cmd(linear,0.1; diffusealpha,0;);
	};
};