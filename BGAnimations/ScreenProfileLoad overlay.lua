local t = Def.ActorFrame{};

t[#t+1] = Def.Quad{
	InitCommand=cmd(Center; zoomto,_screen.w,_screen.h;diffuse,Color.Black);
};

t[#t+1] = Def.Quad{
	InitCommand=cmd(zoomto,_screen.w,0; Center; diffuse,Color.White);
	OnCommand=cmd(decelerate, 0.3; zoomtoheight,50; sleep,0.5; sleep,0.1; queuecommand, "Load");
	LoadCommand=function(self) 
		SCREENMAN:GetTopScreen():Continue();
	end;
};


t[#t+1] = LoadFont("_wendy small")..{
	Text=THEME:GetString("ScreenProfileLoad","Loading Profiles...");
	InitCommand=cmd(Center;diffuse,color("#000000");shadowlength,0; zoom,0.6);
	OffCommand=cmd(linear,0.2;diffusealpha,0);
};

return t;