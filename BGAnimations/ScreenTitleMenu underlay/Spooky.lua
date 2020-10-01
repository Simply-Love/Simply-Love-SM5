local af = Def.ActorFrame{}

af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w, _screen.h):diffuse(0,0,0,0) end,
	TitleMenuToGameplayMessageCommand=function(self) self:smooth(1):diffusealpha(1) end
}

af[#af+1] = LoadActor(THEME:GetPathG("", "_VisualStyles/Spooky/SelectColor.png"))..{
	InitCommand=function(self) self:zoom(0.2):diffuse(GetHexColor(12, true)):diffusealpha(0) end,
	TitleMenuToGameplayMessageCommand=function(self) self:sleep(0.55):smooth(1.15):diffuse(0.9,0,0,0.65):sleep(0.15):smooth(0.5):diffuse(0,0,0,0) end
}

return af