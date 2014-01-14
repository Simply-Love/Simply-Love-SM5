local t = Def.ActorFrame{
	LoadActor("MusicWheelItem sort.png" )..{
		InitCommand=cmd(zoomto,SCREEN_WIDTH/2,50; horizalign,left; addx,-SCREEN_WIDTH/10);
		SetMessageCommand=function(self,param)
		end;
	};
};

return t;