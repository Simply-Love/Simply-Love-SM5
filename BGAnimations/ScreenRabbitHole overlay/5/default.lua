-- elsewhere, far away
local af = Def.ActorFrame{}
af.InputEventCommand=function(self, event)
	if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
end
af.InitCommand=function(self) self:xy(_screen.cx,0):diffusealpha(0) end
af.OnCommand=function(self)
	self:sleep(2):linear(1):diffusealpha(1)
end

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/5/seaside_catchball.ogg"),
	OnCommand=function(self) self:play() end
}

af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/5/seaside_catchball.mp4"),
	InitCommand=function(self) self:valign(0):y(0):loop(true) end
}

af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/5/yt.png"),
	InitCommand=function(self) self:valign(1):y(_screen.h+40):zoom(0.582) end
}

return af