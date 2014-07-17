local t = Def.ActorFrame{
	LoadActor("MusicWheelItem sort.png" )..{
		InitCommand=cmd(zoomto,_screen.w/2,50; horizalign,left; addx,-_screen.w/10);
		SetMessageCommand=function(self,param)
		end;
	};
};

return t;