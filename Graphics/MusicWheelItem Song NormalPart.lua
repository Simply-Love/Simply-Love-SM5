local t = Def.ActorFrame{
	InitCommand=cmd(fov,90);

	LoadActor("MusicWheelItem song.png")..{
		Name="SongItemBG";
		InitCommand=cmd(zoomto,SCREEN_WIDTH/2, SCREEN_HEIGHT/15; horizalign,left; addx,-SCREEN_WIDTH/10);
		SetMessageCommand=function(self,params)
				
		end;
	};
};

return t;