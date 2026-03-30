t = Def.ActorFrame {}

t[#t+1] = Def.Sprite {
	
	Texture="NyanCat 4x3.png",
	Frame0000=6,	Delay0000=0.1666666666666667,
	Frame0001=7,	Delay0001=0.1666666666666667,
	Frame0002=8,	Delay0002=0.1666666666666667,
	Frame0003=9,	Delay0003=0.1666666666666667,
	Frame0004=10,	Delay0004=0.1666666666666667,
	Frame0005=11,	Delay0005=0.1666666666666667,
	Frame0006=0,	Delay0006=0.1666666666666667,
	Frame0007=1,	Delay0007=0.1666666666666667,
	Frame0008=2,	Delay0008=0.1666666666666667,
	Frame0009=3,	Delay0009=0.1666666666666667,
	Frame0010=4,	Delay0010=0.1666666666666667,
	Frame0011=5,	Delay0011=0.1666666666666667,
	
	OnCommand=function(self)
		self:effectclock("bgm")
		self:cropright(0.02)
		self:cropleft(0.02)
		self:croptop(0.02)
		self:cropbottom(0.02)
		self:zoom(1.4)
	end
	
}

return t