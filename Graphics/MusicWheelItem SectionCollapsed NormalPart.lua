local t = Def.ActorFrame{
	Name="WheelItemSectionNormal";

	LoadActor( "MusicWheelItem SectionCollapsed.png" )..{
		Name="SectionBG";
		InitCommand=cmd(zoomto,SCREEN_WIDTH/2,SCREEN_HEIGHT/15; horizalign,left; addx,-SCREEN_WIDTH/10);
		SetMessageCommand=function(self,params)
		end;
	};	
};

return t;