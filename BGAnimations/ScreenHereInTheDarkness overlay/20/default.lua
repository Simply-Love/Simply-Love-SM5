-- I am a walk to nowhere.

local af = Def.ActorFrame{}
af.OnCommand=function(self) self:sleep(17.5):queuecommand("Transition") end
af.TransitionCommand=function(self) SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen") end

af[#af+1] = LoadActor("./walk.mp4")..{
	InitCommand=function(self) self:diffuse(0,0,0,1):Center():zoom(2/3) end,
	OnCommand=function(self) self:smooth(2):diffuse(1,1,1,1):sleep(12.5):smooth(3):diffuse(0,0,0,1) end
}

af[#af+1] = LoadActor("./walk.ogg")..{
	OnCommand=function(self) self:play() end
}

return af