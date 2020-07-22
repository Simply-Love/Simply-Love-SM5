return Def.ActorFrame{

	LoadActor("../Combo 100milestone"),

	LoadActor("Arrows_swoosh")..{
		InitCommand=cmd(diffusealpha,0;blend,"BlendMode_Add"),
		MilestoneCommand=cmd(finishtweening; diffuse,GetCurrentColor(); zoom,0.25;diffusealpha,0.7;x,0;linear,0.7;zoom,3;diffusealpha,0;x,100)
	},

	LoadActor("Arrows_swoosh")..{
		InitCommand=cmd(diffusealpha,0;blend,"BlendMode_Add"),
		MilestoneCommand=cmd(finishtweening; diffuse,GetCurrentColor(); rotationy,180;zoom,0.25;diffusealpha,0.7;x,0;linear,0.7;zoom,3;diffusealpha,0;x,-100)
	}
}