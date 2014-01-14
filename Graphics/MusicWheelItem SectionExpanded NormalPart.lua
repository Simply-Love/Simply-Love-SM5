local t = Def.ActorFrame{
	Name="WheelItemSectionOpened";


	Def.Quad{
		Name="SectionBG";
		InitCommand=cmd(zoomto,SCREEN_WIDTH/2,SCREEN_HEIGHT/15; horizalign,left; addx,-SCREEN_WIDTH/10);
		SetMessageCommand=function(self,params)
			self:diffuse(color("#4c565d"));
		end;
	};
	
};

return t;