-- D  Bm  D  Bm
-- D  E   D  E
-- D  C   D  Em
-- D

local intro = {"Walking on the balls of my feet", "I led her down a dark hallway."}
local footsteps = { "our","feet","gently","tip","tap","tapping","on","the","cold","dark","floor","as we","walked","hand in hand","together" }
local outro = {"Where were we going?", "How would we know when we got there?", "I gripped her hand more tightly."}

local line_height = 18
local font_path = THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini")

local line = function(text, i, num_lines, wait)
	return Def.BitmapText{
		File=font_path,
		Text=text,
		InitCommand=function(self)
			self:xy( _screen.cx, _screen.cy-50-((num_lines-i)*line_height) ):diffusealpha(0)
		end,
		OnCommand=function(self)
			self:sleep(wait + (i-1)*2):smooth(2):diffusealpha(1)
			self:sleep(3):smooth(2):diffusealpha(0)
		end,
	}
end

local af = Def.ActorFrame{}
af.InputEventCommand=function(self, event)
	if event.type == "InputEventType_FirstPress" and event.GameButton=="Back" then
		self:queuecommand("NextScreen")
	end
end
af.OnCommand=function(self)
	self:queuecommand("Intro")
	self:sleep(11):queuecommand("Walk")
	self:sleep(#footsteps/1.475):queuecommand("Hide")
	self:sleep(14):queuecommand("NextScreen")
end
af.NextScreenCommand=function(self)
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end

af[#af+1] = LoadActor("hallways-v1.ogg")..{
	OnCommand=function(self) self:play() end
}

for i=1, #intro do
	af[#af+1] = line(intro[i], i, #intro, 2)
end

for i=1, #outro do
	af[#af+1] = line(outro[i], i, #outro, 22.125)
end

local hallway = Def.ActorFrame{
	InitCommand=function(self) self:y(_screen.cy+20):fov(90):rotationx(-80) end,
	WalkCommand=function(self) self:linear(#footsteps/1.475) end,
	HideCommand=function(self) self:visible(false) end
}

for i=#footsteps, 1, -1 do
	 hallway[i]= Def.ActorFrame{
		InitCommand=function(self) self:diffuse(0,0,0,1) end,
		WalkCommand=function(self) self:sleep(i*0.5):accelerate(1.25):diffuse(1,1,1,1) end,

		Def.BitmapText{
			File=font_path,
			Text=footsteps[i],
			InitCommand=function(self) self:xy(_screen.cx+(i%2==0 and -20 or 20), -70):rotationx(82.5) end,
			WalkCommand=function(self) self:sleep(i*0.5):linear(2.4):y(_screen.h * 0.75):linear(0.5):diffusealpha(0):queuecommand("Hide") end,
			HideCommand=function(self) self:visible(false) end
		}
	}
end

af[#af+1] = hallway

return af