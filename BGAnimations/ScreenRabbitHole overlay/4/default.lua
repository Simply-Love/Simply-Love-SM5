-- recalling
local haiku = "as my cursor blinks\nidle, my mind is active\nrecalling your voice"

local af = Def.ActorFrame{
	InputEventCommand=function(self, event)
		if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
			self:smooth(1):diffuse(0,0,0,1):queuecommand("NextScreen")
		end
	end,
	NextScreenCommand=function(self)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
}


af[#af+1] = LoadActor("./recalling.ogg")..{
	OnCommand=function(self) self:play() end
}

af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	Text=haiku,
	InitCommand=function(self) self:Center():diffusealpha(0) end,
	OnCommand=function(self) self:sleep(2.5):linear(1):diffusealpha(1) end
}

af[#af+1] = LoadActor("./mask.png")..{
	InitCommand=function(self) self:zoom(0.25):Center() end,
	OnCommand=function(self) self:sleep(0.5):pulse():effectmagnitude(14,1,1):effectperiod(6) end
}

-- cursor
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:halign(0):xy(_screen.cx,_screen.cy-100):zoomto(2,20):diffuseblink():effectperiod(1):effectcolor1(0,0,0,1):effectcolor2(1,1,1,1) end
}


return af