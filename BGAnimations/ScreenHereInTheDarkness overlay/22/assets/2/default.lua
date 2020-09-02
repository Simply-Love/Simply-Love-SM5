local af = Def.ActorFrame{}

-- booth
af[#af+1] = LoadActor("./booth.jpg")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self)
		self:sleep( 3):smooth(4):diffusealpha(1)
	   self:sleep(36):smooth(2):diffusealpha(0)
	end,
}

-- disjointed thoughts
af[#af+1] = LoadActor("./thoughts.png")..{
	InitCommand=function(self) self:diffusealpha(0):zoom(1.05):xy(-5, -5) end,
	ShowCommand=function(self)
		self:sleep(47):smooth(1.666):diffusealpha(1)
		self:linear(10):xy(5,5):smooth(1.666):diffusealpha(0)
	end
}

-- disjointed thoughts
af[#af+1] = LoadActor("./thoughts.png")..{
	InitCommand=function(self) self:diffusealpha(0):zoom(1.05):xy(-5, -5) end,
	ShowCommand=function(self)
		self:sleep(47):smooth(1.666):diffusealpha(1)
		self:sleep(10):smooth(1.666):diffusealpha(0)
	end
}

-- me
af[#af+1] = LoadActor("./me.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self)
		self:smooth(1.666):diffusealpha(1):sleep(65):smooth(1.666):diffusealpha(0)
	end,
}

-- us
af[#af+1] = LoadActor("./us.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self)
		self:sleep(72):smooth(5):diffusealpha(1):linear(40):zoom(1.4):smooth(5):diffusealpha(0)
	end,
}

-- fade
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w*10, _screen.h*10):diffuse(0,0,0,1) end,
	ShowCommand=function(self)
		self:smooth(5):diffusealpha(0)
			:sleep(25.5):smooth(3):diffusealpha(0.5)
			:sleep(4.5):smooth(3):diffusealpha(0)
		end
}

-- why are you up here?
af[#af+1] = LoadActor("./why.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(32):smooth(1):diffusealpha(1):sleep(1.25):smooth(3):diffusealpha(0) end,
}

return af