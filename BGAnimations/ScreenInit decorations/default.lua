local t = Def.ActorFrame {};

t[#t+1] = Def.ActorFrame {
	
	InitCommand=cmd(Center);
  
	Def.ActorFrame {
		Def.Quad {
			InitCommand=cmd(zoomto,SCREEN_WIDTH,0;);
			OnCommand=cmd( accelerate,0.3; zoomtoheight,128; diffusealpha,1; sleep,1.5; linear,0.25);
			OffCommand=cmd(accelerate,0.3; zoomtoheight,0;)
		};
		LoadActor("ssc") .. {
			InitCommand=cmd(diffusealpha,0);
			OnCommand=cmd(sleep,0.3; linear,1;diffusealpha,1;sleep,0.75;linear,0.25;diffusealpha,0);
		};
	};
	
	Def.ActorFrame {
		OnCommand=cmd(playcommandonchildren,"ChildrenOn"; diffuse,color("0,0,0,1"););
		ChildrenOnCommand=cmd(diffusealpha,0;sleep,2;linear,0.25;diffusealpha,1);
		OffCommand=cmd(linear, 0.2; diffusealpha,0);
	  
		LoadFont("_misoreg hires") .. {
			Text=ProductID();
			InitCommand=cmd(y,-36; zoom, 0.9; );
		};
		LoadFont("_wendy small") .. {
			Text=THEME:GetThemeDisplayName();
			InitCommand=cmd(y, -10; zoom, 0.55; );
		};
		LoadFont("_misoreg hires") .. {
			Text="Created by " .. THEME:GetThemeAuthor();
			InitCommand=cmd(y,24; zoom, 0.9; );
		};
		
		LoadFont("_misoreg hires") .. {
			Text="SM5 port by dbk2";
			InitCommand=cmd(y,42;zoom,0.75);
		};
	};
};

return t