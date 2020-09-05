-- distant towers

local af = Def.ActorFrame{}

-- white bg
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:diffuse(1,1,1,1):zoomto(_screen.w*10, _screen.h*10) end,
	ShowCommand=function(self) self:sleep(50):smooth(3):diffuse(0,0,0,1) end
}

af[#af+1] = LoadActor("./tower2.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(50):smooth(3):diffusealpha(0.75):accelerate(1.5):diffusealpha(0) end,
}

af[#af+1] = Def.ActorFrame{
	InitCommand=function(self) self:zoom(1.2):y(100):valign(0) end,
	ShowCommand=function(self) self:sleep(15):linear(30):zoom(1):y(0):smooth(4):diffusealpha(0) end,


	LoadActor("./all.png")..{
		InitCommand=function(self) end,
		ShowCommand=function(self) self:smooth(6):diffusealpha(0) end,
		FadeOutCommand=function(self)  end
	},

	LoadActor("./city.png")..{
		InitCommand=function(self) end,
		ShowCommand=function(self) self:sleep(3):smooth(3):diffusealpha(1) end,
		FadeOutCommand=function(self) self:decelerate(1.666):diffuse(0,0,0,0) end
	},

	LoadActor("./shading.png")..{
		InitCommand=function(self) end,
		ShowCommand=function(self) self:sleep(3):smooth(3):diffusealpha(1) end,
		FadeOutCommand=function(self) self:decelerate(1.666):diffuse(0,0,0,0) end
	},

	LoadActor("./tower.png")..{
		InitCommand=function(self) end,
		ShowCommand=function(self) self:sleep(1):smooth(3):diffusealpha(1) end,
		FadeOutCommand=function(self) self:decelerate(1.666):diffuse(0,0,0,0) end
	},

	LoadActor("./powerlines.png")..{
		InitCommand=function(self) end,
		ShowCommand=function(self) self:sleep(6):smooth(2):diffusealpha(1) end,
		FadeOutCommand=function(self) self:decelerate(1.666):diffuse(0,0,0,0) end
	},

	LoadActor("./birds.png")..{
		InitCommand=function(self) end,
		ShowCommand=function(self) self:sleep(8):smooth(1):diffusealpha(1) end,
		FadeOutCommand=function(self) self:decelerate(1.666):diffuse(0,0,0,0) end
	},
}

af[#af+1] = LoadActor("./window.png")..{
	InitCommand=function(self) end,
	ShowCommand=function(self) self:sleep(14):accelerate(6):zoom(2):x(80) end,
	FadeOutCommand=function(self) self:decelerate(1.666):diffuse(0,0,0,1) end
}

-- black fg
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:diffuse(0,0,0,1):zoomto(_screen.w*10, _screen.h*10) end,
	ShowCommand=function(self) self:smooth(4):diffusealpha(0):queuecommand("Hide") end,
	HideCommand=function(self) self:visible(false) end,
}

return af