t = Def.ActorFrame {}

t[#t+1] = Def.Sprite {
	
	Texture="Sonic 4x2.png",
	Frame0000=0,	Delay0000=0.125,
	Frame0001=1,	Delay0001=0.125,
	Frame0002=2,	Delay0002=0.125,
	Frame0003=3,	Delay0003=0.125,
	Frame0004=4,	Delay0004=0.125,
	Frame0005=5,	Delay0005=0.125,
	Frame0006=6,	Delay0006=0.125,
	Frame0007=7,	Delay0007=0.125,
	
	OnCommand=function(self)
		self:effectclock("bgm")
		self:cropright(0.02)
		self:cropleft(0.02)
		self:croptop(0.02)
		self:cropbottom(0.02)
		self:zoom(2)
	end
	
}

return t