local style = ThemePrefs.Get("VisualStyle")
local c = GetCurrentColor(true)

return Def.ActorFrame{
	InitCommand=function(self) self:visible(false) end,
	ThousandMilestoneCommand=function(self) self:finishtweening():visible(true):sleep(0.7):queuecommand("Hide") end,
	HideCommand=function(self) self:visible(false) end,

	LoadActor("../Combo 100milestone"),

	LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/Combo 1000milestone swoosh"))..{
		InitCommand=function(self) self:diffusealpha(0):blend("BlendMode_Add") end,
		ThousandMilestoneCommand=function(self) self:finishtweening():diffuse(c):zoom(0.25):diffusealpha(0.7):x(0):linear(0.7):zoom(3):diffusealpha(0):x(100) end
	},

	LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/Combo 1000milestone swoosh"))..{
		InitCommand=function(self) self:diffusealpha(0):blend("BlendMode_Add") end,
		ThousandMilestoneCommand=function(self) self:finishtweening():diffuse(c):rotationy(180):zoom(0.25):diffusealpha(0.7):x(0):linear(0.7):zoom(3):diffusealpha(0):x(-100) end
	}
}