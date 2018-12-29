local image = ThemePrefs.Get("VisualTheme")

return Def.ActorFrame{
	LoadActor("explosion.png")..{
		InitCommand=cmd(diffusealpha,0; blend,"BlendMode_Add"),
		MilestoneCommand=cmd(finishtweening; rotationz,0;zoom,2;diffusealpha,0.5;linear,0.5;rotationz,90;zoom,1;diffusealpha,0)
	},

	LoadActor("explosion.png")..{
		InitCommand=cmd(diffusealpha,0; blend,"BlendMode_Add";),
		MilestoneCommand=cmd(finishtweening; rotationz,0;zoom,2;diffusealpha,0.5;linear,0.5;rotationz,-90;zoom,1;diffusealpha,0)
	},

	LoadActor(image.."_splode")..{
		InitCommand=cmd(diffusealpha,0; blend,"BlendMode_Add";),
		MilestoneCommand=cmd(finishtweening; diffuse, GetCurrentColor();rotationz,10;zoom,.25;diffusealpha,0.6;decelerate,0.6;rotationz,0;zoom,2;diffusealpha,0)
	},

	LoadActor(image.."_minisplode")..{
		InitCommand=cmd(diffusealpha,0; blend,"BlendMode_Add";),
		MilestoneCommand=cmd(finishtweening; diffuse, GetCurrentColor();rotationz,10;zoom,.25;diffusealpha,1;linear,0.4;rotationz,0;zoom,1.8;diffusealpha,0)
	}
}