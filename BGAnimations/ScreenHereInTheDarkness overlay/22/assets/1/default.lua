local af = Def.ActorFrame{}

-- ---------------------------------
-- bg

local bg = Def.ActorFrame{}
bg.ShowCommand=function(self) self:zoom(1.4):linear(19):zoom(1):smooth(6):diffusealpha(0):queuecommand("Hide") end
bg.HideCommand=function(self) self:visible(false) end

bg[#bg+1] = LoadActor("./bg.jpg")..{
	InitCommand=function(self) self:zoom(1.5):diffusealpha(1) end,
	ShowCommand=function(self)
		self:spin():effectmagnitude(2,0,0)
	end
}
bg[#bg+1] = LoadActor("./bg.jpg")..{
	InitCommand=function(self) self:zoom(1.5):diffusealpha(0.65) end,
	ShowCommand=function(self)
		self:spin():effectmagnitude(0,1.5,0)
	end
}
bg[#bg+1] = LoadActor("./bg.jpg")..{
	InitCommand=function(self) self:rotationz(180) end,
	ShowCommand=function(self)
		self:sleep(0.5)
		self:diffuseshift():effectcolor1(1,1,1,1):effectcolor2(1,1,1,0):effectperiod(4.444):effect_hold_at_full(0.5)
	end
}

bg[#bg+1] = Def.ActorFrame{
	InitCommand=function(self) self:zoom(1.333) end,
	ShowCommand=function(self)
		self:sleep(2.222):spin():effectmagnitude(0,1,0)
	end,

	LoadActor("./bg.jpg")..{
		ShowCommand=function(self)
			self:sleep(1.75):rotationy(180)
			self:diffuseshift():effectcolor1(1,1,1,1):effectcolor2(1,1,1,0):effectperiod(4.444):effect_hold_at_full(0.5)
		end
	}
}

bg[#bg+1] = LoadActor("./bg.jpg")..{
	InitCommand=function(self) self:zoom(1.5):rotationy(180):rotationx(180):diffusealpha(0) end,
	ShowCommand=function(self)
		self:sleep(3.333)
		self:diffuseshift():effectcolor1(1,1,1,0.25):effectcolor2(1,1,1,1):effectperiod(4.444)
	end
}

af[#af+1] = bg

-- ---------------------------------
-- ladder

local rung_height = 448

af[#af+1] = LoadActor("./ladder.png")..{
	InitCommand=function(self) self:valign(1):y(_screen.h) end,
	ShowCommand=function(self) self:sleep(0.5):queuecommand("Climb") end,
	ClimbCommand=function(self)
		-- climb 7 rungs of the utility ladder
		self:bounceend(2.5):addy(rung_height):sleep(0.5)
		self:bounceend(2.5):addy(rung_height):sleep(0.5)
		self:bounceend(2.5):addy(rung_height):sleep(0.5)
		self:bounceend(2.5):addy(rung_height):sleep(0.5)
		self:bounceend(2.5):addy(rung_height):sleep(0.5)
		self:bounceend(2.5):addy(rung_height):sleep(0.5)
		self:bounceend(2.5):addy(rung_height):sleep(0.5)
		self:bounceend(2.5):addy(rung_height):sleep(0.5)

		self:smooth(0.666):diffusealpha(0)
	end,
}

-- ---------------------------------
-- fade

af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w*10, _screen.h*10):diffuse(0,0,0,1) end,
	ShowCommand=function(self) self:smooth(3):diffusealpha(0):sleep(16.5):smooth(4.5):diffusealpha(1) end
}

-- ---------------------------------

return af