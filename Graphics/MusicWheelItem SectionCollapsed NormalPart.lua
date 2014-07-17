local t = Def.ActorFrame{
	Name="WheelItemSectionNormal";

	LoadActor( "MusicWheelItem SectionCollapsed.png" )..{
		Name="SectionBG";
		InitCommand=cmd(zoomto,_screen.w/2,_screen.h/15; horizalign,left; addx,-_screen.w/10);
		SetMessageCommand=function(self,params)
		end;
	};	
};

return t;