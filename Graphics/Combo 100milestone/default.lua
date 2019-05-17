local style = ThemePrefs.Get("VisualTheme")
local c = GetCurrentColor()

return Def.ActorFrame{
	InitCommand=function(self) self:visible(false) end,
	HundredMilestoneCommand=function(self) self:finishtweening():visible(true):sleep(0.6):queuecommand("Hide") end,
	ThousandMilestoneCommand=function(self) self:finishtweening():queuecommand("HundredMilestone") end,
	HideCommand=function(self) self:visible(false) end,

	LoadActor("explosion.png")..{
		InitCommand=cmd(diffusealpha,0; blend,"BlendMode_Add"),
		HundredMilestoneCommand=cmd(finishtweening; rotationz,0; zoom,2; diffusealpha,0.5; linear,0.5; rotationz,90; zoom,1; diffusealpha,0)
	},

	LoadActor("explosion.png")..{
		InitCommand=cmd(diffusealpha,0; blend,"BlendMode_Add"),
		HundredMilestoneCommand=cmd(finishtweening; rotationz,0; zoom,2; diffusealpha,0.5; linear,0.5; rotationz,-90; zoom,1; diffusealpha,0)
	},

	LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/Combo 100milestone splode"))..{
		InitCommand=cmd(diffusealpha,0; blend,"BlendMode_Add"),
		HundredMilestoneCommand=cmd(finishtweening; diffuse,c; rotationz,10; zoom,0.25; diffusealpha,0.6; decelerate,0.6; rotationz,0; zoom,2; diffusealpha,0)
	},

	LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/Combo 100milestone minisplode"))..{
		InitCommand=cmd(diffusealpha,0; blend,"BlendMode_Add"),
		HundredMilestoneCommand=cmd(finishtweening; diffuse,c; rotationz,10; zoom,0.25; diffusealpha,1; linear,0.4; rotationz,0; zoom,1.8; diffusealpha,0)
	}
}