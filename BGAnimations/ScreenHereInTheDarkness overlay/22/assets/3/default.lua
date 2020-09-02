local af = Def.ActorFrame{}

-- holding hands
af[#af+1] = LoadActor("./holdinghands.jpg")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:smooth(6):diffusealpha(1) end
}

-- fade
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w*10, _screen.h*10):diffuse(1,1,1,0) end,
	ShowCommand=function(self) self:sleep(4.5):smooth(5):diffusealpha(1) end
}

-- winter
af[#af+1] = LoadActor("./winter.jpg")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(12):smooth(3):diffusealpha(1) end
}

-- spring
af[#af+1] = LoadActor("./spring.jpg")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(20):smooth(3):diffusealpha(1) end
}

-- summer
af[#af+1] = LoadActor("./summer.jpg")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(28):smooth(3):diffusealpha(1) end
}

-- fade
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w*10, _screen.h*10):diffuse(1,1,1,0) end,
	ShowCommand=function(self) self:sleep(35):smooth(5):diffusealpha(1) end
}

return af