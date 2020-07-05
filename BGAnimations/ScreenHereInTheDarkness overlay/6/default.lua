-- elsewhere, far away

local af = Def.ActorFrame{}
af.InputEventCommand=function(self, event)
	if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
		self:stoptweening():smooth(1):diffuse(0,0,0,1):sleep(0.5):queuecommand("NextScreen")
	end
end
af.InitCommand=function(self) self:xy(_screen.cx,0):diffuse(0,0,0,1) end
af.OnCommand=function(self)
	self:sleep(2):smooth(1):diffuse(1,1,1,1):sleep(29):smooth(1):diffuse(0,0,0,1):queuecommand("NextScreen")
end
af.NextScreenCommand=function(self)
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end

af[#af+1] = LoadActor("./seaside_catchball.ogg")..{
	OnCommand=function(self) self:play() end,
	OffCommand=function(self) self:stop() end,
}

af[#af+1] = LoadActor("./seaside_catchball.mp4")..{
	InitCommand=function(self) self:valign(0):y(0):loop(false) end,
}

af[#af+1] = LoadActor("./yt.png")..{
	InitCommand=function(self) self:valign(1):y(_screen.h+40):zoom(0.582) end
}

return af