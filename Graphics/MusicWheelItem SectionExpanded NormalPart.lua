local t = Def.ActorFrame{
	Name="WheelItemSectionOpened";


	Def.Quad{
		Name="SectionBG";
		InitCommand=cmd(zoomto,_screen.w/2,_screen.h/15; horizalign,left; addx,-_screen.w/10);
		SetMessageCommand=function(self,params)
			self:diffuse(color("#4c565d"));
		end;
	};
	
};

return t;