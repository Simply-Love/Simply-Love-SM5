-- guitar

local af = Def.ActorFrame{}

af[#af+1] = LoadActor("./bg.png")..{
	InitCommand=function(self) self:diffuse(1,1,1,0) end,
	ShowCommand=function(self) self:smooth(1.666):diffuse(1,1,1,1) end,
}

af[#af+1] = LoadActor("./shading.png")..{
	InitCommand=function(self) self:diffuse(1,1,1,0) end,
	ShowCommand=function(self) self:sleep(0.2):smooth(1.666):diffuse(1,1,1,1) end,
}

af[#af+1] = LoadActor("./guitar.png")..{
	InitCommand=function(self) self:diffuse(1,1,1,0) end,
	ShowCommand=function(self) self:sleep(1):smooth(3):diffuse(1,1,1,0.8) end,
}

af[#af+1] = LoadActor("./splotches.png")..{
	InitCommand=function(self) self:diffuse(1,1,1,0):x(5):y(50):zoom(1.1) end,
	ShowCommand=function(self) self:sleep(3):accelerate(1):diffuse(1,1,1,0.666):zoom(1.115):x(0) end,
}

af[#af+1] = LoadActor("./splotches.png")..{
	InitCommand=function(self) self:diffuse(1,1,1,0):rotationz(180):x(-105):zoom(1.015) end,
	ShowCommand=function(self) self:sleep(6):accelerate(2):diffuse(1,1,1,0.666):zoom(1.025):x(-100) end,
}

af[#af+1] = LoadActor("./splotches.png")..{
	InitCommand=function(self) self:diffuse(1,1,1,0) end,
	ShowCommand=function(self) self:sleep(9):smooth(2.5):diffuse(0.5,0.5,0.5,0.8):zoom(1.025) end,
}

af[#af+1] = LoadActor("./splotches.png")..{
	InitCommand=function(self) self:diffuse(1,1,1,0):zoom(1.333):rotationy(180) end,
	ShowCommand=function(self) self:sleep(9):smooth(4):diffuse(0.45,0.45,0.45,0.75) end,
}

af[#af+1] = LoadActor("./silhouette.png")..{
	InitCommand=function(self) self:diffuse(1,1,1,0):zoom(3) end,
	ShowCommand=function(self) self:sleep(3):smooth(10):diffuse(0,0,0,1):zoom(1) end,
}

return af