return Def.ActorFrame{

	LoadActor("usbicon.png")..{
		OnCommand=cmd(zoom,0.6;glow,1,1,1,1;glowshift;x,_screen.cx;y,_screen.cy;diffusealpha,0;sleep,1.0;decelerate,2;diffusealpha,1;sleep,6;linear,0.75;diffusealpha,0);
		OffCommand=cmd(stoptweening;accelerate,0.5;addx,-_screen.w*1.5);
	};
	
	LoadFont("_miso")..{
		Text="Use a USB card";
		OnCommand=cmd(x,_screen.cx;y,_screen.cy-60;diffusealpha,0;sleep,2.0;decelerate,1;diffusealpha,1;sleep,6;linear,0.75;diffusealpha,0);
		OffCommand=cmd(stoptweening;accelerate,0.5;addx,-_screen.w*1.5);
	};
	
	LoadFont("_miso")..{
		Text="to save scores and preferences.";
		OnCommand=cmd(x,_screen.cx;y,_screen.cy+60;diffusealpha,0;sleep,3.0;decelerate,1;diffusealpha,1;sleep,5;linear,0.75;diffusealpha,0);
		OffCommand=cmd(stoptweening;accelerate,0.5;addx,-_screen.w*1.5);
	};

};