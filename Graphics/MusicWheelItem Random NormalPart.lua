-- return Def.Actor{}
local t = Def.ActorFrame{
	LoadActor("MusicWheelItem song.png" )..{
		InitCommand=cmd(zoomto,_screen.w/2,32; horizalign,left; addx,-_screen.w/10);
		SetMessageCommand=function(self,param)
		end;
	};
};

return t;
