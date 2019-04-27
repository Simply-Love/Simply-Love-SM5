-- "Don't you think it looks a little like snow?"

local af = Def.ActorFrame{}
af.OnCommand=function(self) self:sleep(12):queuecommand("Transition") end
af.TransitionCommand=function(self) SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen") end

af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/1/snowfall.mp4"),
	InitCommand=function(self) self:diffuse(0,0,0,1):Center():zoom(2/3) end,
	OnCommand=function(self) self:smooth(2):diffuse(1,1,1,1):sleep(9):smooth(1):diffuse(0,0,0,1) end
}

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/1/snowfall.ogg"),
	OnCommand=function(self) self:play() end
}

return af