return Def.ActorFrame{
	
	LoadActor("../Combo 100milestone");
	
	LoadActor("heartswoosh.png")..{
		InitCommand=cmd(diffusealpha,0;blend,"BlendMode_Add");
		MilestoneCommand=cmd(diffuse,GetCurrentColor();zoom,0.25;diffusealpha,0.7;x,0;linear,0.7;zoom,3;diffusealpha,0;x,100);
	};

	LoadActor("heartswoosh.png")..{
		InitCommand=cmd(diffusealpha,0;blend,"BlendMode_Add");
		MilestoneCommand=cmd(diffuse,GetCurrentColor();rotationy,180;zoom,0.25;diffusealpha,0.7;x,0;linear,0.7;zoom,3;diffusealpha,0;x,-100);
	};
	
};
