-- D  Bm  D  Bm
-- D  E   D  E
-- D  C   D  Em
-- D

local intro = "Walking on the balls of my feet\nI led her down a dark hallway."
local footsteps = { "our","feet","gently","tip","tap","tapping","on","the","cold","dark","floor","as we","walked","hand in hand","together" }
local outro = "Where were we going?\nHow would we know when we got there?\nI gripped her hand more tightly."

local af = Def.ActorFrame{}
af.InputEventCommand=function(self, event)
	if event.type == "InputEventType_FirstPress" and event.GameButton=="Back" then
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
end
af.OnCommand=function(self)
	self:queuecommand("Intro")
		:sleep(11):queuecommand("Walk")
		:sleep(#footsteps/1.475):queuecommand("Outro")
end


af[#af+1] = LoadActor("hallways-v1.ogg")..{
	OnCommand=function(self) self:play() end
}

af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	Text=intro,
	InitCommand=function(self) self:xy( _screen.cx, _screen.cy-self:GetHeight()/2 ):diffusealpha(0) end,
	IntroCommand=function(self)
		self:sleep(2):linear(2):diffusealpha(1):sleep(5):linear(2):diffusealpha(0)
		if self:GetText()==outro then
			self:sleep(3):queuecommand("Transition")
		end
	end,
	OutroCommand=function(self)
		self:settext(outro):queuecommand("Intro")
	end,
	TransitionCommand=function(self)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
}

local hallway = Def.ActorFrame{
	InitCommand=function(self) self:y(_screen.cy+20):fov(90):rotationx(-80) end,
	WalkCommand=function(self) self:linear(#footsteps/1.475) end,
	OutroCommand=function(self) self:visible(false) end
}

for i=#footsteps, 1, -1 do
	 hallway[i]= Def.ActorFrame{
		InitCommand=function(self) self:diffuse(0,0,0,1) end,
		WalkCommand=function(self) self:sleep(i*0.5):accelerate(1.25):diffuse(1,1,1,1) end,

		Def.BitmapText{
			File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
			Text=footsteps[i],
			InitCommand=function(self) self:xy(_screen.cx+(i%2==0 and -20 or 20), -70):rotationx(82.5) end,
			WalkCommand=function(self) self:sleep(i*0.5):linear(2.4):y(_screen.h * 0.75) end
		}
	}
end

af[#af+1] = hallway

return af