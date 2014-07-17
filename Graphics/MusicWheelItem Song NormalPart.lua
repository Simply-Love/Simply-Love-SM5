local t = Def.ActorFrame{
	InitCommand=cmd(fov,90);

	LoadActor("MusicWheelItem song.png")..{
		Name="SongItemBG";
		InitCommand=cmd(zoomto,_screen.w/2, _screen.h/15; horizalign,left; addx,-_screen.w/10);
		SetMessageCommand=function(self,params)
				
		end;
	};
};

return t;