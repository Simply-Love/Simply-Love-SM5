-- simultaneously reassuring
-- yet determinedly sad

local af = Def.ActorFrame{}


af[#af+1] = LoadActor("./river.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(1):smooth(4):diffusealpha(1):sleep(26):smooth(3):diffusealpha(0) end,
}

-- -------------------------------------------

af[#af+1] = Def.ActorFrame{
	InitCommand=function(self) self:x(40):zoom(1.1):diffusealpha(0) end,
	ShowCommand=function(self) self:smooth(4):diffusealpha(1):sleep(29):smooth(3):diffusealpha(0) end,

	LoadActor("./water-texture1.png")..{
		InitCommand=function(self) self:rotationy(180):texcoordvelocity(0,0.025):customtexturerect(0,0,1,1) end,
	},
	LoadActor("./water-texture1.png")..{
		InitCommand=function(self) self:rotationy(180):texcoordvelocity(0,0.025):customtexturerect(0,0.333,1,1.333) end,
	},
	LoadActor("./water-texture1.png")..{
		InitCommand=function(self) self:rotationy(180):texcoordvelocity(0,0.025):customtexturerect(0,0.666,1,1.666) end,
	},

	LoadActor("./water-texture2.png")..{
		InitCommand=function(self) self:texcoordvelocity(0,0.04):customtexturerect(0,0,1,1) end,
	},
	LoadActor("./water-texture2.png")..{
		InitCommand=function(self) self:texcoordvelocity(0,0.04):customtexturerect(0,0.333,1,1.333) end,
	},
	LoadActor("./water-texture2.png")..{
		InitCommand=function(self) self:texcoordvelocity(0,0.04):customtexturerect(0,0.666,1,1.666) end,
	},
}

-- -------------------------------------------

af[#af+1] = LoadActor("./grass.png")..{
	InitCommand=function(self) self:diffuse(0,0,0,0) end,
	ShowCommand=function(self) self:smooth(1):diffusealpha(1):sleep(8):smooth(1.666):diffuse(1,1,1,1):sleep(23):smooth(3):diffusealpha(0) end,
}

af[#af+1] = LoadActor("./characters.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(11):smooth(1.666):diffusealpha(1) end,
}

af[#af+1] = LoadActor("./time1.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(18):smooth(6):diffusealpha(1):smooth(6):diffusealpha(0) end,
}

af[#af+1] = LoadActor("./time2.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(24):smooth(6):diffusealpha(1):sleep(4):smooth(3):diffusealpha(0) end,
}

-- -------------------------------------------
-- sparkles over

af[#af+1] = LoadActor("./sparkles2.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self)
		self:sleep(10):smooth(1.666):diffusealpha(1)
			:diffuseshift():effectperiod(4):effectcolor1(1,1,1,1):effectcolor2(1,1,1,0.5)
			:sleep(20):smooth(2):diffusealpha(0)
	end
}
af[#af+1] = LoadActor("./sparkles1.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self)
		self:sleep(10):smooth(1.666):diffusealpha(1)
			:diffuseshift():effectperiod(4):effectcolor1(1,1,1,1):effectcolor2(1,1,1,0)
			:sleep(20):smooth(2):diffusealpha(0)
	end
}

return af